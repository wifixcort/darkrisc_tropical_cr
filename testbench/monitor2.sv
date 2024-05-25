import instructions_data_struc::*;

// `define __DB_ENABLE__
// `define __DB_PASS__

`define RMDATA top.soc0.core0.RMDATA

`define XIDATA top.soc0.core0.XIDATA
`define DPTR top.soc0.core0.DPTR
`define S1PTR top.soc0.core0.S1PTR
`define S1REG top.soc0.core0.S1REG
`define U1REG top.soc0.core0.U1REG
`define S2PTR top.soc0.core0.S2PTR
`define S2REG top.soc0.core0.S2REG
`define U2REG top.soc0.core0.U2REG
`define XSIMM top.soc0.core0.XSIMM
`define XUIMM top.soc0.core0.XUIMM
`define FALSE 0
`define TRUE 1

class monitor2;
   // scoreboard sb = new();
   scoreboard sb;

   logic [15:0] inst_counter;
   int			err_count;
   logic [15:0]	display_one;
   logic [31:0]	sinc_count = 0;
   logic [31:0]	sb_rd_reg_value;

   logic		old_pc, old2_pc;

   int			debug_counter_num_inst;
   string		rx_funct_str = "";
   //    function new(); //scoreboard sb
   function new(scoreboard sb); //
      $display("Creating monitor 2");
	  //     this.intf = intf;
	  this.sb = sb;
	  this.inst_counter = 0;
	  this.err_count = 0;
	  this.display_one = 1;
	  this.debug_counter_num_inst = 0;
   endfunction

   task check();
	  debug_counter_num_inst = 0;
	  // this.display_one = 1;
	  forever begin
		 @ (posedge top.CLK);
		 old_pc = top.soc0.core0.IADDR; //Take PC (1 clock in the future, actually)
		 if (top.soc0.core0.IADDR != 0)begin //Waits for first instruction out of reset. // !top.soc0.core0.XRES && |top.soc0.core0.IADDR
			if(top.soc0.core0.OPCODE != 0 )begin 				//Ricardos Sync
			   if (debug_counter_num_inst==0) sb.process_inst(); 		//Fixes a bug which requires initializing the SB by processing the very first instruction
			   sb.process_inst();								//Pop scoreboard info to compare it against actual instruction.
			   if(this.display_one == 1)begin
				  $display(" # | Type | Stat | risv rd p | SB   rd p  | Stat |  Riscv rs1 p | SB   rs1 p | Stat |  Riscv rs2 p | SB   rs2 p | Stat |  Riscv rs2 v | SB   rs2 v | Stat |  Riscv imm v | SB   imm v | Stat | Gen. STATUS ");
				  this.display_one = 0;
			   end
			   sb_rd_reg_value = (top.soc0.core0.DPTR==0)? sb.ref_model.fake_reg0 : sb.ref_model.REGS[sb.rdd_val];
			   case (top.soc0.core0.XIDATA[6:0])
				 R_TYPE: begin
					case({top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]})
					  10'h0: begin //add
						//  cp_mem_w("add", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==ADD)?"ADD":"FUNC ERROR");
						r_type_cheker_rd_rs1_rs2("ADD",ADD, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
					  end
					  10'b0100000000: begin //sub 
						//  cp_mem_w("sbu", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SUB)?"SUB":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
						r_type_cheker_rd_rs1_rs2("SBU",SUB, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
					  end
					  SLL_FC: begin //sll
						r_type_cheker_rd_rs1_rs2("SLL",SLL, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("sll", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLL)?"SLL":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  SLT_FC: begin //slt
						r_type_cheker_rd_rs1_rs2("SLT",SLT, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("slt", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLT)?"SLT":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  SLTU_FC: begin //sltu
						r_type_cheker_rd_rs1_rs2("SLTU",SLTU, `DPTR, `RMDATA, `S1PTR, `U1REG, `S2PTR, `U2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("sltu", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLTU)?"SLTU":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  XOR_FC: begin //xor
						r_type_cheker_rd_rs1_rs2("XOR",XOR, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("xor", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==XOR)?"XOR":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  9'h005: begin //srl
						r_type_cheker_rd_rs1_rs2("SRL",SRL, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("srl", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SRL)?"SRL":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  9'h105: begin //sra
						r_type_cheker_rd_rs1_rs2("SRA",SRA, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("sra", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SRA)?"SRA":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  OR_FC: begin //or
						r_type_cheker_rd_rs1_rs2("OR",OR, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("or", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==OR)?"OR":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  AND_FC: begin //and
						r_type_cheker_rd_rs1_rs2("AND",AND, `DPTR, `RMDATA, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd_val, sb_rd_reg_value,
						sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
						//  cp_mem_w("and", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==AND)?"AND":($sformatf(rx_funct_str, "%b", "FUNC ERROR")));
					  end
					  default: begin
`ifdef __DB_ENABLE__ 
						 $display("**** Instruccion type R not found = %b PC:%h, sb_pc:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC, sb.pc_val);
						 $display("FC7 = %b, FC3 = %b", top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]);
						 $display("sb_rd_p = %h, sb_rd_val = %d, sb_rs1_p = %h, sb_rs1_val = %d, sb_imm = %d ", sb.rdd_val, sb_rd_reg_value, sb.rs1_val, $signed(sb.ref_model.REGS[sb.rs1_val]), sb.imm_val_sign_ext);
