import instructions_data_struc::*;

class gen_sequence extends uvm_sequence;
    `uvm_object_utils(gen_sequence)
    function new(string name="gen_sequence");
        super.new(name);
    endfunction

    // Variables Internas para generacion de direcciones Validas 
    logic signed [31:0] min_rs1;
    logic signed [31:0] max_rs1;

    //logic signed [31:0] imm_offset;
    logic signed [11:0] imm_offset_signed;
    logic signed [31:0] imm_t;

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_1"); // Instruction i-1

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        `uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)

        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=0;i!=2**`MLEN/(4*2);i=i+1) begin   

            //*** Seteando registros (instrucciones 0-30)
            if (i <= 30) begin
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==i;};
                //Transaccion
                start_item(item_0);
                finish_item(item_0);  
                `uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	        //item_0.print();   
            
            //*** Generando Instrucciones (instrucciones 31-511)
            end else if (i < 2**`MLEN/(4*2) ) begin 
                
                item_0.randomize(); // Randomize Instruction
                
                // Si la instruccion item_0 es un STORE o un LOAD
                if ( (item_0.opcode==S_TYPE) || (item_0.opcode==I_L_TYPE) ) begin
                    
                    imm_offset_signed = item_0.imm; // Now is a signed value

                    //imm_offset_signed = {{21{item_0.imm[11]}}, item_0.imm};

                    `uvm_info("IMM_VAL_OFFSET_L/S", $sformatf("#%d: ", imm_offset_signed), UVM_MEDIUM)
                    
                    // Calculate the minimum and maximum values for rs1_val such that the sum is within [512, 1024]
                    min_rs1 = (512 - imm_offset_signed > 0) ? 512 - imm_offset_signed : 0;
                    max_rs1 = (1024 - imm_offset_signed > 4095) ? 4095 : 1024 - imm_offset_signed;

                    `uvm_info("min_rs1", $sformatf("#%d: ", min_rs1), UVM_MEDIUM)
                    `uvm_info("max_rs1", $sformatf("#%d: ", max_rs1), UVM_MEDIUM)

                    imm_t = $urandom_range(min_rs1, max_rs1);

                    `uvm_info("RS1_VB_L/S", $sformatf("#%d: ", imm_t), UVM_MEDIUM)

                    // ADDI
                    item_1.randomize() with {
                        opcode==I_TYPE &&
                        funct3==ADDI_FC && 
                        rd==item_0.rs1 && 
                        rs1==5'h00 &&   // rs1 pointer = 0, rs1_v = 0
                        imm == imm_t;
                    };

                    `uvm_info("RS1_V_L/S", $sformatf("#%d: ", item_1.imm), UVM_MEDIUM)

                    `uvm_info("SUMA_L/S", $sformatf("#%d: ", item_1.imm + imm_offset_signed), UVM_MEDIUM)

                    // Addi Transaction
                    start_item(item_1);
                    finish_item(item_1);
                    // Load/Store Transaction
                    start_item(item_0);
                    finish_item(item_0);
                    
                    //INFO prints
                    `uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0] + 2'h1), UVM_MEDIUM)
    	            //item_1.print();
                    `uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0] + 2'h2), UVM_MEDIUM)
    	            //item_0.print();

                    //Compensar el iterador por la instruccion extra enviada
                    i = i+1;
                end

                // Si la instruccion item_0 es REGISTER o IMMEDIATE
                else begin
                    //Transaccion normal
                    start_item(item_0);
                    finish_item(item_0);
                    `uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	            item_0.print();
                end
            end

            //*** Insertando instrucciones para crear loop al final del programa (Instrucciones 510-511)
            //todo: el item tiene que soportar AUIPC y JALR para poder hacerlo bien mediante transacciones de item
            //else
        end
    endtask
endclass

//This is a very good reference for this component: https://verificationguide.com/uvm/uvm-sequence/