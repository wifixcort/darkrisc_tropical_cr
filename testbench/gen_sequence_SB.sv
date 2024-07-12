class gen_sequence_SB extends gen_sequence;
    `uvm_object_utils(gen_sequence_SB)
    function new(string name="gen_sequence_SB");
        super.new(name);
    endfunction

    logic [11:0] a, b;  //valores para controlar el rs1 y rs2 de los branches
    
    virtual task body();
        sequence_item_rv32i_instruction item_0 = sequence_item_rv32i_instruction::type_id::create("item_0");
        sequence_item_rv32i_instruction item_1 = sequence_item_rv32i_instruction::type_id::create("item_1");
        sequence_item_rv32i_instruction item_2 = sequence_item_rv32i_instruction::type_id::create("item_2"); 
        //********* Inicio de generacion de secuencia (Programa para arquitectura rv32i) ***********
        //`uvm_info("SEQUENCE", $sformatf("Generate instructions:"), UVM_MEDIUM)
        // Para la cantidad de instrucciones correspondiente (512 actualmente)
        for(int i=0; i < 2**`MLEN/(4*2); i=i+1) begin 

            if ( i <= 2**`MLEN/(4*2) - 1 - 5) begin   
                
                item_0.randomize() with {opcode==S_B_TYPE && rs1!=rs2;}; //S_B_TYPE
                
                branch_solve(0, item_0.funct3, a, b);
                
                item_1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_0.rs1 && imm==a;};
                item_2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==item_0.rs2 && imm==b;};
                $display("A = %b \t B = %b", a, b);

                // Transacciones
                start_item(item_1);
                finish_item(item_1);
                //
                start_item(item_2);
                finish_item(item_2);
                //
                start_item(item_0);
                finish_item(item_0);
                
                $display("\n(force ADDI)\tInstruct #%d\t\tnew instruct:%h", i[15:0], item_1.full_inst); 
                $display("(force ADDI)\tInstruct #%d\t\tnew instruct:%h", i[15:0]+1'h1, item_2.full_inst);
                $display("(S_B-TYPE)\tInstruct #%d\t\tnew instruct:%h", i[15:0]+2'h2, item_0.full_inst);

                i = i+2; //compensar iterador por haber enviado mas de una instruccion
            end


            //  Ultima instruccion, que retroceda hasta el inicio
            else begin
                item_0.randomize() with {opcode==I_JALR_TYPE && rs1==0 && imm==12'h000 ;};
                $display("\n(for JALR)\t\tInstruct #%d\t\tinstruct: %h\tOffset: %b   (bin)", i[15:0], item_0.full_inst, item_0.imm);
                // Transaccion JALR
                start_item(item_0);
                finish_item(item_0);
            end
        end
    endtask

    // Para poder manipular si un branch se toma o no
    // Entradas: take (si el salto se toma o no), funct3 (instruccion branch)
    // Salidas: valores a meter en los registros que compara el branch.   rs1<-a  rs2<-b
    // Con esta función no se pueden ejercitar el caso de BGE donde ambos registros sean iguales. todo: generarlo desde el task run
    function branch_solve (input bit take, input logic [2:0] funct3, output logic [11:0] a, output logic [11:0] b);
        logic [11:0] temp1, temp2;
        temp1 = $urandom_range(0, 4095);
        temp2 = $urandom_range(0, 4095);
        if (temp1==temp2) temp2=temp2+1'b1; // Evitar que temp1 y temp2 sean iguales

        if(funct3==BEQ_FC) begin   
            //$display("temp1 = %b", temp1);
            if(take) begin
                a = temp1;
                b = temp1;  
            end else begin
                a = temp1;
                b = temp1 + 1'b1;
            end
        
        end else if(funct3==BNE_FC) begin
            if(take) begin
                a = temp1;
                b = temp1 + 1'b1;  
            end else begin
                a = temp1;
                b = temp1;
            end

        end else if( funct3==BLT_FC ) begin
            if(take) begin
                a = temp1;
                b = temp1 + 1'b1;
            end else begin
                a = temp1;
                b = temp1;
            end

        end 
        // else if(funct3==BGE_FC) begin
        //     if(take) begin
        //         a = temp1;
        //         b = temp1 - 1'b1;
        //     end else begin
        //         a = temp1;
        //         b = temp1 + 1'b1;
        //     end

        // end else if( funct3==BLTU_FC ) begin
        //     if(take) begin
        //         a = 12'b0f0;
        //         b = 12'b0f0;
        //     end else begin
        //         a = 12'b0f0;
        //         b = 12'b0f0;
        //     end

        // end 
        // else if(  funct3==BGEU_FC ) begin
        //     if(take) begin
                
        //     end else begin
                
        //     end
        // end 

    endfunction
endclass


        // end else if( funct3==BLT_FC ) begin
        //     if(take) begin
        //         if (temp1 < temp2) begin a=temp1; b=temp2; end else begin a=temp2; b=temp1; end
        //     end else begin
        //         if (temp1 < temp2) begin a=temp2; b=temp1; end else begin a=temp2; b=temp1; end
        //     end

        // end else if(funct3==BGE_FC) begin
        //     if(take) begin
        //         if (temp1 > temp2) begin a=temp1; b=temp2; end else begin a=temp2; b=temp1; end
        //     end else begin
        //         if (temp1 > temp2) begin a=temp2; b=temp1; end else begin a=temp2; b=temp1; end
        //     end

        // end else if( funct3==BLTU_FC ) begin
        //     if(take) begin
        //         if ($signed(temp1) < $signed(temp2)) begin a=temp1; b=temp2; end else begin a=temp2; b=temp1; end
        //     end else begin
        //         if ($signed(temp1) < $signed(temp2)) begin a=temp2; b=temp1; end else begin a=temp2; b=temp1; end
        //     end

        // end else if(  funct3==BGEU_FC ) begin
        //     if(take) begin
        //         if ($signed(temp1) > $signed(temp2)) begin a=temp1; b=temp2; end else begin a=temp2; b=temp1; end
        //     end else begin
        //         if ($signed(temp1) > $signed(temp2)) begin a=temp2; b=temp1; end else begin a=temp2; b=temp1; end
        //     end
        // end 