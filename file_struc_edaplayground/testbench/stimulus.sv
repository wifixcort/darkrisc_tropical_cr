import instructions_data_struc::*;
`include "../src/config.vh"
// for test
`define MLEN 15

class instruction_generator;
  	
    rand bit [31:0] full_inst;
    rand bit [6:0]  opcode;
    rand bit [4:0]  rs1;
    rand bit [4:0]  rs2;
    rand bit [4:0]  rd;
    rand bit [6:0]  funct7;
    rand bit [2:0]  funct3;
    rand bit [31:0] imm;

    //=============================
    //Constraints
    //=============================
  
    constraint construct_full_inst{
    	solve opcode,rs1,rs2,funct7,funct3,imm before full_inst;
        (opcode == R_TYPE)   -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
        (opcode == I_TYPE)   -> full_inst == {imm[11:0],rs1,funct3,rd,opcode};
        (opcode == I_L_TYPE) -> full_inst == {imm[11:0],rs1,funct3,rd,opcode};
        (opcode == S_TYPE)   -> full_inst == {imm[11:5],rs2, rs1,funct3,imm[4:0],opcode};
    }
  
    constraint opcode_cases {
        opcode inside 	{R_TYPE,
                        I_TYPE
                        /*I_L_TYPE
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

        (opcode == I_L_TYPE) -> funct3 inside {LB_FC,
                                              LH_FC, 
                                              LW_FC,
                                              LBU_FC,     
                                              LHU_FC};
      
        (opcode == S_TYPE) -> funct3 inside   {SB_FC,
                                              SH_FC,
                                              SW_FC};
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
  
  	// x0 is always 0. 
  	// regs for use -> 1 to 15
    constraint regs {
      	solve rs1, rs2, rd before full_inst;
      	rs1 != 0;
        rs2 != 0;
      	rd  != 0;
        rs1 < 16;
        rs2 < 16;
        rd  < 16;
    }

    // offset should be multiple of data size of operand
   	constraint offset_imm_load_store {
      	solve funct3 before imm;
    	if (opcode == I_L_TYPE){
          //si se hace con ||, es como si no existiera el constraint para ese funct3 ¿por que? no lo se.
          /*(funct3 == (LB_FC || LBU_FC)) -> 	imm[2:0] == 3'b000;
          (funct3 == (LH_FC || LHU_FC)) ->	imm[3:0] == 4'b0000;*/
          (funct3 == LB_FC) 	-> 	imm[2:0] == 3'b000;
          (funct3 == LBU_FC) 	-> 	imm[2:0] == 3'b000;
          (funct3 == LH_FC) 	->	imm[3:0] == 4'b0000;
          (funct3 == LHU_FC) 	->	imm[3:0] == 4'b0000;
          (funct3 == LW_FC) 	->	imm[4:0] == 5'b00000;
      	}
          
        if (opcode == S_TYPE){
          (funct3 == SB_FC) 	-> 	imm[2:0] == 3'b000;
          (funct3 == SH_FC) 	->	imm[3:0] == 4'b0000;
          (funct3 == SW_FC) 	->	imm[4:0] == 5'b00000;
      	}
    } 
      
endclass
  
          

          
class stimulus;
  reg [31:0] MEM [0:2**`MLEN/4-1];
  logic [7:0] debug_counter;
  
  // fulling the MEM array
  function void mem_generate(logic DBG_HIGH_VERBOSITY=0);
    instruction_generator inst_gen;
    inst_gen = new;
    debug_counter = 0;
    for(int i=0;i!=2**`MLEN/4;i=i+1)
    begin
        MEM[i] = 32'd0; //This is completely necessary, otherwise there are x's in the RAM 
    end
    foreach(MEM[i]) begin
      inst_gen.randomize();
	    if (DBG_HIGH_VERBOSITY && debug_counter<50) begin //Print only n-instructions
        // Due to RISCV management of signed numbers, these displays ALWAYS (I think) print positive numbers
        if (inst_gen.opcode==R_TYPE)begin
          $display("Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  |  rd=%d |  imm=%d", debug_counter, inst_gen.opcode, inst_gen.rs1, inst_gen.rs2, inst_gen.rd, 0);
        end
        else if (inst_gen.opcode==I_TYPE || inst_gen.opcode==I_L_TYPE || inst_gen.opcode==S_TYPE)begin
          $display("Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  |  rd=%d |  imm=%d", debug_counter, inst_gen.opcode, inst_gen.rs1, inst_gen.rs2, inst_gen.rd, inst_gen.imm[11:0]);
        end  
        debug_counter=debug_counter+1;
      end
      MEM[i] = inst_gen.full_inst;
    end
    //return MEM;
  endfunction
  
  // TO DO: función para generar instrucciones anteriores a loads que tengan sentido para estos
  //	fuente de la idea: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
  // filminas 8 y 9
  
endclass

 
////////////////////////// 

//Unselect next line for test
//`define stimulus_tb
`ifdef stimulus_tb
  module tb;
    initial begin
      stimulus sti = new();
      sti.mem_generate(1);
      $display("**************************/n");
      $display("MEM size = %d\n",$size(sti.MEM));
      for (int i = 0 ; i < 50; i++) begin
        $display("instruction: %h     op: %b",sti.MEM[i], sti.MEM[i][6:0]);
      end
      $display(".\n.\n.\n");
    end
  endmodule
`endif
