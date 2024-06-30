import instructions_data_struc::*;

class gen_sequence extends uvm_sequence;
    `uvm_object_utils(gen_sequence)
    function new(string name="gen_sequence");
        super.new(name);
    endfunction

    // Variables para generacion de direcciones
    logic [4:0]	    reg_addr;
    logic [11:0]    effective_addr = 12'h000;  //[2**`MLEN/2-1:0]

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_1"); // Instruction i-1
        sequence_item_rv32i_instruction item_2 = sequence_item_rv32i_instruction::type_id::create("item_2"); // Instruction i-2

        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=0;i!=2**`MLEN/(4*2);i=i+1) begin 
            
            //*** Seteando registros (instrucciones 0-30)
            if (i <= 30) begin
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==i;};
                //Transaccion
                start_item(item_0);
                finish_item(item_0);  
                //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	        //item_0.print();   
            end
                                                                                                       //hasta 511 hasta que no se agregue lo del loop al final
            //*** Insertando instrucciones teniendo en cuenta las direcciones base en caso de LOAD/STORE (Instrucciones 31-509)
            //    Para esto actualmente se están insertando un ADDI y un SLLI (debido a la arquitectura de las instrucciones y del tamaño de la memoria)
            //    Se puede hacer mas escalable para tamaños de memoria mas grandes si se implementan instrucciones LUI
            else if (i < 2**`MLEN/(4*2) ) begin //-2
                item_0.randomize();
                
                // Si la instruccion item_00 es un STORE o un LOAD
                if ( (item_0.opcode==S_TYPE) || (item_0.opcode==I_L_TYPE) ) begin
                    reg_addr = item_0.rs1 ; // reg where store/load going to search base adrress

                    // loop if effective_addr out of range
                    //todo: cambiar a while normal

                    while ((effective_addr < 2**`MLEN/2) || (effective_addr >= 2**`MLEN) ) begin        
                        //Generacion de ADDI con valor positivo y > 2048 si se le hace un shift l, el valor queda debidamente alineado segun la instruccion STORE
                        //Hace falta el shift left porque si no el ADDI detecta el imm como un numero negativo (es suma con signo)
                        if (  (item_0.funct3==SW_FC) || (item_2.funct3==LW_FC) )                                                                                        
                            item_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm[11:10]==2'b01 && imm[1:0]==2'b0;}; 
                        else
                            item_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm[11:10]==2'b01;}; // half y byte quedarian con un 0 en el LSB siempre, el offset se encarga de ejercitar los demas casos de byte
                        effective_addr = (item_2.imm << 1) + item_0.imm ; // Effective Address = base + offset
                    end
                    effective_addr = 12'h000;
                
                    
                    //do begin
                    //end while(  && );  //ACOTADORES effective_address

                    // Generacion de SLLI para tener el valor base deseado
                    item_1.randomize() with {opcode==I_TYPE && funct3==SLLI_FC && rd==reg_addr && rs1==reg_addr && imm[4:0] == 5'h001;};
                    
                    // Transacciones
                    start_item(item_2);
                    finish_item(item_2);
                    //
                    start_item(item_1);
                    finish_item(item_1);
                    //
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
                    $display("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]+2'h1, item_1.full_inst);
                    if (item_0.opcode==S_TYPE)
                        $display("(for STORE)\t\tInstruct #%d\t\tinstruct: %h\tIADDR: %h", i[15:0]+2'h2, item_0.full_inst, i*3'h4);
                    else
                        $display("(for LOAD)\t\tInstruct #%d\t\tinstruct: %h", i[15:0]+2'h2, item_0.full_inst);
                    $display("Effective Address: %d   (decimal)", (item_2.imm << 1) + item_0.imm); // Efective address = base address + offset
                    // `uvm_info("opt_addr()", $sformatf("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]), UVM_LOW)
                    // `uvm_info("opt_addr()", $sformatf("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]), UVM_LOW)
                    // `uvm_info("opt_addr()", $sformatf("(for STORE)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]), UVM_LOW)

                    //Compensar el iterador por las 2 instrucciones extra enviadas
                    i = i+2;
                end

                // Si la instruccion item_0 es REGISTER o IMMEDIATE
                else begin
                    //Transaccion normal
                    start_item(item_0);
                    finish_item(item_0);
                    //`uvm_info("SEQUENCER", $sformatf("Generate instruction #%d: ",i[15:0]), UVM_MEDIUM)
    	            //item_0.print();
                end
            end

            //*** Insertando instrucciones para crear loop al final del programa (Instrucciones 510-511)
            //todo: el item tiene que soportar AUIPC y JALR para poder hacerlo bien mediante transacciones de item
            //else
        end
    endtask
endclass
