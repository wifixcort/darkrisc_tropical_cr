import instructions_data_struc::*;

class gen_sequence extends uvm_sequence;
    `uvm_object_utils(gen_sequence)
    function new(string name="gen_sequence");
        super.new(name);
    endfunction

    // Variables para generacion de direcciones
    logic [4:0]	    reg_base;
    logic [11:0]    effective_addr = 12'h000;  
    logic [31:0]    target_addr    = 32'h00000000;  //for JALR
    logic [31:0]    branch_addr  = 32'h00000000;  //for Branches
    // Variables para generacion de branches
    logic [8:0] total_nops;             // Numero total de nops por branch
    logic [31:0] addi2_imm_val;         // Valor inmediato para ADDI_2
    logic signed [20:1] offset_jump;    // Para calcular el offset negativo 
    logic [11:0] inc_dec_value;         // Valor inmediato de incremento/decremento para ADDI_rupt

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_1"); // Instruction i-1
        sequence_item_rv32i_instruction item_2 = sequence_item_rv32i_instruction::type_id::create("item_2"); // Instruction i-2
        // Branch structures items
        sequence_item_rv32i_instruction item_BRANCH      = sequence_item_rv32i_instruction::type_id::create("item_BRANCH"); // Instruction Branch
        sequence_item_rv32i_instruction item_ADDI_1      = sequence_item_rv32i_instruction::type_id::create("item_ADDI_1"); // Instruction ADDI for set item_BRANCH.rs1
        sequence_item_rv32i_instruction item_ADDI_2      = sequence_item_rv32i_instruction::type_id::create("item_ADDI_2"); // Instruction ADDI for set item_BRANCH.rs2
        sequence_item_rv32i_instruction item_ADDI_rupt   = sequence_item_rv32i_instruction::type_id::create("item_ADDI_rupt"); // Instruction ADDI for broke the branch condition
        sequence_item_rv32i_instruction item_JAL         = sequence_item_rv32i_instruction::type_id::create("item_JAL"); // Instruction JAL for generate a loop
        sequence_item_rv32i_instruction item_inside_loop = sequence_item_rv32i_instruction::type_id::create("item_inside_loop"); // Instruction NOP

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=1;i<=2**`MLEN/(4*2);i=i+1) begin 
            
            //*** Seteando registros (instrucciones 1-62)
            if (i <= 62) begin
                // LUI
                item_0.randomize() with {opcode==LUI_TYPE && rd==(i+1)/2;};
                //Transaccion
                start_item(item_0);
                finish_item(item_0);
                $display("\n(LUI for set regs)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst); 
                // ADDI
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==(i+1)/2 && rd==(i+1)/2;};
                //Transaccion
                start_item(item_0);
                finish_item(item_0);
                $display("\n(ADDI for set regs)\tInstruct #%d\t\tInstruction :%h\t", i[15:0]+1'b1, item_0.full_inst); 
                //
                i++; // compensar por instruccion extra
            end
                                                                                                       
            //*** Inserting all instruction types
            else if (i < 2**`MLEN/(4*2) - 20) begin // -n para dejar una brecha y evitar rebase
                item_0.randomize(); //with {opcode inside {R_TYPE, I_TYPE, S_TYPE, I_L_TYPE, S_B_TYPE};}
                
                // Si la instruccion item_00 es un STORE o un LOAD
                if ( (item_0.opcode==S_TYPE) || (item_0.opcode==I_L_TYPE) ) begin
                    reg_base = item_0.rs1 ; // reg where store/load going to search base adrress
                    // loop if effective_addr out of range
                    effective_addr = 12'h000;
                    while ((effective_addr < 2**`MLEN/2) || (effective_addr >= 2**`MLEN) ) begin        
                        //Generacion de ADDI con valor positivo y > 2048 si se le hace un shift l, el valor queda debidamente alineado segun la instruccion STORE
                        //Hace falta el shift left porque si no el ADDI detecta el imm como un numero negativo (es suma con signo)
                        if (  (item_0.funct3==SW_FC) || (item_2.funct3==LW_FC) )                                                                                        
                            item_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_base && rs1==5'h00 && imm[11:10]==2'b01 && imm[0]==1'b0;}; 
                        else
                            item_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_base && rs1==5'h00 && imm[11:10]==2'b01;}; // half y byte quedarian con un 0 en el LSB siempre, el offset se encarga de ejercitar los demas casos de byte
                        effective_addr = (item_2.imm << 1) + item_0.imm ; // Effective Address = base + offset
                    end  
                    // Generacion de SLLI para tener el valor base deseado
                    item_1.randomize() with {opcode==I_TYPE && funct3==SLLI_FC && rd==reg_base && rs1==reg_base && imm[4:0] == 5'h001;};      
                    // Transacciones
                    start_item(item_2);
                    finish_item(item_2);
                    start_item(item_1);
                    finish_item(item_1);
                    start_item(item_0);
                    finish_item(item_0);
                    //INFO prints
                    //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	            //item_2.print();
                    //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0] + 2'h1), UVM_MEDIUM)
    	            //item_1.print();
                    //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0] + 2'h2), UVM_MEDIUM)
    	            //item_0.print();
                    // todo: quitar displays
                    $display("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0], item_2.full_inst);
                    $display("(force SLLI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]+2'h1, item_1.full_inst);
                    if (item_0.opcode==S_TYPE)
                        $display("(for STORE)\t\tInstruct #%d\t\tinstruct: %h\tIADDR: %h", i[15:0]+2'h2, item_0.full_inst, i*3'h4);
                    else
                        $display("(for LOAD)\t\tInstruct #%d\t\tinstruct: %h", i[15:0]+2'h2, item_0.full_inst);
                    $display("Effective Address: %d   (decimal)", (item_2.imm << 1) + item_0.imm); // Efective address = base address + offset
                    // `uvm_info("opt_addr()", $sformatf("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]), UVM_LOW)
                    // `uvm_info("opt_addr()", $sformatf("(force SLLI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]), UVM_LOW)
                    // `uvm_info("opt_addr()", $sformatf("(for STORE)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]), UVM_LOW)
                    //Compensar el iterador por las 2 instrucciones extra enviadas
                    i = i+2;
                end

                //
                else if (item_0.opcode == S_B_TYPE) begin
                    //*** Generacion de instrucciones BRANCH y JAL con su respectivo offset ***//
                    total_nops   = $urandom_range(3,10);   
                    offset_jump = -(1+total_nops+1)*(4/2);
                    item_BRANCH.randomize() with {opcode==S_B_TYPE && rs1!=0 && rs2!=0 && rs1!=rs2 && imm==(total_nops+1+1+1)*(4/2);};  //offset = nops + addi_rupt + jal + 1 
                    item_JAL.randomize() with {opcode==J_TYPE && rs1==0 && rd==0 && imm_jal==offset_jump;};

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
                    $display("\n(ADDI_1)\t #%d\t\tPC: 0x%h\t\tInstruction: %h\timm: 0x%h",i[9:0], i[9:0]*4, item_ADDI_1.full_inst, item_ADDI_1.imm);
                    $display("(ADDI_2)\t #%d\t\tPC: 0x%h\t\tInstruction: %h\timm: 0x%h",i[9:0]+1'b1, (i[9:0]+1'b1)*4, item_ADDI_2.full_inst, item_ADDI_2.imm);
                    // Transactions
                    start_item(item_ADDI_1);
                    finish_item(item_ADDI_1);
                    start_item(item_ADDI_2);
                    finish_item(item_ADDI_2);
                    i+=2;

                    //*** Enviar Branch ***//
                    // Info
                    $display("(BRANCH)\t #%d\t\tPC: 0x%h\t\tInstruction: %h\toffset: 0x%h\t\tTarget_PC: 0x%h", i[9:0], i[9:0]*4, item_BRANCH.full_inst, $signed(item_BRANCH.imm)*2'h2, i*4+$signed(item_BRANCH.imm)*2);
                    // Transaction
                    start_item(item_BRANCH);
                    finish_item(item_BRANCH);
                    i++;

                    //*** Enviar Instrucciones dentro del loop ***//    
                    for(int k=0; k < total_nops; k=k+1) begin
                        item_inside_loop.randomize() with {opcode inside {R_TYPE, I_TYPE, LUI_TYPE, AUIPC_TYPE} && rd!=item_BRANCH.rs1 && rd!=item_BRANCH.rs2;};
                        // Info
                        $display("#%d\t\tPC: 0x%h\t\tInstruction: %h", i[9:0], i[9:0]*4, item_inside_loop.full_inst);
                        // Transaction
                        start_item(item_inside_loop);
                        finish_item(item_inside_loop);
                        i++;         
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
                    $display("(ADDI_rupt)\t #%d\t\tPC: 0x%h\t\tInstruction: %h\timm:", i[9:0], i[9:0]*4, item_ADDI_rupt.full_inst, $signed(item_ADDI_rupt.imm));
                    // Transaction
                    start_item(item_ADDI_rupt);
                    finish_item(item_ADDI_rupt);
                    i++;

                    //*** Enviar JAL para generar loop ***//
                    // Info
                    $display("(JAL)\t\t #%d\t\tPC: 0x%h\t\tInstruction: %h\toffset: %d\tTarget_PC: 0x%h\n", i[9:0], i[9:0]*4, item_JAL.full_inst, $signed(item_JAL.imm_jal*2'h2), i*4+$signed(item_JAL.imm_jal)*2 );
                    // Transaction
                    start_item(item_JAL);
                    finish_item(item_JAL);
                    //i++;  
                end

                else if (item_0.opcode == J_TYPE) begin
                    item_0.randomize() with {opcode==J_TYPE && imm_jal==2;};
                    start_item(item_0);
                    finish_item(item_0);
                    $display("\n(JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
                end

                else if (item_0.opcode == I_JALR_TYPE) begin
                    item_1.randomize() with {opcode==AUIPC_TYPE && rd!=0 && imm_U==0;};
                    item_0.randomize() with {opcode==I_JALR_TYPE && rs1==item_1.rd && imm==8;};
                    start_item(item_1);
                    finish_item(item_1);
                    start_item(item_0);
                    finish_item(item_0);
                    $display("\n(AUIPC)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], item_1.full_inst);
                    $display("\n(JALR)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0]+1'b1, item_0.full_inst, item_0.imm);
                    i++;
                end

                // Si la instruccion item_0 es REGISTER, IMMEDIATE, LUI o AUIPC
                else begin
                    //Transaccion normal
                    start_item(item_0);
                    finish_item(item_0);
                    $display("\n\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst);
                    //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	            //item_0.print();
                end
            end


            // Cuando llegue la ultima instruccion, retroceder minimo unas  posiciones ( instrucciones)
            else if ( i == 2**`MLEN/(4*2) - 2 ) begin
                item_0.randomize() with {opcode==J_TYPE && imm_jal==0 ;};
                $display("\n(JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
                // Transaccion JALR
                start_item(item_0);
                finish_item(item_0);

                    
            end

            // En cualquier otro caso. ->Casos anteriores a jump final
            else begin
                item_0.randomize() with {opcode inside {R_TYPE, I_TYPE, LUI_TYPE, AUIPC_TYPE};};
                //Transaccion
                start_item(item_0);
                finish_item(item_0); 
                //
                $display("\n(R/I)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst); 
            end

            //todo: soportar lui para escalar generacion de direcciones y preprocesamiento de registros para load/store, branches, jumps 
            //else
        end
    endtask
endclass