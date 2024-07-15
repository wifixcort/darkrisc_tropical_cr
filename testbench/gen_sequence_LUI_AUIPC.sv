import instructions_data_struc::*;

class gen_sequence_LUI_AUIPC extends gen_sequence;
    `uvm_object_utils(gen_sequence_LUI_AUIPC)
    function new(string name="gen_sequence_LUI_AUIPC");
        super.new(name);
    endfunction

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        logic [4:0] init_reg = 5'b00001;

        for(int i=0; i < 2**`MLEN/(4*2); i=i+1) begin 

            // Metiendo LUIs y AUIPCs
            if ( i <= 2**`MLEN/(4*2) - 4 ) begin
                item_0.randomize() with {opcode inside {LUI_TYPE, AUIPC_TYPE};}; 
                // Transaccion
                start_item(item_0);
                finish_item(item_0);

                if(item_0.opcode==AUIPC_TYPE)
                    $display("\n(AUIPC)\t\tInstruct #%d\t%h\timm_U: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_U); 
                else if (item_0.opcode==LUI_TYPE)
                    $display("\n(LUI)\t\tInstruct #%d\t%h\timm_U: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_U); 

            end

            //  Ultima instruccion, que retroceda hasta el inicio
            else begin
                 item_0.randomize() with {opcode==J_TYPE && imm_jal==0 ;};       
                $display("\n(for JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
                // Transaccion JAL
                start_item(item_0);
                finish_item(item_0); 
            end
        end

    endtask
endclass