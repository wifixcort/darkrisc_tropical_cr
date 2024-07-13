import instructions_data_struc::*;

class gen_sequence_R extends gen_sequence;
    `uvm_object_utils(gen_sequence_R)
    function new(string name="gen_sequence_R");
        super.new(name);
    endfunction

    //rand logic [3:0] num_chunks; //Cuantos grupos de 6 instrucciones se usaran?

    logic [6:0] total_chunks;  //Cuantos grupos de 6 instrucciones hay disponibles
    logic [6:0] puntero_chunk; //Por cual grupo de 6 instrucciones vamos?
    logic       bndra_ncsto_inc; //Bandera necesito incremento
    logic [8:0] total_nops;  //Numero total de nops por branch

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        branch_aux_vars aux_vars = branch_aux_vars::type_id::create("aux_vars"); // Instruction i
        total_chunks = 80; // For defecto vamos a generar unos 80 chunks
        puntero_chunk = 85;
        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente) 
      
        while ( (total_chunks>15)&&(puntero_chunk>0) )begin
            //Aqui genera variables que son generales a todos los tipos de branch
            aux_vars.randomize(); //Genera el tipo de branch y cuantos chunks
            total_nops = (aux_vars.num_chunks*6)-5;
            $display("Necesito esta cantidad de chunks para este branch%d", aux_vars.num_chunks);
            $display("Para este branch necesito esta cantidad de nops %d", total_nops);
            $display("Chunks restantes: %d", total_chunks);
            //Calcular el inmediat del jal.
            //Calcular el inmediat del branch.
            //Usar los punteros de registros rs1 y rs2 de forma que tenga sentido.
            //Caso BEQ
            if (1)begin //Esto debería ser aux_vars.tipo_branch == loquesea.
                $display("Vamos a generar un BEQ");
                //Creadores de estado de condicion
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==0;};
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==1 && rd==0;};
                //Branch
                //item_0.randomize() crear branch
                //Cuerpo de nops
                for(int k=0; k < total_nops; k=k+1) begin
                    $display("Generando nop numero %d", k);
                    item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==1 && rd==0;};
                end
                //Ruptura ADD-Condicionarlo, si rs1_val es mayor que rs2 de acuerdo con el algoritmo
                //If rs1 mayor que rs2 usar decremento.
                //If rs2 mayor que rs2 usar incremento.
                item_0.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==1 && rd==0;};
                //JALR o JAL de regreso
                //  item 0
            end

            //Fin de la secuencia
            total_chunks = total_chunks-aux_vars.num_chunks;
            puntero_chunk = puntero_chunk - 1;
        end


        for(int i=0; i < 10; i=i+1) begin             
            // Cuando llegue la ultima instruccion, meter jal para retroceder
            if ( i == 9 ) begin
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:10]==11'hfff ;};       
                $display("\n(for JAL)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm_jal);
                // Transaccion JAL
                start_item(item_0);
                finish_item(item_0); 
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