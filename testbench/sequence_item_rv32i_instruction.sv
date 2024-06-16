//`include "uvm_macros.svh"
//import uvm_pkg::*;
import instructions_data_struc::*;
//`include "../rtl/config.vh"

// sequence item  <- legacy class instruction_generator
class sequence_item_rv32i_instruction extends uvm_sequence_item;

  // random variables 
  rand bit [31:0] full_inst;
  rand bit [6:0]  opcode;
  rand bit [4:0]  rs1;
  rand bit [4:0]  rs2;
  rand bit [4:0]  rd;
  rand bit [6:0]  funct7;
  rand bit [2:0]  funct3;
  rand bit [11:0] imm;

  // operation variables
  logic opt_addr_select = 1'b0; //optimize for generate address

  //==============================================================
  //         Constraints for instruction generator
  //==============================================================
   
  // Generate the full instruction in last contraint solver
  //**************************************************************
  constraint construct_full_inst{
    solve opcode,rd,rs1,rs2,funct7,funct3,imm before full_inst;
    (opcode == R_TYPE)   -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
    (opcode == I_TYPE)   -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == I_L_TYPE) -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == S_TYPE)   -> full_inst == {imm[11:5],rs2, rs1,funct3,imm[4:0],opcode};   
   }
   
   //********************************************************
  constraint opcode_cases{
  soft opcode dist  {R_TYPE   :/ 44,
                    I_TYPE    :/ 44,
                    I_L_TYPE  :/ 5,
                    S_TYPE    :/ 5
                    /*S_B_TYPE,
                    J_TYPE,
                    I_JALR_TYPE,
                    LUI_TYPE,
                    AUIPC_TYPE */
                  };
  }
   
  // funct3
  //********************************************************
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

  // for R_TYPE and some I_TYPE instructions
  //********************************************************
  constraint func7_cases{
    solve funct3 before funct7;
    if (opcode == R_TYPE) {
      (funct3 == ADD_o_SUB_FC)  -> funct7 inside {h00_FC7,
                                                  h20_FC7};
      (funct3 == SRL_o_SRA_FC ) -> funct7 inside {h00_FC7,
                                                  h20_FC7};
      (funct3 != ADD_o_SUB_FC ) -> funct7 ==      h00_FC7; 
      (funct3 != SRL_o_SRA_FC ) -> funct7 ==      h00_FC7; 
    } 
    //special cases of I_TYPE instructions
    if (opcode == I_TYPE) { 
      (funct3 == SRLI_FC)  -> imm[11:5] inside {h20_FC7,
                                                   h00_FC7};
      (funct3 == SLLI_FC)  -> imm[11:5]      == h00_FC7;
    }
  }
   
  // special cases for regs
  //************************
  constraint regs {
    if (opcode == S_TYPE) {
      rs1 != 0; 
      //rs2 != 0;
    }   

    if (opcode == I_L_TYPE) {
      rs1 != 0; 
      rd  != 0;
    }
   }
   
  // Offseft for calc effective direction
  //*******************************************************
  constraint offset_load_store {
    solve funct3 before imm;
    if (!opt_addr_select) {     
      if (opcode == I_L_TYPE){
        (funct3 == LH_FC) 	->	imm[0]   == 1'b0;
        (funct3 == LHU_FC) 	->	imm[0]   == 1'b0;
        (funct3 == LW_FC) 	->	imm[1:0] == 2'b00;
      } else if (opcode == S_TYPE){
        (funct3 == SH_FC) 	->	imm[0]   == 1'b0;
        (funct3 == SW_FC) 	->	imm[1:0] == 2'b00;
      }
      //ACOTADORES de offset a +127 -127
      if(imm[11] == 0){
        //pos sign extend
        imm[10:8] == 3'b000;
      } else if (imm[11] == 1){
        //neg sign extend
        imm[10:8] == 3'b111;
      }
    }
   } 
   
  // UVM requirements
  //*******************************************************
  `uvm_object_utils_begin(sequence_item_rv32i_instruction)
  `uvm_object_utils_end
  function new(string name = "sequence_item_rv32i_instruction");
    super.new(name);
  endfunction
endclass
