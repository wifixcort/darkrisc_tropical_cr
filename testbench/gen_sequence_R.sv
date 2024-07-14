import instructions_data_struc::*;

class gen_sequence_R extends gen_sequence;
    `uvm_object_utils(gen_sequence_R)
    function new(string name="gen_sequence_R");
        super.new(name);
    endfunction

    //rand logic [3:0] num_chunks; //Cuantos grupos de 6 instrucciones se usaran?

    logic [8:0]     jumps_sequence [$];         //Secuencia pura
    logic [8:0]     jumps_sequence_final [$];   //Secuencia sin los JALR

    logic [8:0]     jump_inst_id_list [$];      //Lista con el ID de instrucción de un jump o un ADDI
    logic [8:0]     jump_ptr_list [$];          //Queue con el puntero del proximo salto
    logic [8:0]     addi_list [$];              //Lista de las filas que deben tener un ADDI
    logic [8:0]     max_num_instructions;       //Constante-Variable para indicar cuantos jumps generaremos

    logic           this_is_an_addi;            //Bandera para indicar que esto es un ADDI que antecede a un jalr.
    logic [8:0]     instruction_counter;        //Contador de cual instrucción vamos generando
    logic [10:0]    destination_address;        //Valor de salto del jal
    logic [11:0]    destination_address_jalr;   //Valor de salto del jal

    virtual task body();
        sequence_item_rv32i_instruction item_0          = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i       
        sequence_item_rv32i_instruction item_addi_jump  = sequence_item_rv32i_instruction::type_id::create("item_addi_jump"); // Instruction ADDI to create branch offset.
        sequence_item_rv32i_instruction item_NOP        = sequence_item_rv32i_instruction::type_id::create("item_NOP"); // Instruction NOP
        jump_aux_vars jmp_aux_vars = jump_aux_vars::type_id::create("jmp_aux_vars"); // Instruction i

        item_NOP.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==0 && imm==0;};

        max_num_instructions = 500; //Generemos 500 jumps porque arriba de este valor el compilador a veces se bugea
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
        jumps_sequence_final.push_back(max_num_instructions-1); //Hace que el último ID tenga como siguiente dirección la última dirección, es decir la 499, ahí debe haber un nop

        //Imprime la secuencia sin los jalr
        $display("\n Construccion de secuencia final ========================= \nLa secuencia final generada, con un tamaño=%d, es:", jumps_sequence_final.size());
        for(int i=0; i < jumps_sequence_final.size(); i=i+1) begin             
            $display("%d", jumps_sequence_final[i]);
        end

        //Imprime las filas que almacenaran addis
        $display("\n Construccion de ADDIS ========================= \nLas siguientes filas tendran addis:");
        for(int i=0; i < addi_list.size(); i=i+1) begin             
            $display("%d", addi_list[i]);
        end        

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

                item_0.randomize() with {opcode==I_JALR_TYPE && imm[11:0]==destination_address_jalr; };
                item_addi_jump.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_0.rd && imm==jmp_aux_vars.addi_imm;};

                uvm_report_info(get_full_name(), $sformatf("\n Presentando la siguiente instrucción ADDI al driver. Numero de instruccion/fila %d ", instruction_counter), UVM_LOW);                
                instruction_counter = instruction_counter+1;
                item_addi_jump.print();
                //start_item(item_addi_jump);
                //finish_item(item_addi_jump);

                uvm_report_info(get_full_name(), $sformatf("\n Presentando la siguiente instrucción JALR al driver. Numero de instruccion/fila %d ", instruction_counter), UVM_LOW);
                instruction_counter = instruction_counter+1;
                item_0.print();            
                //start_item(item_0);
                //finish_item(item_0);
            end
            else begin
                destination_address = ((jump_ptr_list[kqt]*4) - (jump_inst_id_list[kqt]*4));
                $display("Generando JAL con salto hacia instrucción número %d, con PC=%d, con PC=%b", jump_ptr_list[kqt], destination_address, destination_address);
                
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:1]=={9'b0, destination_address} ;};
                uvm_report_info(get_full_name(), $sformatf("\n Presentando la siguiente instrucción JAL al driver. Numero de instruccion/fila %d ", instruction_counter), UVM_LOW);
                item_0.print();
                instruction_counter = instruction_counter+1;

                //start_item(item_0);
                //finish_item(item_0); 
            end
        end
       //Fake body to run the simulation
        for(int i=0; i < 13; i=i+1) begin             
            // Cuando llegue la ultima instruccion, meter jal para retroceder
            if ( i == 12 ) begin
                item_0.randomize() with {opcode==J_TYPE && imm_jal[20:10]==11'hfff ;};                
                uvm_report_info(get_full_name(), $sformatf("\n Presentando la siguiente instrucción JALR al driver Numero de instruccion/fila %d ", instruction_counter), UVM_LOW);                
                item_0.print();
                start_item(item_0);
                finish_item(item_0); 
            end

            // NOPs al final para optimizar la secuencia porque el compilador explota
            else begin
                uvm_report_info(get_full_name(), $sformatf("\n Presentando la siguiente instrucción NOP al driver Numero de instruccion/fila %d ", instruction_counter), UVM_LOW);                
                instruction_counter = instruction_counter+1;
                item_NOP.print();
                start_item(item_NOP);
                finish_item(item_NOP);
            end
        end        
    endtask
endclass