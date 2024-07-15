import instructions_data_struc::*;

class gen_sequence_I extends gen_sequence;
    `uvm_object_utils(gen_sequence_I)
    function new(string name="gen_sequence_I");
        super.new(name);
    endfunction

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=1; i <= 2**`MLEN/(4*2); i=i+1) begin 

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
            
            // Cuando llegue la ultima instruccion, meter jal para retroceder
            else if ( i == 2**`MLEN/(4*2) ) begin
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:10]==11'hfff ;};       
                // Transaccion JALR
                start_item(item_0);
                finish_item(item_0);
                $display("\n(for JALR)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
            end

            // Instrucciones I
            else begin
                item_0.randomize() with {opcode==I_TYPE;};

                start_item(item_0);
                finish_item(item_0);

                $display("\n(I type)\tInstruct #%d\t\tInstruction :%h\t", i[15:0], item_0.full_inst); 

            end
        end
    endtask
endclass