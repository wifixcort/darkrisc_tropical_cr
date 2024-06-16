`include "instructions_data_struc.sv"
`include "scoreboard.sv"

`ifdef SBTEST
  module scoreboard_tb;

    // Scoreboard instance
    scoreboard sb;

    // Initial block for generating test stimuli
    initial begin

      // For VCD    
      //$dumpfile("dump.vcd");
      //$dumpvars;
      sb = new();
      sb.ref_model.REGS[5'b10000] = 32'hA;
      sb.ref_model.REGS[5'b00100] = 32'hA;
      // Generate some test instructions
      $display("Pushing test instructions to scoreboard...");
      // Reg Instructions
      //sb.push_instruction(32'hA,8'h1, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //ADD
      //sb.push_instruction(8'h2, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //Sub
      //sb.push_instruction(8'h3, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //XOR
      //sb.push_instruction(8'h4, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //OR
      //sb.push_instruction(8'h5, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //AND
      //sb.push_instruction(8'h6, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //SLL
      //sb.push_instruction(8'h7, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //SRL
      //sb.push_instruction(8'h8, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //SRA
      //sb.push_instruction(8'h9, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //SLT
      //sb.push_instruction(8'hA, 21'b000000000000100000001, 5'b10000, 5'b00100, 5'b00001); //SLTU
      // Imm Instructions
      //sb.push_instruction(32'hA,8'hB, 21'b111111111111111111110, 5'b10000, 5'b00100, 5'b00001); //ADDI
      //sb.push_instruction(8'hC, 21'b111111111111111111111, 5'b10000, 5'b00100, 5'b00001); //XORI
      //sb.push_instruction(8'hD, 21'b000011111111111111111, 5'b10000, 5'b00100, 5'b00001); //ORI
      //sb.push_instruction(8'hE, 21'b001111111111111111111, 5'b10000, 5'b00100, 5'b00001); //ANDI
      //sb.push_instruction(8'hF, 21'b000011111111111100001, 5'b10000, 5'b00100, 5'b00001); //SLLI
      //sb.push_instruction(8'h10, 21'b111111111111111100001, 5'b10000, 5'b00100, 5'b00001); //SRLI 
      //sb.push_instruction(8'h11, 21'b111111111111111100001, 5'b10000, 5'b00100, 5'b00001); //SRAI
      //sb.push_instruction(8'h12, 21'b000000000000000000011, 5'b10000, 5'b00100, 5'b00001); //SLTI 
      //sb.push_instruction(8'h13, 21'b000000000000000000011, 5'b10000, 5'b00100, 5'b00001); //SLTIU
      // Load Instructions.
      //sb.push_instruction(8'h14, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //LB
      //sb.push_instruction(8'h15, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //LH
      //sb.push_instruction(8'h16, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //LW
      //sb.push_instruction(8'h17, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //LBU
      //sb.push_instruction(8'h18, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //LHU
      // Store Instructions
      //sb.push_instruction(8'h19, 21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //SB
      //sb.push_instruction(8'h1A,      21'b000000000000000000000, 5'b10000, 5'b00100, 5'b00001); //SH
      //sb.push_instruction(32'hA, 8'h1B, 21'b000000000000000000001, 5'b10000, 5'b00100, 5'b00001); //SW
      //sb.push_instruction(32'hA,8'h1C, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BEQ
      //sb.push_instruction(32'hA,8'h1D, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BNE
      //sb.push_instruction(32'hA,8'h1E, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BLT
      //sb.push_instruction(32'hA,8'h1F, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BGE
      //sb.push_instruction(32'hA,8'h20, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BLTU
      //sb.push_instruction(32'hA,8'h21, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BGEU
      //sb.push_instruction(32'hA,8'h22, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //JAL
      //sb.push_instruction(32'hA,8'h23, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //JALR
      //sb.push_instruction(32'hA,8'h24, 21'b111111111111111111111, 5'b10000, 5'b00100, 5'b00001); //LUI
      //sb.push_instruction(32'hA,8'h25,   21'b100000000000000000000, 5'b10000, 5'b00100, 5'b00001); //AUIPC


      // Pruebas Flush
      sb.push_instruction(32'h0,8'hB, 21'b111111111111111111110, 5'b10000, 5'b00100, 5'b00001); //ADDI
      sb.push_instruction(32'hA,8'h1C, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //BEQ
      sb.push_instruction(32'h24,8'hF, 21'b000011111111111100001, 5'b10000, 5'b00100, 5'b00001); //SLLI
      sb.push_instruction(32'h24,8'hF, 21'b000011111111111100001, 5'b10000, 5'b00100, 5'b00001); //SLLI
      sb.push_instruction(32'h24,8'hF, 21'b000011111111111100001, 5'b10000, 5'b00100, 5'b00001); //SLLI
      sb.push_instruction(32'h4,8'h22, 21'b111111111111111111100, 5'b10000, 5'b00100, 5'b00001); //JAL
      $display("Size of queue: ", sb.decoded_inst_q.size());
      // Process Instructions in Queue
      while (sb.decoded_inst_q.size() != 0)
        begin 
        $display("-----------------------------------------------------");
        $display("Instructions in Queue: ", sb.decoded_inst_q.size());
        $display("Calling process_inst function...");
        sb.process_inst();
        $display("Processed an Instruction, showing predicted Values");
        $display("rx_funct: %d", sb.rx_funct);
        $display("PC_Val_in: %h",(sb.ref_model.pc_val_in));
        $display("pc_val: %h", sb.pc_val);
        $display("JREQ: ", sb.ref_model.JREQ);
        $display("Flush: ", sb.ref_model.FLUSH);

        $display("imm_val: %b", sb.imm_val);
        $display("imm_val_sign_ext: %b", sb.imm_val_sign_ext);
        $display("imm_val_sign_ext: ", $signed(sb.imm_val_sign_ext));

        $display("rs1_val:", sb.rs1_val);
        $display("rs2_val:", sb.rs2_val);
        $display("rdd_val:", sb.rdd_val);

        $display("RS1: ",$signed(sb.ref_model.REGS[5'b10000]));
        $display("RS1: %b",(sb.ref_model.REGS[5'b10000]));   


        $display("\n");
        $display("Valor Final RDD: %b", sb.ref_model.REGS[5'b00001]);
        $display("Valor Final RDD: %h", sb.ref_model.REGS[5'b00001]);
        $display("Valor Final RDD: ", $signed(sb.ref_model.REGS[5'b00001]));
        $display("Valor Final Store MEM: %h", sb.ref_model.MEM[2]);
        $display("Valor Final Store MEM: ", $signed(sb.ref_model.MEM[2]));   
        end
    end
  endmodule
`endif