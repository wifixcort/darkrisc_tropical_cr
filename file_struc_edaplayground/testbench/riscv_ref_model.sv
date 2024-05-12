import instructions_data_struc::*;

`include "config.vh"

class riscv_ref_model;
  // Signals that store predicted value
  logic [31:0] pc_val_upd;
  logic [4:0] rs1_val_upd;
  logic [4:0] rs2_val_upd;
  logic [4:0] rdd_val_upd;
  logic signed [31:0]  imm_val_sign_ext;
  logic [31:0] DATAI;
  logic [31:0] DATAO;
  logic [31:0] DADDR;
  logic [3:0] BE;
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
  
  function predict(logic [31:0] pc_val, logic [7:0] rx_funct,logic signed [20:0] imm_val,logic [4:0] rs1_val,logic [4:0] rs2_val,logic [4:0] rdd_val);
    // Procces and Execute Instruction, increment pc
    // L/S: DADDR[31] debe ser 0 para ejecutar esto, de lo contario se accede a I/O de los perifericos.
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
      ADDI : begin //This Operation is always signed
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        REGS[rdd_val] = (REGS[rs1_val]) + (imm_val_sign_ext);
      end
      XORI : begin
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] ^ imm_val_sign_ext;
      end
      ORI  : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        REGS[rdd_val] = REGS[rs1_val] | imm_val_sign_ext;
      end
      ANDI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
      	REGS[rdd_val] = REGS[rs1_val] & imm_val_sign_ext;
      end
      SLLI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] << (imm_val_sign_ext[4:0]);
      end
      SRLI : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] >> (imm_val_sign_ext[4:0]); 
      end
      SRAI : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = $signed(REGS[rs1_val]) >>> (imm_val_sign_ext[4:0]);
      end
      SLTI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = ($signed(REGS[rs1_val]) < imm_val_sign_ext) ? 1'b1 : 1'b0; 
      end
      SLTIU: begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = (REGS[rs1_val] < $unsigned(imm_val_sign_ext)) ? 1'b1 : 1'b0;
      end
      // I-L(load)Type
      LB   : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]]; 
        case (DADDR[1:0])
          3: BE = 4'b1000;
          2: BE = 4'b0100;
          1: BE = 4'b0010;
          0: BE = 4'b0001;
        endcase
        case (BE)
          4'b1000: DATAI = {{24{DATAI[31]}},DATAI[31:24]};
          4'b0100: DATAI = {{24{DATAI[23]}},DATAI[23:16]};
          4'b0010: DATAI = {{24{DATAI[15]}},DATAI[15:8 ]};
          4'b0001: DATAI = {{24{DATAI[7 ]}},DATAI[7:0  ]};
        endcase
        REGS[rdd_val] = DATAI;
      end
      LH   : begin
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]];
        case (DADDR[0])
          1: BE = 4'b1100;
          0: BE = 4'b0011;
        endcase
        case (BE)
          4'b1100: DATAI = {{16{DATAI[31]}},DATAI[31:16]};
          4'b0011: DATAI = {{16{DATAI[15]}},DATAI[15:0]};
        endcase
        REGS[rdd_val] = DATAI;
      end
      LW   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]];
        BE = 4'b1111;
        REGS[rdd_val] = DATAI;
      end
      LBU  : begin 
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]]; 
        case (DADDR[1:0])
          3: BE = 4'b1000;
          2: BE = 4'b0100;
          1: BE = 4'b0010;
          0: BE = 4'b0001;
        endcase
        case (BE)
          4'b1000: DATAI = {{24{1'b0}},DATAI[31:24]};
          4'b0100: DATAI = {{24{1'b0}},DATAI[23:16]};
          4'b0010: DATAI = {{24{1'b0}},DATAI[15:8]};
          4'b0001: DATAI = {{24{1'b0}},DATAI[7:0]};
        endcase
        REGS[rdd_val] = DATAI;
      end
      LHU  : begin 
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]];
        case (DADDR[0])
          1: BE = 4'b1100;
          0: BE = 4'b0011;
        endcase
        case (BE)
          4'b1100: DATAI = {{16{1'b0}},DATAI[31:16]};
          4'b0011: DATAI = {{16{1'b0}},DATAI[15:0]};
        endcase
        REGS[rdd_val] = DATAI;
      end 
      // S-Type
      SB   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        case (DADDR[1:0])
          3: BE = 4'b1000;
          2: BE = 4'b0100;
          1: BE = 4'b0010;
          0: BE = 4'b0001;
        endcase
        case (BE)
          4'b1000: begin 
            DATAO = {REGS[rs2_val][7:0],{24{1'b0}}};
            MEM[DADDR[`MLEN-1:2]][31:24] = DATAO[31:24];
          end 
          4'b0100: begin
            DATAO = {{8{1'b0}},REGS[rs2_val][7:0],{16{1'b0}}};
            MEM[DADDR[`MLEN-1:2]][23:16] = DATAO[23:16];
          end
          4'b0010: begin 
            DATAO = {{16{1'b0}},REGS[rs2_val][7:0],{8{1'b0}}};
            MEM[DADDR[`MLEN-1:2]][15:8] = DATAO[15:8];
          end
          4'b0001: begin 
            DATAO = {{24{1'b0}},REGS[rs2_val][7:0]};
            MEM[DADDR[`MLEN-1:2]][7:0] = DATAO[7:0];
          end 
        endcase
      end
	  SH   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        case (DADDR[0])
          1: BE = 4'b1100;
          0: BE = 4'b0011;
        endcase
        case (BE)
          4'b1100: begin 
            DATAO = {REGS[rs2_val][15:0],{16{1'b0}}};
            MEM[DADDR[`MLEN-1:2]][31:16] = DATAO[31:16];
          end
          4'b0011: begin 
            DATAO = {{16{1'b0}},REGS[rs2_val][15:0]};
            MEM[DADDR[`MLEN-1:2]][15:0] = DATAO[15:0];
          end 
        endcase
      end
      SW   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAO = REGS[rs2_val];
        BE = 4'b1111;
        MEM[DADDR[`MLEN-1:2]] = DATAO;
      end
      /*
      // S-B-Type
      BEQ  : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
      BNE  : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
      BLT  : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
      BGE  : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
      BLTU : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
      BGEU : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
      */
      // J-Type
      JAL  : begin // jump ±1 MiB range 
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = pc_val+4;
        pc_val = pc_val + imm_val_sign_ext;
      end 
      
      JALR : imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
      // U-Type
      LUI  : imm_val_sign_ext = {imm_val[20:0], '0};
	  AUIPC: imm_val_sign_ext = {imm_val[20:0], '0};
    endcase
    
    // Update Predicted Values
    pc_val_upd  = pc_val;
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