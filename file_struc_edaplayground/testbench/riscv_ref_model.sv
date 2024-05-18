import instructions_data_struc::*;

`include "../src/config.vh"

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
  logic bt;
  // For debug
  logic [31:0] pc_val_in;
  logic [31:0] fake_reg0;
  // General Purpose 32x32 bit registers 
  logic [31:0] REGS [0:31];
  integer i;
  // Memory Model
  logic [31:0] MEM [0:2**`MLEN/4-1]; // ro memory
  
  // Constructor
  function new();
    pc_val_upd  = '0;
    pc_val_in   = '0;
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
    // L/S: DADDR[31] must equal 0, if not we access I/O peripherals.
    // All instructions shouldnt be allowed to modify register 0 value
    pc_val_in = pc_val; // Copy of the input PC for debug
    case (rx_funct)
      // R Type
      ADD  : begin 
        REGS[rdd_val] = REGS[rs1_val] + REGS[rs2_val];
        pc_val = pc_val + 4;
      end
      SUB  : begin 
        REGS[rdd_val] = REGS[rs1_val] - REGS[rs2_val];
        pc_val = pc_val + 4;
      end
      XOR  : begin 
        REGS[rdd_val] = REGS[rs1_val] ^ REGS[rs2_val];
        pc_val = pc_val + 4;
      end
      OR   : begin 
        REGS[rdd_val] = REGS[rs1_val] | REGS[rs2_val];
        pc_val = pc_val + 4;
      end
      AND  : begin 
        REGS[rdd_val] = REGS[rs1_val] & REGS[rs2_val];
        pc_val = pc_val + 4;
      end
      SLL  : begin 
        REGS[rdd_val] = REGS[rs1_val] << (REGS[rs2_val][4:0]);
        pc_val = pc_val + 4;
      end
      SRL  : begin 
        REGS[rdd_val] = REGS[rs1_val] >> (REGS[rs2_val][4:0]);
        pc_val = pc_val + 4;
      end
      SRA  : begin 
        REGS[rdd_val] = $signed(REGS[rs1_val]) >>> (REGS[rs2_val][4:0]); 
        pc_val = pc_val + 4;
      end
      SLT  : begin 
        REGS[rdd_val] = ($signed(REGS[rs1_val]) < $signed(REGS[rs2_val])) ? 1'b1 : 1'b0;
        pc_val = pc_val + 4;
      end
      SLTU : begin 
        REGS[rdd_val] = (REGS[rs1_val] < REGS[rs2_val]) ? 1'b1 : 1'b0;
        pc_val = pc_val + 4;
      end
      // I Type 
      ADDI : begin //This Operation is always signed
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        REGS[rdd_val] = (REGS[rs1_val]) + (imm_val_sign_ext);
        pc_val = pc_val + 4;
      end
      XORI : begin
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] ^ imm_val_sign_ext;
        pc_val = pc_val + 4;
      end
      ORI  : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        REGS[rdd_val] = REGS[rs1_val] | imm_val_sign_ext;
        pc_val = pc_val + 4;
      end
      ANDI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
      	REGS[rdd_val] = REGS[rs1_val] & imm_val_sign_ext;
        pc_val = pc_val + 4;
      end
      SLLI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] << (imm_val_sign_ext[4:0]);
        pc_val = pc_val + 4;
      end
      SRLI : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = REGS[rs1_val] >> (imm_val_sign_ext[4:0]); 
        pc_val = pc_val + 4;
        //$display("pc_val: %h, rx_f: %h, imm: %b, rs1: %h, rs2: %h, rdd: %h", pc_val, rx_funct, imm_val, rs1_val, rs2_val, rdd_val);
      end
      SRAI : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = $signed(REGS[rs1_val]) >>> (imm_val_sign_ext[4:0]);
        pc_val = pc_val + 4;
        //$display("xd",pc_val, rx_funct, imm_val,rs1_val, rs2_val, rdd_val);
      end
      SLTI : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = ($signed(REGS[rs1_val]) < imm_val_sign_ext) ? 1'b1 : 1'b0; 
        pc_val = pc_val + 4;
      end
      SLTIU: begin 
        imm_val_sign_ext = {{20{1'b0}}, imm_val[11:0]}; // No sign extension required
        REGS[rdd_val] = (REGS[rs1_val] < imm_val_sign_ext) ? 1'b1 : 1'b0;
        pc_val = pc_val + 4;
      end
      // I-L(load) Type - DADDR[31] must equal 0, if not we access I/O peripherals.
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
        pc_val = pc_val + 4;
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
        pc_val = pc_val + 4;
      end
      LW   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAI = MEM[DADDR[`MLEN-1:2]];
        BE = 4'b1111;
        REGS[rdd_val] = DATAI;
        pc_val = pc_val + 4;
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
        pc_val = pc_val + 4;
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
        pc_val = pc_val + 4;
      end 
      // S-Type - DADDR[31] must equal 0, if not we access I/O peripherals.
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
        pc_val = pc_val + 4;
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
        pc_val = pc_val + 4;
      end
      SW   : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        DADDR = REGS[rs1_val] + imm_val_sign_ext;
        DATAO = REGS[rs2_val];
        BE = 4'b1111;
        MEM[DADDR[`MLEN-1:2]] = DATAO;
        pc_val = pc_val + 4;
      end
      // S-B-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
      BEQ  : begin
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        bt = REGS[rs1_val] == REGS[rs2_val];
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      BNE  : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        bt = REGS[rs1_val] != REGS[rs2_val];
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      BLT  : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        bt = $signed(REGS[rs1_val]) < $signed(REGS[rs2_val]);
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      BGE  : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        bt = $signed(REGS[rs1_val]) >= $signed(REGS[rs2_val]);
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      BLTU : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        bt = REGS[rs1_val] < REGS[rs2_val];
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      BGEU : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        bt = REGS[rs1_val] >= REGS[rs2_val];
        case(bt)
          0 : pc_val = pc_val + 4;
          1 : pc_val = pc_val + imm_val_sign_ext;
        endcase
      end
      // J-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
      JAL  : begin  // JAL with rd = 0x is a plain jump
      	imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = pc_val+4;
        pc_val = pc_val + imm_val_sign_ext;  
      end 
      JALR : begin 
        imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        REGS[rdd_val] = pc_val+4;
        pc_val = REGS[rs1_val] + imm_val_sign_ext;
      end
      // U-Type
      LUI  : begin 
        imm_val_sign_ext = {imm_val[20:0], {11{1'b0}}}; 
        REGS[rdd_val] = imm_val_sign_ext;
      end 
      AUIPC: begin 
        imm_val_sign_ext = {imm_val[20:0], {11{1'b0}}}; 
        REGS[rdd_val] = pc_val + imm_val_sign_ext;
      end
    endcase
    
    // Assign Value that was supposed to be for reg0 to a fake reg
    fake_reg0 = REGS[rdd_val];
    // Keep Register 0 to value 0
    REGS[0] = 0;
    
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
