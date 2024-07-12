import instructions_data_struc::*;

class gen_sequence_R extends gen_sequence;
    `uvm_object_utils(gen_sequence_R)
    function new(string name="gen_sequence_R");
        super.new(name);
    endfunction


    rand logic [31:0] rs1_beq_val;
    rand logic [31:0] rs2_beq_val;

    rand logic [2:0] tipo_branch; //Para generar uno de los 6 valores disponibles. 
    rand logic [3:0] num_chunks; //Cuantos grupos de 6 instrucciones se usaran?

    logic [6:0] total_chunks;  //Cuantos grupos de 6 instrucciones hay disponibles
    logic [6:0] puntero_chunk; //Por cual grupo de 6 instrucciones vamos?

    constraint valid_branches {6>tipo_branch; 0<=tipo_branch;}
    constraint valid_rng_num_chunks {15>num_chunks; 0<=num_chunks;}

    constraint valid_rs1_beq_val {1000>rs1_beq_val; -1000<=rs1_beq_val;}
    constraint valid_rs2_beq_val {1000>rs2_beq_val; -1000<=rs1_beq_val;}  

    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0"); // Instruction i
        total_chunks = 80; // For defecto vamos a generar unos 80 chunks
        puntero_chunk = 0;
        num_chunks = 0;
        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        randomize(num_chunks);
        $display("Necesito esta cantidad de chunks %d", num_chunks);
//        while(total_chunks!=0)begin
//
//            $display("Mi tipo branch aqui es %h", tipo_branch);
//
//            //Fin de la secuencia
//            $display("Posicion del chunk numero %d", num_chunks);
//            total_chunks = total_chunks-num_chunks;
//        end        

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