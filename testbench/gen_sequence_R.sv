import instructions_data_struc::*;

class gen_sequence_R extends gen_sequence;
    `uvm_object_utils(gen_sequence_R)
    function new(string name="gen_sequence_R");
        super.new(name);
    endfunction

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        logic [4:0] init_reg = 5'b00001;

        for(int i=1; i <= 2**`MLEN/(4*2); i=i+1) begin 

            //*** Seteando registros (instrucciones 0-60)
            if (i <= 30) begin
                //item_1.randomize() with {opcode==LUI_TYPE && rd==init_reg;};
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==init_reg && rd==init_reg;};
                //  todo: meter LUI para setear parte alta de registros y no solo primeros 12 bits
                //Transaccion
                // start_item(item_1);
                // finish_item(item_1);
                //
                start_item(item_0);
                finish_item(item_0);
                //
                $display("\n(LUI for set regs)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_1.full_inst);  
                //$display("\n(ADDI for set regs)\tInstruct #%d\t\tInstruction :%h\t", i[15:0] + 1'b1, item_0.full_inst); 

                //i = i+1; // compensar por instruccion extra
                init_reg = init_reg + 1; // para setear siguiente registro
            end
            
            // Cuando llegue la ultima instruccion, meter jal para retroceder
            else if ( i == 2**`MLEN/(4*2) - 1 ) begin
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:10]==11'hfff ;};       
                // Transaccion JALR
                start_item(item_0);
                finish_item(item_0);
                $display("\n(for JALR)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
            end

            // Instrucciones R
            else begin
                item_0.randomize() with {opcode==R_TYPE;};

                start_item(item_0);
                finish_item(item_0);

                $display("\n(R type)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst); 

            end
        end
    endtask
endclass