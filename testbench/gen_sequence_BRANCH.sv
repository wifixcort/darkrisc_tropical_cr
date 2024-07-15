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
    logic [8:0] total_nops;             // Numero total de nops por branch
    logic [31:0] addi2_imm_val;         // Valor inmediato para ADDI_2
    logic signed [20:1] offset_jump;    // Para calcular el offset negativo 
    logic [11:0] inc_dec_value;         // Valor inmediato de incremento/decremento para ADDI_rupt
    
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
                
                //*** Generacion de instrucciones BRANCH y JAL con su respectivo offset ***//
                total_nops   = $urandom_range(5,20);   //($urandom_range(1,29) * 6) - 5
                offset_jump = -(1+total_nops+1)*(4/2);
                item_BRANCH.randomize() with {opcode==S_B_TYPE && rs1!=0 && rs2!=0 && rs1!=rs2 && imm==(total_nops+1+1+1)*(4/2);};  //offset = nops + addi_rupt + jal + 1   //&& imm==(total_nops+1+1+1)*4
                item_JAL.randomize() with {opcode==J_TYPE && rd==0 && imm_jal==offset_jump;};

                //*** Enviar creadores de estado de condicion ADDI_1 y ADDI_2. Dependen del tipo de BRANCH ***//
                item_ADDI_1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_BRANCH.rs1;}; // ADDI_1 es el mismo siempre
                // BNE
                if (item_BRANCH.funct3 == BNE_FC) begin
                    addi2_imm_val = item_ADDI_1.imm; //imm de ADDI_1 igual que imm de ADDI_2 para el caso de BNE 
                // BEQ
                end else if (item_BRANCH.funct3 == BEQ_FC) begin
                    do
                        addi2_imm_val = $urandom_range(item_ADDI_1.imm-10 , item_ADDI_1.imm+10); // Asegurar que no hay mucha diferencia entre los valores para que no se genere un loop excesivo
                    while (addi2_imm_val == item_ADDI_1.imm);  // Asegurar que los valores asignados por los ADDI 1 y 2 sean diferentes     
                // BLT
                end else if ( (item_BRANCH.funct3 == BLT_FC) || (item_BRANCH.funct3 == BLTU_FC) ) begin
                    addi2_imm_val = $urandom_range(item_ADDI_1.imm-10 , item_ADDI_1.imm-1); // Asegurar que rs1_val > rs2_val para que no se tome el salto inicialmente
                // BGE
                end else if ((item_BRANCH.funct3 == BGE_FC) || (item_BRANCH.funct3 == BGEU_FC)) begin
                    addi2_imm_val = $urandom_range(item_ADDI_1.imm+1 , item_ADDI_1.imm+10); // Asegurar que rs1_val < rs2_val para que no se tome el salto inicialmente
                end
                item_ADDI_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_BRANCH.rs2 && imm==addi2_imm_val;};
                // Info
                $display("\n(ADDI_1)\t\tPC: 0x%h\t\tInstruction: %h\timm: 0x%h", instruction_counter[9:0]*4, item_ADDI_1.full_inst, item_ADDI_1.imm);
                $display("(ADDI_2)\t\tPC: 0x%h\t\tInstruction: %h\timm: 0x%h", (instruction_counter[9:0]+1'b1)*4, item_ADDI_2.full_inst, item_ADDI_2.imm);
                // Transactions
                start_item(item_ADDI_1);
                finish_item(item_ADDI_1);
                start_item(item_ADDI_2);
                finish_item(item_ADDI_2);
                instruction_counter+=2;

                //*** Enviar Branch ***//
                // Info
                $display("(BRANCH)\t\tPC: 0x%h\t\tInstruction: %h\toffset: 0x%h\t\tTarget_PC: 0x%h", instruction_counter[9:0]*4, item_BRANCH.full_inst, $signed(item_BRANCH.imm)*2'h2, instruction_counter*4+$signed(item_BRANCH.imm)*2);
                // Transaction
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
                //Caso BEQ: incrementar/decrementar de 1 en 1.
                if ( (item_BRANCH.funct3 == BEQ_FC) ) begin     
                    if ( item_ADDI_1.imm > item_ADDI_2.imm) begin
                        inc_dec_value = 12'hfff;
                    end
                    else if (item_ADDI_1.imm < item_ADDI_2.imm) begin
                        inc_dec_value = 12'h001;
                    end
                end
                // Caso BNE: incrementar/decrementar por cualquier valor excepto por 0
                else if (item_BRANCH.funct3 == BNE_FC) begin
                    inc_dec_value = $urandom_range(1,4095);
                end
                // Caso BLT || BGE: incrementar/decrementar de 2 en 2 para que sea posible ejercitar mejor BGE (caso "mayor que" y caso "igual que")
                else if ((item_BRANCH.funct3 == BLT_FC) || (item_BRANCH.funct3 == BGE_FC)) begin
                    if ( item_ADDI_1.imm > item_ADDI_2.imm) begin //BLT
                        inc_dec_value = 12'hffe;
                    end
                    else if (item_ADDI_1.imm < item_ADDI_2.imm) begin //BGE
                        inc_dec_value = 12'h002;
                    end
                end
                // Caso BLTU || BGEU
                else if ( (item_BRANCH.funct3 == BLTU_FC) || (item_BRANCH.funct3 == BGEU_FC) ) begin
                    if ( {1'b0,item_ADDI_1.imm} > {1'b0,item_ADDI_2.imm} ) begin //BLTU
                        inc_dec_value = 12'hffe;
                    end
                    else if ({1'b0,item_ADDI_1.imm} < {1'b0,item_ADDI_2.imm}) begin //BGEU
                        inc_dec_value = 12'h002;
                    end
                end
                item_ADDI_rupt.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==item_BRANCH.rs1 && rd==item_BRANCH.rs1 && imm==inc_dec_value;};   
                // Info
                $display("(ADDI_rupt)\t\tPC: 0x%h\t\tInstruction: %h\timm:", instruction_counter[9:0]*4, item_ADDI_rupt.full_inst, $signed(item_ADDI_rupt.imm));
                // Transaction
                start_item(item_ADDI_rupt);
                finish_item(item_ADDI_rupt);
                instruction_counter++;

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
                item_JAL.randomize() with {opcode==J_TYPE && imm_jal==0 ;};  
                // Info     
                $display("(JAL)\t\t\tPC: 0x%h\t\tInstruction: %h\tOffset: %d", instruction_counter[9:0]*4, item_JAL.full_inst, $signed(item_JAL.imm_jal)*2);
                // Transaccion JAL
                start_item(item_JAL);
                finish_item(item_JAL); 
                instruction_counter++;
            end
        end
    endtask
endclass