`endif
						 err_count++;
						 //  inst_counter++;
					  end
					endcase
				 end

				 I_TYPE: begin
					if(top.soc0.core0.FCT3 == 3'b101) begin
					   case(top.soc0.core0.XIDATA[31:25])
						 10'h000: begin //srli
							i_type_cheker_rd_rs1_imm("SRLI",SRLI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
													 sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("srli", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SRLI)?"SRLI":"FUNC ERROR");
						 end
						 10'h020: begin //srai
							i_type_cheker_rd_rs1_imm("SRAI",SRAI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("srai", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SRAI)?"SRAI":"FUNC ERROR");
						 end
						 default: begin
`ifdef __DB_ENABLE__ 
							$display("**** Instruccion type I not found = %b PC:%h, sb_pc:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC, sb.pc_val);
							$display("FC3 = %b", top.soc0.core0.XIDATA[14:12]);
`endif
							err_count++;
							// inst_counter++;
						 end
					   endcase
					end else if(top.soc0.core0.FCT3 == 3'b001)begin
					   case(top.soc0.core0.XIDATA[31:25])
						 10'h000: begin //srli
							i_type_cheker_rd_rs1_imm("SLLI",SLLI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("slli", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLLI)?"SLLI":"FUNC ERROR");
						 end
						 default: begin
`ifdef __DB_ENABLE__ 
							$display("**** Instruccion type I not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
							$display("FC3 = %b", top.soc0.core0.XIDATA[14:12]);
`endif
							err_count++;
							// inst_counter++;
						 end
					   endcase
					end else begin
					   case(top.soc0.core0.FCT3)
						 ADDI_FC:begin //addi , logic'(ADDI)
							i_type_cheker_rd_rs1_imm("ADDI", ADDI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("addi", `RMDATA, sb_rd_reg_value, ((sb.rx_funct==ADDI)?"ADDI":"FUNC ERROR"));
						 end
						 SLTI_FC:begin //slti
							i_type_cheker_rd_rs1_imm("SLTI",SLTI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_bb("slti", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLTI)?"SLTI":"FUNC ERROR");					 
						 end
						 SLTIU_FC:begin //sltiu
							i_type_cheker_rd_rs1_imm("SLTIU", SLTIU, `DPTR, `RMDATA, `S1PTR, `U1REG, `XUIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_bb("sltiu", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLTIU)?"SLTIU":"FUNC ERROR");
						 end
						 XORI_FC:begin //xori
							i_type_cheker_rd_rs1_imm("XORI", XORI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("xori", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==XORI)?"XORI":"FUNC ERROR");
						 end
						 ORI_FC:begin //ori
							i_type_cheker_rd_rs1_imm("ORI", ORI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("ori", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==ORI)?"ORI":"FUNC ERROR");
						 end
						 ANDI_FC:begin //andi
							i_type_cheker_rd_rs1_imm("ANDI", ANDI, `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
							sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
							// cp_mem_w("andi", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==ANDI)?"ANDI":"FUNC ERROR");
						 end
						 default: begin
`ifdef __DB_ENABLE__ 
							$display("**** Instruccion type I not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
							$display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
`endif
							err_count++;
							// inst_counter++;
						 end
					   endcase                  
					   
					end
				 end	
				 /*
				  I_L_TYPE: begin
				  case(top.soc0.core0.FCT3)
				  LB_FC: begin //lb
				  cp_mem_b("lb" ,top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.DATAI[7:0]);//top.soc0.core0.LDATA[7:0]
				  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
						   end
				  LH_FC: begin //lh
				  cp_mem_h("lh" ,top.soc0.core0.LDATA[15:0], sb.DATAI[15:0]);
				  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
						   end
				  LW_FC: begin //lw
				  cp_mem_w("lw" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LW)?"LW":"FUNC ERROR");
				  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);
						   end
				  LBU_FC: begin //lbu
				  cp_mem_w("lbu" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LBU)?"LBU":"FUNC ERROR");
				  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
						   end
				  LHU_FC: begin //lhu
				  cp_mem_w("lhu" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LHU)?"LHU":"FUNC ERROR");
				  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
						   end
				  default: begin
				  `ifdef __DB_ENABLE__ 
				  $display("**** Instruccion type IL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
				  $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
				  `endif
				  err_count++;
				  inst_counter++;
						   end
						 endcase
					  end
				  I_JALR_TYPE: begin //jalr
				  case(top.soc0.core0.FCT3)
				  JALR_C: begin
				  // inst_counter++;
						   end
				  default: begin
				  `ifdef __DB_ENABLE__ 
				  $display("**** Instruccion type I_JARL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
				  $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
				  `endif
				  err_count++;
				  inst_counter++;
						   end
						 endcase
					  end	
				  S_TYPE: begin
				  case(top.soc0.core0.FCT3)
				  SB_FC:begin //sb
				  cp_mem_b("sb", top.soc0.core0.SDATA[7:0], sb.DATAO[7:0]);
				  $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);					 
						   end
				  SH_FC:begin //sh
				  cp_mem_h("sh", top.soc0.core0.SDATA[15:0], sb.DATAO[15:0]);
				  $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);			
						   end
				  SW_FC:begin //sw
				  cp_mem_w("sw", top.soc0.core0.SDATA, sb.DATAO, (sb.rx_funct==SW)?"SW":"FUNC ERROR");
				  $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);
						   end
				  default: begin
				  `ifdef __DB_ENABLE__ 
				  $display("**** Instruccion type S not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
				  $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
				  `endif
				  err_count++;
				  inst_counter++;
						   end
						 endcase  
					  end	
				  S_B_TYPE: begin
				  case(top.soc0.core0.FCT3)
				  BEQ_FC: begin //beq
				  // inst_counter++;
				  $display("*********************ALERTA**********************     BEQ    ");
						   end
				  BNE_FC: begin //bne
				  `ifdef __DB_ENABLE__ 
				  //  $display("-> func: BNE <-");
				  $display("*********************ALERTA**********************     BNE    ");
				  `endif
						   end
				  BLT_FC: begin //blt
				  `ifdef __DB_ENABLE__ 
				  //  $display("-> func: BLT <-");
				  $display("*********************ALERTA**********************     BLT    ");
				  `endif
				  // inst_counter++;
						   end
				  BGE_FC: begin //beg
				  `ifdef __DB_ENABLE__ 
				  //  $display("-> func: BEG <-");
				  $display("*********************ALERTA**********************     BEG    ");
				  `endif
				  // inst_counter++;
						   end
				  BLTU_FC: begin //bltu
				  `ifdef __DB_ENABLE__ 
				  //  $display("-> func: BLTU <-");
				  $display("*********************ALERTA**********************     BLTU   ");
				  `endif
				  // inst_counter++;
						   end
				  BGEU_FC: begin //bgeu
				  `ifdef __DB_ENABLE__ 
				  //  $display("-> func: BGEU <-");
				  $display("*********************ALERTA**********************     BGEU    ");
				  `endif
				  // inst_counter++;
						   end
				  default: begin
				  `ifdef __DB_ENABLE__ 
				  $display("**** Instruccion type S_B not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
				  `endif
				  err_count++;
				  //  inst_counter++;
						   end
						 endcase
					  end	
				  J_TYPE: begin
				  // inst_counter++;
				  $display("*********************ALERTA**********************     J_TYPE    ");
					  end
				  LUI_TYPE: begin
				  // inst_counter++;
				  $display("*********************ALERTA**********************     LUI    ");
					  end	
				  AUIPC_TYPE: begin
				  // inst_counter++;
				  //   $display("*********************ALERTA**********************     AUIPC    ");
					  end	
				  **/
				 default: begin
					if(top.soc0.core0.XIDATA != 0) begin
`ifdef __DB_ENABLE__ 
					   // $display("**** Instruccion not found ****");
					   // $display("-> UNKOWN: %b , PC : %h<-", top.soc0.core0.XIDATA, top.soc0.core0.PC);
`endif
					   err_count++; 
					end
				 end
			   endcase
			   debug_counter_num_inst = debug_counter_num_inst+1;     
			end
			inst_counter++;
		 end//Work out of reset
	  end
   endtask

   task s_and_b_print(input logic [7:0]num, input logic [6:0]opcode, input logic [4:0]rs1, input logic [4:0]rs2, input logic [4:0]rd, input logic [20:0]imm);
	  //$display("RISC PC | SB PC VAL IN | SB PC |Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", num, opcode, rs1, rs2, imm);
	  //$display("-----------------------------------------------------------------------------------------------");
   endtask

   task cp_mem_b(string inst ,input logic [7:0] risc_mem, input logic [7:0] sb_mem);
	  inst = inst_resize(inst);
	  if(risc_mem != sb_mem)begin
		 // $display(" %h | %h |       %d         |      %s     |    %h     |    %h     | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X");
		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
`ifdef __DB_ENABLE__
		 $display("rc_pc = %h, rc_rd_p =%h, rc_sr1_p =%h, rc_rs1_val =%d, rc_rs2_p =%h rc_rs2_val =%d | sb_pc = %h, sb_rd_p =%h, sb_sr1_p =%h, sb_rs1_val =%d, sb_rs2_p =%h sb_rs2_val =%d", top.soc0.core0.PC, top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.pc_val, sb.rdd_val, sb.rs1_val, sb.ref_model.REGS[sb.rs1_val],sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
`endif
		 err_count++;
	  end else begin
		 //$display(" %h | %h |        %d         |      %s     |    %h     |    %h     | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS");
	  end
	  inst_counter++;
   endtask

   task cp_mem_h(string inst ,input logic [15:0] risc_mem, input logic [15:0] sb_mem);
	  inst = inst_resize(inst);
	  if(risc_mem != sb_mem)begin
		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 //$display(" %h | %h |        %d         |      %s     |   %h    |   %h    | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X");
		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
`ifdef __DB_ENABLE__
		 $display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1_val =%d, rc_rs2_p =%d rc_rs2_val =%d| sb_rd_p =%d, sb_sr1_p =%d, sb_rs1_val =%d, sb_rs2_p =%d sb_rs2_val =%d", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.rdd_val, sb.rs1_val, sb.ref_model.REGS[sb.rs1_val],sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
`endif			
		 err_count++;
	  end else begin
		 //$display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 //$display(" %h | %h |        %d         |      %s     |   %h    |   %h    | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS");
	  end

	  inst_counter++;
   endtask

   task cp_mem_bb( string inst,input logic risc_mem, input logic sb_mem, string rx_funct);
	  inst = inst_resize(inst);
	  if(risc_mem != sb_mem)begin
		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 //$display(" %h | %h |        %d         |      %s     |     %h     |     %h     | %s | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X", rx_funct);
		 //$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
`ifdef __DB_ENABLE__
		 $display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1_val =%d, rc_rs2_p =%d rc_rs2_val =%d, rc_imm = %b | sb_rd_p =%d, sb_sr1_p =%d, sb_rs1_val =%d, sb_rs2_p =%d sb_rs2_val =%d, sb_imm = %b ", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, top.soc0.core0.XUIMM, sb.rdd_val, sb.rs1_val, sb.ref_model.REGS[sb.rs1_val],sb.rs2_val, sb.ref_model.REGS[sb.rs2_val], sb.imm_val_sign_ext);
`endif			
		 err_count++;
	  end else begin
		 //$display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 //$display(" %h | %h |        %d         |      %s     |     %h     |     %h     | %s | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS", rx_funct);
		 //$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
	  end
	  inst_counter++;
   endtask

   task automatic i_type_cheker_rd_rs1_imm(
										   string			  inst,
										   input logic [7:0]  instruccion,
										   input logic [31:0] risc_rd_p, // riscv rd register pointer
										   input logic [31:0] risc_rd_v, // riscv rd register value
										   input logic [31:0] risc_rs1_p,  // riscv rs1 register pointer
										   input logic [31:0] risc_rs1_v, // riscv rs1 register value
										   input logic [31:0] risc_imm, // riscv immidiate value
										   input logic [31:0] sb_rd_p, // sb rd register pointer
										   input logic [31:0] sb_rd_v, // sb rd register value
										   input logic [31:0] sb_rs1_p, // sb rs1 register pointer
										   input logic [31:0] sb_rs1_v, // sb rs1 register value
										   input logic [31:0] sb_imm); // sb immidiate value

	  bit													  function_check;
	  bit													  rd_p_check;	  
	  bit													  rd_v_check;
	  bit													  rs1_p_check;
	  bit													  rs1_v_check;
	  bit													  imm_check;
	  bit													  general_check;

	  begin
		 
		 inst = inst_resize(inst);
		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
		//  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
		// 											 sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
			inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
		 end else begin
			general_check = `TRUE;//Si paso la prueba
`ifdef __DB_PASS__ 
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
			inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
			// $display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %s", 
			// inst_counter, inst, function_check?"OK":"X", risc_rd_p, sb_rd_p, rd_p_check?"OK":"X", risc_rd_v, sb_rd_v, rd_v_check?"OK":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"OK":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"OK":"X", risc_imm, sb_imm, imm_check?"OK":"X", general_check?"OK":"X");
`endif
		 end
	  end
   endtask: i_type_cheker_rd_rs1_imm

   task r_type_cheker_rd_rs1_rs2(
										   string			  inst,
										   input logic [7:0]  instruccion,
										   input logic [31:0] risc_rd_p, // riscv rd register pointer
										   input logic [31:0] risc_rd_v, // riscv rd register value
										   input logic [31:0] risc_rs1_p,  // riscv rs1 register pointer
										   input logic [31:0] risc_rs1_v, // riscv rs1 register value
										   input logic [31:0] risc_rs2_p, // riscv rs2 register pointer
										   input logic [31:0] risc_rs2_v, // riscv rs2 register value
										   input logic [31:0] sb_rd_p, // sb rd register pointer
										   input logic [31:0] sb_rd_v, // sb rd register value
										   input logic [31:0] sb_rs1_p, // sb rs1 register pointer
										   input logic [31:0] sb_rs1_v, // sb rs1 register value
										   input logic [31:0] sb_rs2_p, // sb rs1 register pointer
										   input logic [31:0] sb_rs2_v ); // sb immidiate value

	  bit													  function_check;
	  bit													  rd_p_check;	  
	  bit													  rd_v_check;
	  bit													  rs1_p_check;
	  bit													  rs1_v_check;
	  bit													  rs2_p_check;
	  bit													  rs2_v_check;
	  bit													  general_check;

	  begin
		 
		 inst = inst_resize(inst);
		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
		 rs2_p_check = (risc_rs2_p == sb_rs2_p) ? `TRUE : `FALSE;
		 rs2_v_check = (risc_rs2_v == sb_rs2_v) ? `TRUE : `FALSE;
		//  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd_val, sb_rd_reg_value,
		// 											 sb.rs1_val, sb.ref_model.REGS[sb.rs1_val], sb.imm_val_sign_ext);
		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !rs2_p_check || !rs2_v_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- |                              *** %s ***", 
			inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", general_check?"PASS":"ERROR");
		 end else begin
			general_check = `TRUE;//Si paso la prueba
`ifdef __DB_PASS__ 
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- |                              *** %s ***", 
			inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", general_check?"PASS":"ERROR");
		 	// $display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %s", 
			// inst_counter, inst, function_check?"OK":"X", risc_rd_p, sb_rd_p, rd_p_check?"OK":"X", risc_rd_v, sb_rd_v, rd_v_check?"OK":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"OK":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"OK":"X", risc_imm, sb_imm, imm_check?"OK":"X", general_check?"OK":"X");
`endif
		 end
	  end
   endtask: r_type_cheker_rd_rs1_rs2

   task cp_mem_w(string inst ,input logic [31:0] risc_mem, input logic [31:0] sb_mem, string rx_funct);
	  inst = inst_resize(inst);
	  if(risc_mem != sb_mem)begin
		 //$display("Inst. N | Inst.Dec/Ex | Darck Inst | SB Inst | Risc MEM | SB MEM | STATUS ");
		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 $display(" %d | %h | %s | %s | %h | %h | %s ", inst_counter, top.soc0.core0.XIDATA, inst, rx_funct, risc_mem, sb_mem, "X");
		 //--$display(" Counter: %d         |      %s     | riscv_mem:%h  | sb_mem:%h  | %s | rx_f:%s",   inst_counter, inst, risc_mem, sb_mem, "X", rx_funct);
		 //--$display("riscv_opcode %h", top.soc0.core0.OPCODE);
		 //--$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
`ifdef __DB_ENABLE__
		 //$display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1_val =%d, rc_rs2_p =%d rc_rs2_val =%d| sb_rd_p =%d, sb_sr1_p =%d, sb_rs1_val =%d, sb_rs2_p =%d sb_rs2_val =%d", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.rdd_val, sb.rs1_val, sb.ref_model.REGS[sb.rs1_val],sb.rs2_val, sb.ref_model.REGS[sb.rs2_val]);
`endif
		 err_count++;
	  end else begin
		 // $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
		 //--$display(" Counter: %d         |      %s     | riscv_mem:%h  | sb_mem:%h  | %s | rx_f:%s",  inst_counter, inst, risc_mem, sb_mem, "PASS", rx_funct);
		 //--$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
		 $display(" %d | %h | %s | %s | %h | %h | %s", inst_counter, top.soc0.core0.XIDATA, inst, rx_funct, risc_mem, sb_mem, "PASS");
		 //  $display("FUNCT 7 = %b , FUNC 3 = %b", top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]);
	  end
	  inst_counter++;
   endtask

   function automatic string inst_resize(string inst);
	  inst = (inst.len() < 3) ? {inst, "   "} :
			 (inst.len() < 4) ? {inst, "  "} :
			 (inst.len() < 5) ? {inst, " "} : inst;
	  return inst;
   endfunction

endclass
