import instructions_data_struc::*;

class gen_sequence_STORE extends gen_sequence;
    `uvm_object_utils(gen_sequence_STORE)
    function new(string name="gen_sequence_STORE");
        super.new(name);
    endfunction

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_1"); // Instruction i - 1
        sequence_item_rv32i_instruction item_2 = sequence_item_rv32i_instruction::type_id::create("item_1"); // Instruction i - 2

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=0; i < 2**`MLEN/(4*2); i=i+1) begin 

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

            // Metiendo Store con su respectivo control de direcciones
            else if ( i <= 2**`MLEN/(4*2) - 4 ) begin
                item_0.randomize() with {opcode==S_TYPE;}; 
                reg_base = item_0.rs1 ; // reg where store/load going to search base adrress

                // loop if effective_addr out of range
                effective_addr = 12'h000;
                while ((effective_addr < 2**`MLEN/2) || (effective_addr >= 2**`MLEN) ) begin        
                    //Hace falta el shift left porque si no el ADDI detecta el imm como un numero negativo (es suma con signo)
                    if (  item_2.funct3==LW_FC )                                                                                        
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
                //
                start_item(item_1);
                finish_item(item_1);
                //
                start_item(item_0);
                finish_item(item_0);

                //INFO
                $display("\n(force ADDI)\tInstruct  #%d:\t\t%h", i[15:0], item_2.full_inst);
                $display("(force SLLI)\tInstruct  #%d:\t\t%h", i[15:0]+2'h1, item_1.full_inst);
                $display("(for STORE)\tInstruct  #%d:\t\t%h\t\tEffective Address: %d   (decimal)", i[15:0]+2'h2, item_0.full_inst, effective_addr);

                // `uvm_info("opt_addr()", $sformatf("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]), UVM_LOW)
                // `uvm_info("opt_addr()", $sformatf("(force SLLI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]), UVM_LOW)
                // `uvm_info("opt_addr()", $sformatf("(for STORE)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]), UVM_LOW)
                //Compensar el iterador por las 2 instrucciones extra enviadas

                i = i+2;
            end

            //  Ultima instruccion, Jump here
            else begin
                 item_0.randomize() with {opcode==J_TYPE && imm_jal==0;};       
                $display("\n(for JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
                // Transaccion JAL
                start_item(item_0);
                finish_item(item_0); 
            end
        end

    endtask
endclass