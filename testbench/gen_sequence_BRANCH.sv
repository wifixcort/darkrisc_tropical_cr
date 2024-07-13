import instructions_data_struc::*;

class gen_sequence_BRANCH extends gen_sequence;
    `uvm_object_utils(gen_sequence_BRANCH)
    function new(string name="gen_sequence_BRANCH");
        super.new(name);
    endfunction

    //rand logic [3:0] num_chunks; //Cuantos grupos de 6 instrucciones se usaran?

    //logic [6:0] total_chunks;  //Cuantos grupos de 6 instrucciones hay disponibles
    //logic [6:0] puntero_chunk; //Por cual grupo de 6 instrucciones vamos?
    //logic       bndra_ncsto_inc; //Bandera necesito incremento
    
    int instruction_counter = 0;
    logic [8:0] total_nops;  //Numero total de nops por branch
    logic [31:0] addi2_imm_val;
    logic signed [20:1] offset_jump;
    
    virtual task body();
        
        sequence_item_rv32i_instruction item_BRANCH     = sequence_item_rv32i_instruction::type_id::create("item_BRANCH"); // Instruction Branch
        sequence_item_rv32i_instruction item_ADDI_1     = sequence_item_rv32i_instruction::type_id::create("item_ADDI_1"); // Instruction ADDI for set item_BRANCH.rs1
        sequence_item_rv32i_instruction item_ADDI_2     = sequence_item_rv32i_instruction::type_id::create("item_ADDI_2"); // Instruction ADDI for set item_BRANCH.rs2
        sequence_item_rv32i_instruction item_ADDI_rupt  = sequence_item_rv32i_instruction::type_id::create("item_ADDI_rupt"); // Instruction ADDI for broke the branch condition
        sequence_item_rv32i_instruction item_JAL        = sequence_item_rv32i_instruction::type_id::create("item_JAL"); // Instruction JAL for generate a loop
        sequence_item_rv32i_instruction item_NOP        = sequence_item_rv32i_instruction::type_id::create("item_NOP"); // Instruction NOP
        item_NOP.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==0 && imm==0;};

        //branch_aux_vars aux_vars = branch_aux_vars::type_id::create("aux_vars"); // Instruction i
        //total_chunks = 80; // For defecto vamos a generar unos 80 chunks
        //puntero_chunk = 85;
        
         
        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        // Para la cantidad de instrucciones correspondiente (512 actualmente) 
        //
        //while ( (total_chunks>15)&&(puntero_chunk>0) )begin
        while (instruction_counter < 2**`MLEN/(4*2) ) begin
           
            // Generacion de estructuras de branches "chunks"
            if ( instruction_counter <= 2**`MLEN/(4*2) - 30) begin
                //Aqui genera variables que son generales a tods los tipos de branch   
                //aux_vars.randomize(); //Genera cuantos chunks          
                //total_nops = (aux_vars.num_chunks*6)-5;
                //$display("Necesito esta cantidad de chunks para este branch%d", (total_nops+5)/6 );  //aux_vars.num_chunks
                //$display("Para este branch necesito esta cantidad de nops %d", total_nops);
                //$display("Chunks restantes: %d", total_chunks);
                //Usar los punteros de registros rs1 y rs2 de forma que tenga sentido.
                
                //*** Generacion de instrucciones BRANCH y JAL con su respectivo offset ***//
                total_nops   = $urandom_range(5,20);   //($urandom_range(1,29) * 6) - 5
                offset_jump = -(1+total_nops+1)*(4/2);
                item_BRANCH.randomize() with {opcode==S_B_TYPE && funct3==BEQ_FC && rs1!=0 && rs2!=0 && rs1!=rs2 && imm==(total_nops+1+1+1)*(4/2);};  //offset = nops + addi_rupt + jal + 1   //&& imm==(total_nops+1+1+1)*4
                item_JAL.randomize() with {opcode==J_TYPE && rd==0 && imm_jal==offset_jump;};

                //*** Enviar creadores de estado de condicion ADDI_1 y ADDI_2 ***//
                item_ADDI_1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_BRANCH.rs1;};
                addi2_imm_val = $urandom_range(item_ADDI_1.imm-10 , item_ADDI_1.imm+10); // Asegurar que no hay mucha diferencia entre los valores para que no se genere un loop excesivo
                item_ADDI_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_BRANCH.rs2 && imm==addi2_imm_val;}; //todo: Este randomize debe ser diferente para las BNE. Implementar mediante un if
                // Info
                $display("\n(ADDI_1)\t\t\tPC: 0x%h\t\tInstruction: %h\t", instruction_counter[9:0]*4, item_ADDI_1.full_inst);
                $display("(ADDI_2)\t\t\tPC: 0x%h\t\tInstruction: %h\t", instruction_counter[9:0]*4+1'b1, item_ADDI_2.full_inst);
                // Transactions
                start_item(item_ADDI_1);
                finish_item(item_ADDI_1);
                start_item(item_ADDI_2);
                finish_item(item_ADDI_2);
                instruction_counter+=2;

                //*** Enviar Branch ***//
                // Transaction
                // Info
                $display("(BRANCH)\t\t\tPC: 0x%h\t\tInstruction: %h\toffset: 0x%h\t\tTarget_PC: 0x%h", instruction_counter[9:0]*4, item_BRANCH.full_inst, $signed(item_BRANCH.imm)*2'h2, instruction_counter*4+$signed(item_BRANCH.imm)*2);
                start_item(item_BRANCH);
                finish_item(item_BRANCH);
                instruction_counter++;

                //*** Enviar NOPs ***//    
                for(int k=0; k < total_nops; k=k+1) begin
                    // Info
                    $display("(NOP # %d)\t\tPC: 0x%h\t\tInstruction: %h", k[7:0], instruction_counter[9:0]*4, item_NOP.full_inst);
                    // Transaction
                    start_item(item_NOP);
                    finish_item(item_NOP);
                    instruction_counter++;         
                end


                 //*** Enviar ADDI para ruptura de condicion, dependiendo del tipo de branch ***//
                if (item_BRANCH.funct3 == BEQ_FC) begin     //Caso BEQ
                
                    // If rs1_value > que rs2_value : enviar instruccion que decremente rs1_value
                    if ( item_ADDI_1.imm > item_ADDI_2.imm) begin
                        item_ADDI_rupt.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==item_BRANCH.rs1 && rd==item_BRANCH.rs1 && imm==12'hfff;};
                    end
                    // If rs1_value < que rs2_value : enviar instruccion que incremente rs1_value 
                    else if (item_ADDI_1.imm < item_ADDI_2.imm) begin
                        item_ADDI_rupt.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==item_BRANCH.rs1 && rd==item_BRANCH.rs1 && imm==12'h001;};
                    end
                    // Info
                    $display("(ADDI_rupt)\t\tPC: 0x%h\t\tInstruction: %h\timm:", instruction_counter[9:0]*4, item_ADDI_rupt.full_inst, $signed(item_ADDI_rupt.imm));
                    // Transaction
                    start_item(item_ADDI_rupt);
                    finish_item(item_ADDI_rupt);
                    instruction_counter++;
                end
                //TODO: condicionales para las condiciones de ruptura de los restantes tipos de branch

                //*** Enviar JAL para generar loop ***//
                // Info
                $display("(JAL)\t\t\tPC: 0x%h\t\tInstruction: %h\toffset: %d\tTarget_PC: 0x%h\n", instruction_counter[9:0]*4, item_JAL.full_inst, $signed(item_JAL.imm_jal*2'h2), instruction_counter*4+$signed(item_JAL.imm_jal)*2 );
                // Transaction
                start_item(item_JAL);
                finish_item(item_JAL);
                instruction_counter++;    
            end


            // NOPs finales
            else if (instruction_counter <= 2**`MLEN/(4*2) - 4) begin
                // Info
                $display("(NOP)\t\t\tPC: 0x%h\t\tInstruction: %h", instruction_counter[9:0]*4, item_NOP.full_inst);
                // Transaction
                start_item(item_NOP);
                finish_item(item_NOP);
                instruction_counter++;       
            end

            // Jump here final
            else begin
                item_JAL.randomize() with {opcode==J_TYPE && imm_jal[20:5]==16'hffff ;};  
                // Info     
                $display("(JAL)\t\t\tPC: 0x%h\t\tInstruction: %h\tOffset: %d", instruction_counter[9:0]*4, item_JAL.full_inst, $signed(item_JAL.imm_jal)*2);
                // Transaccion JAL
                start_item(item_JAL);
                finish_item(item_JAL); 
                instruction_counter++;
            end
        end



        //     //Fin de la secuencia
        //     total_chunks = total_chunks-aux_vars.num_chunks;
        //     puntero_chunk = puntero_chunk - 1;
        // end


        // for(int i=0; i < 10; i=i+1) begin             
        //     // Cuando llegue la ultima instruccion, meter jal para retroceder
        //     if ( i == 9 ) begin
        //         item_0.randomize() with {opcode==J_TYPE && imm_jal[20:10]==11'hfff ;};       
        //         $display("\n(for JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
        //         // Transaccion JAL
        //         start_item(item_0);
        //         finish_item(item_0); 
        //     end

        //     // Instrucciones R
        //     else begin
        //         item_0.randomize() with {opcode==R_TYPE;};

        //         start_item(item_0);
        //         finish_item(item_0);

        //         $display("\n(R type)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst); 

        //     end
        // end
    endtask
endclass