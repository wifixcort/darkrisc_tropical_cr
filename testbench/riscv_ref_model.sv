import instructions_data_struc::*;

`include "../src/config.vh"

class riscv_ref_model extends uvm_component;
    `uvm_component_utils(riscv_ref_model);
    
    // Analysis ports
    //uvm_analysis_port  #(ref_model_t, scoreboard) ap_ref_model;

    // Analysis FIFO to store predictions from ref_model
    uvm_analysis_fifo#(pred_t) ref_model_fifo;

    // Signals that store predicted value
    logic [31:0] pc_val_upd;
    logic signed [31:0]  imm_val_sign_ext;
    logic [31:0] DATAI;
    logic [31:0] DATAO;
    logic [31:0] DADDR;
    logic [3:0] BE;
    logic JREQ;
    // For debug
    logic [31:0] rs1_val_ini;
    logic [31:0] rs2_val_ini;
    logic [31:0] pc_val_in;
    logic [31:0] fake_reg0;
    // General Purpose 32x32 bit registers 
    logic [31:0] REGS [0:31];
    integer i;
    // Memory Model
    logic [31:0] MEM [0:2**`MLEN/4-1]; // ro memory
    // FLUSH Counter
    logic [1:0] FLUSH;
    // Nota: Funcionalidad de Reset despues del primer reset no implementada, por tanto reset no levanta FLUSH en modelo
  
  // Constructor
  function new(string name = ref_model, uvm_component parent = sb);
    super.new(name, parent);
    pc_val_upd  = '0;
    pc_val_in   = '0;
    imm_val_sign_ext = '0;
    DATAI = '0;
    DATAO = '0;
    DADDR = '0;
    JREQ  = '0;
    FLUSH = '0;
    // Loop to initialize all registers to zero
    for (i = 0; i < 32; i = i + 1) begin
      REGS[i] = '0;
    end
    // Intialize Memory
    $readmemh("darksocv.mem",MEM,0);
  endfunction
  
  // Build Phase 
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // Instance of the analysis ports
      //ap_ref_model = new("ap_ref_model", this);
      ref_model_fifo = new("ref_model_fifo", this);
  endfunction 

  function predict(ref_model_t t);
    // L/S: DADDR[31] must equal 0, if not we access I/O peripherals.
    // All instructions shouldnt be allowed to modify register 0 value
    pc_val_in = t.pc_val; // Copy of the input PC for debug
    rs1_val_ini = REGS[t.rs1]; // Copy of initial t.rs1 value
    rs2_val_ini = REGS[t.rs2]; // Copy of initial t.rs2 Value
    // For each call we clean our internal variables that arent outputs
    JREQ = 0;
    DADDR = 0;
    DATAI = 0;
    BE = 0;
    case (t.rx_funct)
      // R Type
      ADD  : begin 
        if (!(|FLUSH)) begin
         REGS[t.rdd] = REGS[t.rs1] + REGS[t.rs2];
        end
        t.pc_val = t.pc_val + 4;
      end
      SUB  : begin 
        if (!(|FLUSH)) begin
         REGS[t.rdd] = REGS[t.rs1] - REGS[t.rs2];
        end
        t.pc_val = t.pc_val + 4;
      end
      XOR  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = REGS[t.rs1] ^ REGS[t.rs2];
        end
        t.pc_val = t.pc_val + 4;
      end
      OR   : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = REGS[t.rs1] | REGS[t.rs2];
        end
        t.pc_val = t.pc_val + 4;
      end
      AND  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = REGS[t.rs1] & REGS[t.rs2];
        end
        t.pc_val = t.pc_val + 4;
      end
      SLL  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = REGS[t.rs1] << (REGS[t.rs2][4:0]);
        end
        t.pc_val = t.pc_val + 4;
      end
      SRL  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = REGS[t.rs1] >> (REGS[t.rs2][4:0]);
        end
        t.pc_val = t.pc_val + 4;
      end
      SRA  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = $signed(REGS[t.rs1]) >>> (REGS[t.rs2][4:0]);
        end
        t.pc_val = t.pc_val + 4;
      end
      SLT  : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = ($signed(REGS[t.rs1]) < $signed(REGS[t.rs2])) ? 1'b1 : 1'b0;
        end
        t.pc_val = t.pc_val + 4;
      end
      SLTU : begin 
        if (!(|FLUSH)) begin
        	REGS[t.rdd] = (REGS[t.rs1] < REGS[t.rs2]) ? 1'b1 : 1'b0;
        end
        t.pc_val = t.pc_val + 4;
      end
      // I Type 
      ADDI : begin //This Operation is always signed
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};  
        	REGS[t.rdd] = (REGS[t.rs1]) + (imm_val_sign_ext);
        end
        t.pc_val = t.pc_val + 4;
      end
      XORI : begin
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = REGS[t.rs1] ^ imm_val_sign_ext;
        end      	
        t.pc_val = t.pc_val + 4;
      end
      ORI  : begin
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};  
        	REGS[t.rdd] = REGS[t.rs1] | imm_val_sign_ext;
        end
        t.pc_val = t.pc_val + 4;
      end
      ANDI : begin
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};  
      	REGS[t.rdd] = REGS[t.rs1] & imm_val_sign_ext;
        end
        t.pc_val = t.pc_val + 4;
      end
      SLLI : begin
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = REGS[t.rs1] << (imm_val_sign_ext[4:0]);
        end
        t.pc_val = t.pc_val + 4;
      end
      SRLI : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = REGS[t.rs1] >> (imm_val_sign_ext[4:0]); 
        end
        t.pc_val = t.pc_val + 4;
      end
      SRAI : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = $signed(REGS[t.rs1]) >>> (imm_val_sign_ext[4:0]);
        end
        t.pc_val = t.pc_val + 4;
      end
      SLTI : begin
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = ($signed(REGS[t.rs1]) < imm_val_sign_ext) ? 1'b1 : 1'b0;
        end
        t.pc_val = t.pc_val + 4;
      end
      SLTIU: begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{20{1'b0}}, t.imm_val[11:0]}; // No sign extension required
        	REGS[t.rdd] = (REGS[t.rs1] < imm_val_sign_ext) ? 1'b1 : 1'b0;
        end
        t.pc_val = t.pc_val + 4;
      end
      // I-L(load) Type - DADDR[31] must equal 0, if not we access I/O peripherals.
      LB   : begin
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
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
          REGS[t.rdd] = DATAI;
        end
        t.pc_val = t.pc_val + 4;
      end
      LH   : begin
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          DATAI = MEM[DADDR[`MLEN-1:2]];
          case (DADDR[1])
            1: BE = 4'b1100;
            0: BE = 4'b0011;
          endcase
          case (BE)
            4'b1100: DATAI = {{16{DATAI[31]}},DATAI[31:16]};
            4'b0011: DATAI = {{16{DATAI[15]}},DATAI[15:0]};
          endcase
          REGS[t.rdd] = DATAI;
        end
        t.pc_val = t.pc_val + 4;
      end
      LW   : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          DATAI = MEM[DADDR[`MLEN-1:2]];
          BE = 4'b1111;
          REGS[t.rdd] = DATAI;
        end
        t.pc_val = t.pc_val + 4;
      end
      LBU  : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
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
          REGS[t.rdd] = DATAI;
        end
        t.pc_val = t.pc_val + 4;
      end
      LHU  : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          DATAI = MEM[DADDR[`MLEN-1:2]];
          case (DADDR[1])
            1: BE = 4'b1100;
            0: BE = 4'b0011;
          endcase
          case (BE)
            4'b1100: DATAI = {{16{1'b0}},DATAI[31:16]};
            4'b0011: DATAI = {{16{1'b0}},DATAI[15:0]};
          endcase
          REGS[t.rdd] = DATAI;
        end
        t.pc_val = t.pc_val + 4;
      end 
      // S-Type - DADDR[31] must equal 0, if not we access I/O peripherals.
      SB   : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          case (DADDR[1:0])
            3: BE = 4'b1000;
            2: BE = 4'b0100;
            1: BE = 4'b0010;
            0: BE = 4'b0001;
          endcase
          case (BE)
            4'b1000: begin 
              DATAO = {REGS[t.rs2][7:0],{24{1'b0}}};
              MEM[DADDR[`MLEN-1:2]][31:24] = DATAO[31:24];
            end 
            4'b0100: begin
              DATAO = {{8{1'b0}},REGS[t.rs2][7:0],{16{1'b0}}};
              MEM[DADDR[`MLEN-1:2]][23:16] = DATAO[23:16];
            end
            4'b0010: begin 
              DATAO = {{16{1'b0}},REGS[t.rs2][7:0],{8{1'b0}}};
              MEM[DADDR[`MLEN-1:2]][15:8] = DATAO[15:8];
            end
            4'b0001: begin 
              DATAO = {{24{1'b0}},REGS[t.rs2][7:0]};
              MEM[DADDR[`MLEN-1:2]][7:0] = DATAO[7:0];
            end 
          endcase
        end
        t.pc_val = t.pc_val + 4;
      end
	  SH   : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          case (DADDR[1])
            1: BE = 4'b1100;
            0: BE = 4'b0011;
          endcase
          case (BE)
            4'b1100: begin 
              DATAO = {REGS[t.rs2][15:0],{16{1'b0}}};
              MEM[DADDR[`MLEN-1:2]][31:16] = DATAO[31:16];
            end
            4'b0011: begin 
              DATAO = {{16{1'b0}},REGS[t.rs2][15:0]};
              MEM[DADDR[`MLEN-1:2]][15:0] = DATAO[15:0];
            end 
          endcase
        end
        t.pc_val = t.pc_val + 4;
      end
      SW   : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
          DADDR = REGS[t.rs1] + imm_val_sign_ext;
          DATAO = REGS[t.rs2];
          BE = 4'b1111;
          MEM[DADDR[`MLEN-1:2]] = DATAO;
        end
        t.pc_val = t.pc_val + 4;
      end
      // S-B-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
      BEQ  : begin
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
          JREQ = REGS[t.rs1] == REGS[t.rs2];
          case(JREQ)
            0 : t.pc_val = t.pc_val + 4;
            1 : t.pc_val = t.pc_val + imm_val_sign_ext;
          endcase
        end else begin 
          t.pc_val = t.pc_val + 4;
        end
      end
      BNE  : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          JREQ = REGS[t.rs1] != REGS[t.rs2];
          case(JREQ)
            0 : t.pc_val = t.pc_val + 4;
            1 : t.pc_val = t.pc_val + imm_val_sign_ext;
          endcase
        end else begin
		      t.pc_val = t.pc_val + 4;
        end
      end
      BLT  : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
            JREQ = $signed(REGS[t.rs1]) < $signed(REGS[t.rs2]);
            case(JREQ)
              0 : t.pc_val = t.pc_val + 4;
              1 : t.pc_val = t.pc_val + imm_val_sign_ext;
            endcase
        end else begin
		      t.pc_val = t.pc_val + 4;
        end
      end
      BGE  : begin 
        if (!(|FLUSH)) begin
          imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
          JREQ = $signed(REGS[t.rs1]) >= $signed(REGS[t.rs2]);
          case(JREQ)
            0 : t.pc_val = t.pc_val + 4;
            1 : t.pc_val = t.pc_val + imm_val_sign_ext;
          endcase
        end else begin
		      t.pc_val = t.pc_val + 4;
        end
      end
      BLTU : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
            JREQ = REGS[t.rs1] < REGS[t.rs2];
            case(JREQ)
              0 : t.pc_val = t.pc_val + 4;
              1 : t.pc_val = t.pc_val + imm_val_sign_ext;
            endcase
        end else begin
		      t.pc_val = t.pc_val + 4;
        end
      end
      BGEU : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]};
        	JREQ = REGS[t.rs1] >= REGS[t.rs2];
        	case(JREQ)
        	  0 : t.pc_val = t.pc_val + 4;
              1 : t.pc_val = t.pc_val + imm_val_sign_ext;
        	endcase
        end else begin
		      t.pc_val = t.pc_val + 4;
        end
      end
      // J-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
      JAL  : begin  // JAL with rd = 0x is a plain jump
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
        	REGS[t.rdd] = t.pc_val+4;
        	t.pc_val = t.pc_val + imm_val_sign_ext;  
        	JREQ = 1;
        end else begin
      	  t.pc_val = t.pc_val + 4; 
        end
      end 
      JALR : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {{11{t.imm_val[20]}}, t.imm_val[20:0]}; 
            REGS[t.rdd] = t.pc_val+4;
            t.pc_val = REGS[t.rs1] + imm_val_sign_ext;
            JREQ = 1;
        end else begin
          t.pc_val = t.pc_val + 4; 
        end
      end
      // U-Type
      LUI  : begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {t.imm_val[20:0], {11{1'b0}}}; 
        	REGS[t.rdd] = imm_val_sign_ext;
        end
          t.pc_val = t.pc_val + 4;
      end 
      AUIPC: begin 
        if (!(|FLUSH)) begin
        	imm_val_sign_ext = {t.imm_val[20:0], {11{1'b0}}}; 
        	REGS[t.rdd] = t.pc_val + imm_val_sign_ext;
        end
          t.pc_val = t.pc_val + 4;
      end
    endcase
    
    // Assign Value that was supposed to be for reg0 to a fake reg
    fake_reg0 = REGS[t.rdd];
    // Keep Register 0 to value 0
    REGS[0] = 0;   
    // Update Predicted Values
    pc_val_upd  = t.pc_val;
    // FLUSH Handeling
    if (|FLUSH)
      begin 
        FLUSH = FLUSH - 1;
      end
    if (JREQ == 1 && !(|FLUSH))
      begin 
      	FLUSH = 2;
      end
    /*
    The following are also Predicted: 
    imm_val_sign_ext
    DATAI
    DATAO
    DADDR
	  REGS
    MEM
    */

    // Write prediction to the FIFO
    pred_t transaction = new();
    /*
    transaction.pc_val = pc_val_upd;
    transaction.imm_val_sign_ext = imm_val_sign_ext;
    transaction.rx_funct = rx_funct;
    transaction.rs1_val = t.rs1_val;
    transaction.rs2_val = t.rs2_val;
    transaction.rdd_val = t.rdd;
    transaction.rs1_val_mem = REGS[t.rs1_val];
    transaction.rs2_val_mem = REGS[t.rs2_val];
    transaction.rdd_val_mem = REGS[t.rdd];
    */
    ref_model_fifo.write_item(pred);  

  endfunction
    
endclass

// https://nandland.com/shift-operator/