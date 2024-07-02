import instructions_data_struc::*;


class riscv_ref_model extends uvm_component;
   `uvm_component_utils(riscv_ref_model);
   
   // Signals that store predicted value
   logic [31:0] pc_val_upd;
   logic signed [31:0] imm_val_sign_ext;
   logic [31:0]		   DATAI;
   logic [31:0]		   DATAO;
   logic [31:0]		   DADDR;
   logic [3:0]		   BE;
   logic			   JREQ;
   logic [31:0]		   rs1_val_final;
   logic [31:0]		   rs2_val_final;
   logic [31:0]		   rdd_val_final;

   logic [4:0]		   rs1_val_upd;
   logic [4:0]		   rs2_val_upd;
   logic [4:0]		   rdd_val_upd;

   // For debug
   logic [31:0]		   rs1_val_init;
   logic [31:0]		   rs2_val_init;
   logic [31:0]		   rdd_val_init;
   logic [31:0]		   pc_val_in;
   logic [31:0]		   fake_reg0;
   logic [31:0]		   sdata;
   logic [31:0]		   ldata;
   // General Purpose 32x32 bit registers 
   logic [31:0]		   REGS [0:31];
   integer			   i;
   // Memory Model
   logic [31:0]		   MEM [0:2**`MLEN/4-1]; // ro memory
   // FLUSH Counter
   logic [1:0]		   FLUSH;
   // Nota: Funcionalidad de Reset despues del primer reset no implementada, por tanto reset no levanta FLUSH en modelo

   virtual		intf_dmp int_dmp;
   
   // Constructor
   function new(string name = "ref_model", uvm_component parent);
      super.new(name, parent);
      pc_val_upd  = '0;
      pc_val_in   = '0;
      imm_val_sign_ext = '0;
      DATAI = '0;
      DATAO = '0;
      DADDR = '0;
      JREQ  = '0;
      FLUSH = '0;
      sdata = '0;
	  ldata = '0;
      // Loop to initialize all registers to zero
      for (i = 0; i < 32; i = i + 1) begin
		 REGS[i] = '0;
      end
	  //$readmemh("darksocv.mem",MEM,0);
   endfunction
   
   // Build Phase 
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // Instance of the analysis ports
      //ap_ref_model = new("ap_ref_model", this);
      //ref_model_fifo = new("ref_model_fifo", this);
	  if(uvm_config_db #(virtual intf_dmp)::get(this, "", "VIRTUAL_INTERFACE_DMP", int_dmp) == 0) begin
		`uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface dmp for the TB")
	 end
   endfunction 

   virtual task run_phase(uvm_phase phase);
   		super.run_phase(phase);
		// Intialize Memory
   		$readmemh("darksocv.mem",MEM,0);
		// int_dmp.sb_dump =  MEM[465];
	endtask


   function predict(logic [31:0] pc_val, logic [7:0] rx_funct,logic signed [20:0] imm_val,logic [4:0] rs1,logic [4:0] rs2,logic [4:0] rdd);
	
      // L/S: DADDR[31] must equal 0, if not we access I/O peripherals.
      // All instructions shouldnt be allowed to modify register 0 value
      pc_val_in = pc_val; // Copy of the input PC for debug
      rs1_val_init = REGS[rs1]; // Copy of initial rs1 value
      rs2_val_init = REGS[rs2]; // Copy of initial rs2 Value
      rdd_val_init = REGS[rdd]; // Copy of initial rdd Value
      // For each call we clean our internal variables that arent outputs
      JREQ = 0;
      DADDR = 0;
      DATAI = 0;
      BE = 0;
      case (rx_funct)
		// R Type
		ADD  : begin 
           if (!(|FLUSH)) begin
			  REGS[rdd] = REGS[rs1] + REGS[rs2];
           end
           pc_val = pc_val + 4;
		end
		SUB  : begin 
           if (!(|FLUSH)) begin
			  REGS[rdd] = REGS[rs1] - REGS[rs2];
           end
           pc_val = pc_val + 4;
		end
		XOR  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = REGS[rs1] ^ REGS[rs2];
           end
           pc_val = pc_val + 4;
		end
		OR   : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = REGS[rs1] | REGS[rs2];
           end
           pc_val = pc_val + 4;
		end
		AND  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = REGS[rs1] & REGS[rs2];
           end
           pc_val = pc_val + 4;
		end
		SLL  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = REGS[rs1] << (REGS[rs2][4:0]);
           end
           pc_val = pc_val + 4;
		end
		SRL  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = REGS[rs1] >> (REGS[rs2][4:0]);
           end
           pc_val = pc_val + 4;
		end
		SRA  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = $signed(REGS[rs1]) >>> (REGS[rs2][4:0]);
           end
           pc_val = pc_val + 4;
		end
		SLT  : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = ($signed(REGS[rs1]) < $signed(REGS[rs2])) ? 1'b1 : 1'b0;
           end
           pc_val = pc_val + 4;
		end
		SLTU : begin 
           if (!(|FLUSH)) begin
        	  REGS[rdd] = (REGS[rs1] < REGS[rs2]) ? 1'b1 : 1'b0;
           end
           pc_val = pc_val + 4;
		end
		// I Type 
		ADDI : begin //This Operation is always signed
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        	  REGS[rdd] = (REGS[rs1]) + (imm_val_sign_ext);
           end
           pc_val = pc_val + 4;
		end
		XORI : begin
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = REGS[rs1] ^ imm_val_sign_ext;
           end      	
           pc_val = pc_val + 4;
		end
		ORI  : begin
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
        	  REGS[rdd] = REGS[rs1] | imm_val_sign_ext;
           end
           pc_val = pc_val + 4;
		end
		ANDI : begin
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};  
      		  REGS[rdd] = REGS[rs1] & imm_val_sign_ext;
           end
           pc_val = pc_val + 4;
		end
		SLLI : begin
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = REGS[rs1] << (imm_val_sign_ext[4:0]);
           end
           pc_val = pc_val + 4;
		end
		SRLI : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = REGS[rs1] >> (imm_val_sign_ext[4:0]); 
           end
           pc_val = pc_val + 4;
		end
		SRAI : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = $signed(REGS[rs1]) >>> (imm_val_sign_ext[4:0]);
           end
           pc_val = pc_val + 4;
		end
		SLTI : begin
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = ($signed(REGS[rs1]) < imm_val_sign_ext) ? 1'b1 : 1'b0;
           end
           pc_val = pc_val + 4;
		end
		SLTIU: begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{20{1'b0}}, imm_val[11:0]}; // No sign extension required
        	  REGS[rdd] = (REGS[rs1] < imm_val_sign_ext) ? 1'b1 : 1'b0;
           end
           pc_val = pc_val + 4;
		end
		// I-L(load) Type - DADDR[31] must equal 0, if not we access I/O peripherals.
		LB   : begin
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAI = MEM[DADDR[`MLEN-1:2]]; 
			  $display("IADDR = %d, MEM = %h", DADDR[`MLEN-1:2], DATAI);
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
			  REGS[rdd] = DATAI;
			  ldata = REGS[rdd];
           end
           pc_val = pc_val + 4;
		end
		LH   : begin
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAI = MEM[DADDR[`MLEN-1:2]];
			  $display("MEM ADR = %d, MEM = %h", DADDR[`MLEN-1:2], DATAI);
			//   int_dmp.sb_dump =  MEM[465];
			  case (DADDR[1])
				1: BE = 4'b1100;
				0: BE = 4'b0011;
			  endcase
			  case (BE)
				4'b1100: DATAI = {{16{DATAI[31]}},DATAI[31:16]};
				4'b0011: DATAI = {{16{DATAI[15]}},DATAI[15:0]};
			  endcase
			  REGS[rdd] = DATAI;
			  ldata = REGS[rdd];
           end
           pc_val = pc_val + 4;
		end
		LW   : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAI = MEM[DADDR[`MLEN-1:2]];
			  $display("IADDR = %d, MEM = %h", DADDR[`MLEN-1:2], DATAI);
			  BE = 4'b1111;
			  REGS[rdd] = DATAI;
			  ldata = REGS[rdd];
           end
           pc_val = pc_val + 4;
		end
		LBU  : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAI = MEM[DADDR[`MLEN-1:2]];
			  $display("IADDR = %d, MEM = %h", DADDR[`MLEN-1:2], DATAI);
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
			  REGS[rdd] = DATAI;
			  ldata = REGS[rdd];
           end
           pc_val = pc_val + 4;
		end
		LHU  : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAI = MEM[DADDR[`MLEN-1:2]];
			  $display("IADDR = %d, MEM = %h", DADDR[`MLEN-1:2], DATAI);
			  case (DADDR[1])
				1: BE = 4'b1100;
				0: BE = 4'b0011;
			  endcase
			  case (BE)
				4'b1100: DATAI = {{16{1'b0}},DATAI[31:16]};
				4'b0011: DATAI = {{16{1'b0}},DATAI[15:0]};
			  endcase
			  REGS[rdd] = DATAI;
			  ldata = REGS[rdd];
           end
           pc_val = pc_val + 4;
		end 
		// S-Type - DADDR[31] must equal 0, if not we access I/O peripherals.
		SB   : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  case (DADDR[1:0])
				3: BE = 4'b1000;
				2: BE = 4'b0100;
				1: BE = 4'b0010;
				0: BE = 4'b0001;
			  endcase
			  case (BE)
				4'b1000: begin 
				   DATAO = {REGS[rs2][7:0],{24{1'b0}}};
				   MEM[DADDR[`MLEN-1:2]][31:24] = DATAO[31:24];
				   sdata = DATAO;
				end 
				4'b0100: begin
				   DATAO = {{8{1'b0}},REGS[rs2][7:0],{16{1'b0}}};
				   MEM[DADDR[`MLEN-1:2]][23:16] = DATAO[23:16];
				   sdata = DATAO;
				end
				4'b0010: begin 
				   DATAO = {{16{1'b0}},REGS[rs2][7:0],{8{1'b0}}};
				   MEM[DADDR[`MLEN-1:2]][15:8] = DATAO[15:8];
				   sdata = DATAO;
				end
				4'b0001: begin 
				   DATAO = {{24{1'b0}},REGS[rs2][7:0]};
				   MEM[DADDR[`MLEN-1:2]][7:0] = DATAO[7:0];
				   sdata = DATAO;
				end 
			  endcase
           end
           pc_val = pc_val + 4;
		end
		SH   : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  case (DADDR[1])
				1: BE = 4'b1100;
				0: BE = 4'b0011;
			  endcase
			  case (BE)
				4'b1100: begin 
				   DATAO = {REGS[rs2][15:0],{16{1'b0}}};
				   MEM[DADDR[`MLEN-1:2]][31:16] = DATAO[31:16];
				   sdata = DATAO;
				end
				4'b0011: begin 
				   DATAO = {{16{1'b0}},REGS[rs2][15:0]};
				   MEM[DADDR[`MLEN-1:2]][15:0] = DATAO[15:0];
				   sdata = DATAO;
				end 
			  endcase
           end
           pc_val = pc_val + 4;
		end
		SW   : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
			  DADDR = REGS[rs1] + imm_val_sign_ext;
			  DATAO = REGS[rs2];
			  BE = 4'b1111;
			  MEM[DADDR[`MLEN-1:2]] = DATAO;
			  sdata = DATAO;
           end
           pc_val = pc_val + 4;
		end
		// S-B-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
		BEQ  : begin
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
			  JREQ = REGS[rs1] == REGS[rs2];
			  case(JREQ)
				0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
			  endcase
           end else begin 
			  pc_val = pc_val + 4;
           end
		end
		BNE  : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  JREQ = REGS[rs1] != REGS[rs2];
			  case(JREQ)
				0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
			  endcase
           end else begin
		      pc_val = pc_val + 4;
           end
		end
		BLT  : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
              JREQ = $signed(REGS[rs1]) < $signed(REGS[rs2]);
              case(JREQ)
				0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
              endcase
           end else begin
		      pc_val = pc_val + 4;
           end
		end
		BGE  : begin 
           if (!(|FLUSH)) begin
			  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
			  JREQ = $signed(REGS[rs1]) >= $signed(REGS[rs2]);
			  case(JREQ)
				0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
			  endcase
           end else begin
		      pc_val = pc_val + 4;
           end
		end
		BLTU : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
              JREQ = REGS[rs1] < REGS[rs2];
              case(JREQ)
				0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
              endcase
           end else begin
		      pc_val = pc_val + 4;
           end
		end
		BGEU : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]};
        	  JREQ = REGS[rs1] >= REGS[rs2];
        	  case(JREQ)
        		0 : pc_val = pc_val + 4;
				1 : pc_val = pc_val + imm_val_sign_ext;
        	  endcase
           end else begin
		      pc_val = pc_val + 4;
           end
		end
		// J-Type // Stimulus should have a constrain of making imm 4 bit multiple -> 2 LSB=0, for memory alignment
		JAL  : begin  // JAL with rd = 0x is a plain jump
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
        	  REGS[rdd] = pc_val+4;
        	  pc_val = pc_val + imm_val_sign_ext;  
        	  JREQ = 1;
           end else begin
      		  pc_val = pc_val + 4; 
           end
		end 
		JALR : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {{11{imm_val[20]}}, imm_val[20:0]}; 
              REGS[rdd] = pc_val+4;
              pc_val = REGS[rs1] + imm_val_sign_ext;
              JREQ = 1;
           end else begin
			  pc_val = pc_val + 4; 
           end
		end
		// U-Type
		LUI  : begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {imm_val[20:0], {11{1'b0}}}; 
           REGS[rdd] = imm_val_sign_ext;
        end
           pc_val = pc_val + 4;
		end 
		AUIPC: begin 
           if (!(|FLUSH)) begin
        	  imm_val_sign_ext = {imm_val[20:0], {11{1'b0}}}; 
           REGS[rdd] = pc_val + imm_val_sign_ext;
        end
           pc_val = pc_val + 4;
		end
      endcase
      
      // Assign Value that was supposed to be for reg0 to a fake reg
      fake_reg0 = REGS[rdd];
      // Keep Register 0 to value 0
      REGS[0] = 0;   
      // Update Predicted Values
      pc_val_upd  = pc_val;
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
      // Update Predicted Values
      pc_val_upd  = pc_val;
      rs1_val_upd = rs1;
      rs2_val_upd = rs2;
      rdd_val_upd = rdd;

      rs1_val_final = REGS[rs1];
      rs2_val_final = REGS[rs2];
      rdd_val_final= REGS[rdd];
   endfunction
   
endclass

// https://nandland.com/shift-operator/
