import instructions_data_struc::*;

class gen_sequence_R extends gen_sequence;
    `uvm_object_utils(gen_sequence_R)
    function new(string name="gen_sequence_R");
        super.new(name);
    endfunction

    //rand logic [3:0] num_chunks; //Cuantos grupos de 6 instrucciones se usaran?

    logic [6:0] total_chunks;               //Cuantos grupos de 6 instrucciones hay disponibles
    logic [6:0] puntero_chunk;              //Por cual grupo de 6 instrucciones vamos?
    logic       bndra_ncsto_inc;            //Bandera necesito incremento
    logic [8:0] total_nops;                 //Numero total de nops por branch

    logic [8:0] jumps_sequence [$];         //Secuencia pura
    logic [8:0] jumps_sequence_final [$];   //Secuencia sin los JALR

    logic [8:0] jump_inst_id_list [$];      //Lista con el ID de instrucción de un jump o un ADDI
    logic [8:0] jump_ptr_list [$];          //Queue con el puntero del proximo salto
    logic [8:0] addi_list [$];              //Lista de las filas que deben tener un ADDI
    logic       is_an_addi_mask [$];        //Posiciones en 1 representan un ADDI
    logic       addi_coincidence;           //Bandera para indicar que la fila actual coincide con una que debe tener un ADDI
    logic [8:0] max_num_instructions;       //Constante-Variable para indicar cuantos jumps generaremos

    logic       this_is_an_addi;            //Bandera para indicar que esto es un ADDI que antecede a un jalr.
    logic [8:0] instruction_counter;        //Contador de cual instrucción vamos generando
    logic [10:0] destination_address;        //Valor de salto del jal
    logic [11:0] destination_address_jalr;   //Valor de salto del jal

    virtual task body();
        sequence_item_rv32i_instruction item_0      = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i       
        sequence_item_rv32i_instruction item_addi_jump = sequence_item_rv32i_instruction::type_id::create("item_addi_jump"); // Instruction ADDI to create branch offset.
        jump_aux_vars jmp_aux_vars = jump_aux_vars::type_id::create("jmp_aux_vars"); // Instruction i

        max_num_instructions = 16;
        instruction_counter  = 0;
        destination_address  = 0;
        //--------------------------------------
        // Construcción de la secuencia numérica
        //--------------------------------------
        // Por cada iteración genera un número de secuencia y lo guarda al queue de secuencia
        // Excluye dos números porque el 0 y el max se agregarán por aparte al inicio y al final respectivamente.
        for(int i=0; i < max_num_instructions-2; i=i+1) begin             
            jmp_aux_vars.randomize();
            jumps_sequence.push_back(jmp_aux_vars.num_instruction);
            $display("Numero de instruccion generado es: %d", jmp_aux_vars.num_instruction);
        end
        //--------------------------------------
        // Exclusión de JALR de la secuencia numérica
        //--------------------------------------
        for(int i=0; i < jumps_sequence.size(); i=i+1) begin             
            jmp_aux_vars.randomize();
            if ( (jumps_sequence[i]%2)==0 )begin
                if (jmp_aux_vars.is_jalr==1)begin
                    addi_list.push_back(jumps_sequence[i]-1);
                end
                else begin
                    jumps_sequence_final.push_back(jumps_sequence[i]);
                end
            end
            else jumps_sequence_final.push_back(jumps_sequence[i]);
        end
        //--------------------------------------
        // Agrega los últimos elementos a las secuencias (El jump here)
        //--------------------------------------
        jumps_sequence_final.push_front(0); //Instroduce a donde salta el jump de la instrucción 0
        jumps_sequence_final.push_back(max_num_instructions-1);
        is_an_addi_mask.push_back(0);

        //--------------------------------------
        // Construccion de dos queues (o un array de dos columnas)
        //--------------------------------------
        // La primer columna almacena el ID de instrucción.
        // La segunda columna almacena a dónde se debe saltar.
        //Llega hasta -1 porque el penultimo elemento se sabe a donde va.
        //Para da i-esima instruccion, revise c

        //No revisa el último (max-1) porque no hay siguiente salto en la secuencia.
        for(int i=0; i < max_num_instructions-1; i=i+1) begin
            for(int k=0; k < jumps_sequence_final.size(); k=k+1) begin
                if (i==jumps_sequence_final[k])begin
                    $display("Iterando en la instrucción Numero=%d || Soy el elemento K=%d en la secuencia || Salto hacia fila: %d", i, k, jumps_sequence_final[k+1]);
                    jump_inst_id_list.push_back(i);
                    jump_ptr_list.push_back(jumps_sequence_final[k+1]);
                    break;
                end
            end
        end
        //--------------------------------------
        // Generacion de saltos
        //--------------------------------------
        $display("");
        for(int kqt=0; kqt < jump_inst_id_list.size(); kqt=kqt+1) begin
            this_is_an_addi = 0;            
            for(int k=0; k < addi_list.size(); k=k+1) begin //Revisa si la fila actual debe contener algún ADDI
                if (jump_inst_id_list[kqt]==addi_list[k])begin this_is_an_addi = 1;
                end
            end
            $display("\nInstruccion numero %d salta hacia %d", jump_inst_id_list[kqt], jump_ptr_list[kqt]);

            if (this_is_an_addi)begin
                jmp_aux_vars.randomize(); //Generate a random number to store in the register rs1
                destination_address_jalr = jump_ptr_list[kqt]*4 - jmp_aux_vars.addi_imm;

                $display("Generando un ADDI, soy la fila %d:", jump_inst_id_list[kqt]);
                $display("Generando JALR con salto hacia %d", jump_ptr_list[kqt]); 
                $display("Mi valor inmediato para el ADDI es %h:", jmp_aux_vars.addi_imm);
                $display("Mi PC destino es %h", jump_ptr_list[kqt]*4);
                $display("Mi offset para el JALR es %h:", destination_address_jalr);

                instruction_counter = instruction_counter+2;
                item_0.randomize() with {opcode==I_JALR_TYPE && imm[11:0]==12'd1 ; };
                item_0.print();
                //item_addi_jump.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_0.rd && imm==jmp_aux_vars.addi_imm;};
                //item_addi_jump.print();
            end
            else begin
                destination_address = ((jump_ptr_list[kqt]*4) - (jump_inst_id_list[kqt]*4));
                $display("Generando JAL con salto hacia instrucción número %d, con PC=%d, con PC=%b", jump_ptr_list[kqt], destination_address, destination_address);
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:1]=={9'b0, destination_address} ;};
                item_0.print();
                instruction_counter = instruction_counter+1;
            end
        end

        //TODO: PARA EL JALR Randomice el valor valor de rs1 y luego calcule imm a partir de eso.

        //Imprime la secuencia pura
        $display("La secuencia generada es:");
        for(int i=0; i < max_num_instructions-2; i=i+1) begin             
            $display("%d", jumps_sequence[i]);
        end

        //Imprime la secuencia sin los jalr
        $display("La secuencia final generada es:");
        for(int i=0; i < jumps_sequence_final.size(); i=i+1) begin             
            $display("%d", jumps_sequence_final[i]);
        end        

        //Imprime las filas que almacenaran addis
        $display("Las siguientes filas tendran addis:");
        for(int i=0; i < addi_list.size(); i=i+1) begin             
            $display("%d", addi_list[i]);
        end

        //Imprime la secuencia final junto con la máscara de addi
        $display("Esto son las filas y su identificador de ADDI:");
        for(int i=0; i < jumps_sequence_final.size(); i=i+1) begin             
            $display("%d || %d", jumps_sequence_final[i], is_an_addi_mask[i]);
        end                

       //Fake body to run the simulation
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