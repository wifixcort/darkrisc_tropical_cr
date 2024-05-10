import instructions_data_struc::*;

`include "config.vh"

class riscv_ref_model;
  // Signals that store predicted value
  //logic [31:0] pc_val_upd;
  logic [4:0] rs1_val_upd;
  logic [4:0] rs2_val_upd;
  logic [4:0] rdd_val_upd;
  logic signed [31:0]  imm_val_sign_ext;
  logic [31:0] DATAI;
  logic [31:0] DATAO;
  logic [31:0] DADDR;
  // General Purpose 32x32 bit registers 
  logic [31:0] REGS [0:31];
  integer i;
  // Memory Model
  logic [31:0] MEM [0:2**`MLEN/4-1]; // ro memory
  
  // Constructor
  function new();
    //pc_val_upd  = '0;
    rs1_val_upd = '0;
    rs2_val_upd = '0;
    rdd_val_upd = '0;
    imm_val_sign_ext = '0;
    DATAI = '0;
    DATAO = '0;
    DADDR = '0;
    // Loop to initialize all registers to zero
    for (i = 0; i < 32; i = i + 1) begin
      REGS[i] = '0;
    end
    // Intialize Memory
    $readmemh("darksocv.mem",MEM,0);
  endfunction
  
  function predict(logic [7:0] rx_funct,logic signed [20:0] imm_val,logic [4:0] rs1_val,logic [4:0] rs2_val,logic [4:0] rdd_val);
    // Procces and Execute Instruction, increment pc
    case (rx_funct)
      // R Type
      ADD  : REGS[rdd_val] = REGS[rs1_val] + REGS[rs2_val];
      SUB  : REGS[rdd_val] = REGS[rs1_val] - REGS[rs2_val];
      XOR  : REGS[rdd_val] = REGS[rs1_val] ^ REGS[rs2_val];
      OR   : REGS[rdd_val] = REGS[rs1_val] | REGS[rs2_val];
      AND  : REGS[rdd_val] = REGS[rs1_val] & REGS[rs2_val];
      SLL  : REGS[rdd_val] = REGS[rs1_val] << (REGS[rs2_val][4:0]);
      SRL  : REGS[rdd_val] = REGS[rs1_val] >> (REGS[rs2_val][4:0]);
      SRA  : REGS[rdd_val] = $signed(REGS[rs1_val]) >>> (REGS[rs2_val][4:0]); 
      SLT  : REGS[rdd_val] = ($signed(REGS[rs1_val]) < $signed(REGS[rs2_val])) ? 1'b1 : 1'b0;
      SLTU : REGS[rdd_val] = (REGS[rs1_val] < REGS[rs2_val]) ? 1'b1 : 1'b0;
      // I Type
      ADDI : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] + imm_val_sign_ext;
      end
      XORI : begin
      	imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] ^ imm_val_sign_ext;
      end
      ORI  : begin
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] | imm_val_sign_ext;
      end
      ANDI : begin
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
      	REGS[rdd_val] = REGS[rs1_val] & imm_val_sign_ext;
      end
      SLLI : begin
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        REGS[rdd_val] = REGS[rs1_val] << (imm_val_sign_ext[4:0]);
      end
      SRLI : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        REGS[rdd_val] = REGS[rs1_val] >> (imm_val_sign_ext[4:0]);
      end
      SRAI : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        REGS[rdd_val] = $signed(REGS[rs1_val]) >>> (imm_val_sign_ext[4:0]);
      end
      SLTI : begin
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        REGS[rdd_val] = ($signed(REGS[rs1_val]) < imm_val_sign_ext) ? 1'b1 : 1'b0;
      end
      SLTIU: begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        REGS[rdd_val] = (REGS[rs1_val] < $unsigned(imm_val_sign_ext)) ? 1'b1 : 1'b0;
      end
      /*
      // I-L(load)Type
      LB   : begin
      	imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR];
        REGS[rdd_val] = DATAI[7:0];
      end 
      LH   : begin
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      end
      LW   : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      end
      LBU  : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      end
      LHU  : begin 
        imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      end 
      // S-Type
      SB   : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
	  SH   : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      SW   : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      // S-B-Type
      BEQ  : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      BNE  : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      BLT  : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      BGE  : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      BLTU : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
      BGEU : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]}; 
      // J-Type
      JAL  : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      JALR : imm_val_sign_ext = {(imm_val[20])? '1 : '0, imm_val[20:0]};
      // U-Type
      LUI  : imm_val_sign_ext = {imm_val[20:0], '0};
	  AUIPC: imm_val_sign_ext = {imm_val[20:0], '0};
      */
    endcase
    
    // Update Predicted Values
    //pc_val_upd  = pc_val;
    rs1_val_upd = rs1_val;
    rs2_val_upd = rs2_val;
    rdd_val_upd = rdd_val;
    /*
    The following are also Predicted: 
    imm_val_sign_ext
    DATAI
    DATAO
    DADDR
    rx_funct
    */
  endfunction
    
endclass

// https://nandland.com/shift-operator/