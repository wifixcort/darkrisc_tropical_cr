import instructions_data_struct::*;

class stimulus;
  rand bit [31:0] full_inst;
  rand bit [6:0]  opcode;
  rand bit [4:0]  rs1;
  rand bit [4:0]  rs2;
  rand bit [4:0]  rd;
  rand bit [6:0]  funct7;
  rand bit [2:0]  funct3;
  rand bit [31:0] imm;
  
  constraint construct_full_inst{
    solve opcode,rs1,rs2,funct7,funct3,imm before full_inst;
    (opcode == R_TYPE) -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
    (opcode == I_TYPE) -> full_inst == {imm[11:0],rs1,funct3,rd,opcode};
  }
  
  constraint opcode_cases {
    opcode inside 	{R_TYPE,
              		I_TYPE
             		/*I_L_TYPE,
              		S_TYPE,
              		S_B_TYPE,
              		J_TYPE,
              		I_JALR_TYPE,
             		LUI_TYPE,
              		AUIPC_TYPE */
             	  	};
  }
  
  // No necessary because in 3 bits are the 8 possible combinations
  // Is util for deselect the possibilities
  constraint funct3_cases{
  	solve opcode before funct3;
    (opcode == R_TYPE) -> funct3 inside {ADD_o_SUB_FC,
                                        XOR_FC,
                                        OR_FC,
                                        AND_FC,
                                        SLL_FC,
                                        SRL_o_SRA_FC,
                                        SLT_FC,
                                        SLTU_FC};
    
    (opcode == I_TYPE) -> funct3 inside {ADDI_FC,
                                        XORI_FC,
                                        ORI_FC,
                                        ANDI_FC,
                                        SLLI_FC,
                                        SRLI_FC,
                                        SRAI_FC,
                                        SLTI_FC,
                                        SLTIU_FC};
  }
  
constraint func7_cases{
  	solve funct3 before funct7;
   
    if (opcode == R_TYPE) {
       (funct3 == (ADD_o_SUB_FC || SRL_o_SRA_FC )) -> funct7 inside {h00_FC7,
                                                                     h20_FC7};
       (funct3 != (ADD_o_SUB_FC || SRL_o_SRA_FC )) -> funct7 ==      h00_FC7;
    } 
   
    //special cases of I_TYPE instructions
    if (opcode == I_TYPE) { 
       (funct3 == SRLI_FC)  -> imm[11:5] inside {h20_FC7,
                                                  h00_FC7};
       (funct3 == SLLI_FC)  -> imm[11:5]      == h00_FC7;
    }
  }
  
  // x0 is always 0
  constraint no_reg_x0 {
    rs1 != 0;
    rs2 != 0;
    rd  != 0;
  }

endclass

////////////////////////// 

//Unselect next line for test
//`define stimulus_tb
`ifdef stimulus_tb
  module tb;
    initial begin
      for (int i = 0 ; i < 50; i++) begin
        stimulus sti = new();
        sti.randomize();
        //$display("op=%b  |  rs1=%d  |  rs2=%d  |  rd=%d", sti.opcode, sti.rs1, sti.rs2, sti.rd);
        $display("isntruction: %h",sti.full_inst);
      end
    end
  endmodule
`endif
