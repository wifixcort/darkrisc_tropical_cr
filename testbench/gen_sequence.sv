import instructions_data_struc::*;

class gen_sequence extends uvm_sequence;
    `uvm_object_utils(gen_sequence)
    function new(string name="gen_sequence");
        super.new(name);
    endfunction

    logic [31:0]    MEM [0:2**`MLEN/4-1];  // Puede que no se use porque ahora se envian a como se van generando

    // Variables para generacion de direcciones
    logic [4:0]	    reg_addr;
    logic [31:0]    effective_addr = 32'h00000000;

    logic shared_data;

    int min_imm;
    int max_imm;

    //rand logic [31:0]   random_try;

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

                    reg_addr = item_0.rs1 ; 

                    // Generate imm random value
                    imm_rand[11:0] inside {[512:1024]};

                    // Calculate the minimum and maximum values for rs1_val such that the sum is within [512, 1024]
                    min_imm = (512 - rs1_val > 0) ? 512 - rs1_val : 0;
                    max_imm = (1024 - rs1_val > 4095) ? 4095 : 1024 - rs1_val;

                    item_1.randomize() with {
                        opcode==I_TYPE &&
                        funct3==ADDI_FC && 
                        rd==reg_addr && // rs1 pointer, base for L-I MEM-address
                        rs1==5'h00 && 
                        imm[11:0]==imm_rand;
                    };

                    // Transacciones
                    start_item(item_1);
                    finish_item(item_1);
                    //
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