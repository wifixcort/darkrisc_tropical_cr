import instructions_data_struc::*;

`define __DB_ENABLE__
`define __DB_PASS__

`define RMDATA top.soc0.core0.RMDATA
`define LDATA top.soc0.core0.LDATA
`define SDATA top.soc0.core0.SDATA
`define CORE top.soc0.core0

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
`define DATAO top.soc0.core0.DATAO

`define FALSE 0
`define TRUE 1

typedef struct {
   string	   inst;
   logic [7:0] instruccion;
   logic [31:0]	risc_rd_p; // riscv rd register pointer
   logic [31:0]	risc_rd_v; // riscv rd register value
   logic [31:0]	risc_rs1_p; // riscv rs1 register pointer
   logic [31:0]	risc_rs1_v; // riscv rs1 register value
   logic [31:0]	risc_rs2_p; // riscv rs1 register pointer
   logic [31:0]	risc_rs2_v; // riscv rs1 register value
   logic [31:0]	risc_imm; // riscv immidiate value
   logic [31:0]	sb_rd_p; // sb rd register pointer
   logic [31:0]	sb_rd_v; // sb rd register value
   logic [31:0]	sb_rs1_p; // sb rs1 register pointer
   logic [31:0]	sb_rs1_v; // sb rs1 register value
   logic [31:0]	sb_rs2_p; // sb rs1 register pointer
   logic [31:0]	sb_rs2_v; // sb rs1 register value
   logic [31:0]	sb_imm; // sb immidiate value

   logic [31:0]	inst_PC;
   logic [31:0]	inst_XIDATA;
   logic [31:0]	sb_DADDR;
   logic [31:0]	sb_DATAI;
}ExData;

class monitor2;
   scoreboard sb;
   ExData ex_dbuf;

   logic [15:0]	inst_counter;
   int			err_count;
   logic [15:0]	display_one;
   logic [31:0]	sinc_count = 0;
   logic [31:0]	sb_rd_reg_value;
   logic [31:0]	risc_rd_reg_value;

   //    logic		old_pc, old2_pc;

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
	  this.risc_rd_reg_value = '0;
	  this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
	  				   risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
	  				   sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0, inst_PC : '0, 
					   inst_XIDATA : '0, sb_DADDR : '0, sb_DATAI : '0};
   endfunction

   task check();
	  forever begin

		 @ (posedge top.CLK);// begin//
		 //  @ (top.soc0.core0.IADDR);// begin	
		 //  old_pc = top.soc0.core0.IADDR; //Take PC (1 clock in the future, actually)
		 if(`CORE.NXPC != 0)begin //Revisar un ciclo despues
		 	// if(inst_counter < 100)begin 
			// 	$display("DPTR = %h",ex_dbuf.risc_rd_p);
			// end
			//R TYPE
			if(ex_dbuf.instruccion == ADD || ex_dbuf.instruccion == SUB || ex_dbuf.instruccion == SLL || ex_dbuf.instruccion == SLT || 
			   ex_dbuf.instruccion == SLTU || ex_dbuf.instruccion == XOR || ex_dbuf.instruccion == SRL || ex_dbuf.instruccion == SRA || 
			   ex_dbuf.instruccion == AND || ex_dbuf.instruccion == OR)begin
			   $display("-------------------------------------------------------------------------------------------->");
			   r_type_cheker_rd_rs1_rs2(ex_dbuf.inst ,ex_dbuf.instruccion, ex_dbuf.risc_rd_p, `CORE.REGS[ex_dbuf.risc_rd_p], 
										ex_dbuf.risc_rs1_p, ex_dbuf.risc_rs1_v, ex_dbuf.risc_rs2_p, ex_dbuf.risc_rs2_v, ex_dbuf.sb_rd_p,
										ex_dbuf.sb_rd_v, ex_dbuf.sb_rs1_p, ex_dbuf.sb_rs1_v, ex_dbuf.sb_rs2_p, ex_dbuf.sb_rs2_v);
			   $display("--------------------------------------------------------------------------------------------<");
			   //Clear this buffer
			   this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
								risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
								sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0, inst_PC : '0, 
								inst_XIDATA : '0, sb_DADDR : '0, sb_DATAI : '0};
			   
			   //I TYPE
			end	else if(ex_dbuf.instruccion == ADDI || ex_dbuf.instruccion == SLTI || ex_dbuf.instruccion == SLTIU || ex_dbuf.instruccion == XORI ||
						ex_dbuf.instruccion == ORI || ex_dbuf.instruccion == ANDI || ex_dbuf.instruccion == SLLI || ex_dbuf.instruccion == SRLI ||
						ex_dbuf.instruccion == SRAI)begin
			   $display("-------------------------------------------------------------------------------------------->");
			   i_type_cheker_rd_rs1_imm(ex_dbuf.inst ,ex_dbuf.instruccion, ex_dbuf.risc_rd_p, `CORE.REGS[ex_dbuf.risc_rd_p], 
										ex_dbuf.risc_rs1_p, ex_dbuf.risc_rs1_v, ex_dbuf.risc_imm, ex_dbuf.sb_rd_p, ex_dbuf.sb_rd_v,
										ex_dbuf.sb_rs1_p, ex_dbuf.sb_rs1_v, ex_dbuf.sb_imm);
			   $display("--------------------------------------------------------------------------------------------<");
			   //Clear this buffer
			   this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
								risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
								sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0, inst_PC : '0, 
								inst_XIDATA : '0, sb_DADDR : '0, sb_DATAI : '0};
			end else if(ex_dbuf.instruccion == LB || ex_dbuf.instruccion == LH || ex_dbuf.instruccion == LW || ex_dbuf.instruccion == LBU || 
						ex_dbuf.instruccion == LHU) begin
			   $display("-------------------------------------------------------------------------------------------->");
			   i_l_type_cheker_rd_imm_rs1(ex_dbuf.inst ,ex_dbuf.instruccion, ex_dbuf.risc_rd_p, ex_dbuf.risc_rd_v, 
										  ex_dbuf.risc_rs1_p, ex_dbuf.risc_rs1_v, ex_dbuf.risc_imm, ex_dbuf.sb_rd_p, ex_dbuf.sb_rd_v,
										  ex_dbuf.sb_rs1_p, ex_dbuf.sb_rs1_v, ex_dbuf.sb_imm);
			   $display("--------------------------------------------------------------------------------------------<");
			   //Clear this buffer
			   this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
								risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
								sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0, inst_PC : '0, 
								inst_XIDATA : '0, sb_DADDR : '0, sb_DATAI : '0};
			end
		 end

		 if (`CORE.IADDR != 0)begin //Waits for first instruction out of reset. // !top.soc0.core0.XRES && |top.soc0.core0.IADDR
			if (`CORE.HLT == 0) begin //For get correct values from two clock cicle instructions
			   if (inst_counter == 0)begin
				  sb.process_inst(); 		//Fixes a bug which requires initializing the SB by processing the very first instruction
				  inst_counter++;
				  continue; //Jump to the start of forever to avoid first invalid instruction from the scoreboard
			   end
			   sb.process_inst();						//Pop scoreboard info to compare it against actual instruction.
			   if(this.display_one == 1)begin
				  $display(" # | Type | Stat | risv rd p | SB   rd p  | Stat |  Riscv rs1 p | SB   rs1 p | Stat |  Riscv rs2 p | SB   rs2 p | Stat |  Riscv rs2 v | SB   rs2 v | Stat |  Riscv imm v | SB   imm v | Stat | Gen. STATUS ");
				  this.display_one = 0;
			   end
			   sb_rd_reg_value = sb.ref_model.REGS[sb.rdd];//(top.soc0.core0.DPTR==0)? sb.ref_model.fake_reg0 : sb.ref_model.REGS[sb.rdd];
			   // end 
			   case (`CORE.XIDATA[6:0])
				 R_TYPE: begin
					risc_rd_reg_value = (`CORE.DPTR==0)? `CORE.REGS[`DPTR] : `RMDATA;
					case({`CORE.XIDATA[31:25], `CORE.XIDATA[14:12]})
					  10'h0: begin //add
						 //  ex_dbuf = '{inst : "ADD", instruccion : ADD, risc_rd_p : `DPTR, risc_rd_v : risc_rd_reg_value, risc_rs1_p : `S1PTR, 
						 //  risc_rs1_v : `S1REG, risc_rs2_p : `S2PTR, risc_rs2_v : `S2REG, risc_imm : `XSIMM, sb_rd_p : sb.rdd, sb_rd_v : sb_rd_reg_value,
						 //  sb_rs1_p : sb.rs1, sb_rs1_v : sb.rs1_val_ini, sb_rs2_p : sb.rs2, sb_rs2_v : sb.rs2_val_ini, sb_imm : sb.imm_val_sign_ext};
						 ex_dbuf.inst = "ADD";
						 ex_dbuf.instruccion = ADD;
						 //  r_type_cheker_rd_rs1_rs2("ADD",ADD, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  10'b0100000000: begin //sub 
						 ex_dbuf.inst = "SUB";
						 ex_dbuf.instruccion = SUB;
						 //  r_type_cheker_rd_rs1_rs2("SBU",SUB, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  SLL_FC: begin //sll
						 ex_dbuf.inst = "SLL";
						 ex_dbuf.instruccion = SLL;
						 //  r_type_cheker_rd_rs1_rs2("SLL",SLL, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  SLT_FC: begin //slt
						 ex_dbuf.inst = "SLT";
						 ex_dbuf.instruccion = SLT;
						 //  r_type_cheker_rd_rs1_rs2("SLT",SLT, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  SLTU_FC: begin //sltu
						 ex_dbuf.inst = "SLTU";
						 ex_dbuf.instruccion = SLTU;
						 //  r_type_cheker_rd_rs1_rs2("SLTU",SLTU, `DPTR, risc_rd_reg_value, `S1PTR, `U1REG, `S2PTR, `U2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  XOR_FC: begin //xor
						 ex_dbuf.inst = "XOR";
						 ex_dbuf.instruccion = XOR;
						 //  r_type_cheker_rd_rs1_rs2("XOR",XOR, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  9'h005: begin //srl
						 ex_dbuf.inst = "SRL";
						 ex_dbuf.instruccion = SRL;
						 //  r_type_cheker_rd_rs1_rs2("SRL",SRL, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  9'h105: begin //sra
						 ex_dbuf.inst = "SRA";
						 ex_dbuf.instruccion = SRA;
						 //  r_type_cheker_rd_rs1_rs2("SRA",SRA, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  OR_FC: begin //or
						 ex_dbuf.inst = "OR";
						 ex_dbuf.instruccion = OR;
						 //  r_type_cheker_rd_rs1_rs2("OR",OR, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  AND_FC: begin //and
						 ex_dbuf.inst = "AND";
						 ex_dbuf.instruccion = AND;
						 //  r_type_cheker_rd_rs1_rs2("AND",AND, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `S2PTR, `S2REG, sb.rdd, sb_rd_reg_value,
						 // 						  sb.rs1, sb.rs1_val_ini, sb.rs2, sb.rs2_val_ini);
					  end
					  default: begin
`ifdef __DB_ENABLE__ 
						 $display("**** Instruccion type R not found = %b PC:%h, sb_pc:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC, sb.pc_val);
						 $display("FC7 = %b, FC3 = %b", top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]);
						 $display("sb_rd_p = %h, sb_rd_val = %d, sb_rs1_p = %h, sb_rs1 = %d, sb_imm = %d ", sb.rdd, sb_rd_reg_value, sb.rs1, $signed(sb.rs1_val_ini), sb.imm_val_sign_ext);
`endif
						 err_count++;
						 //  inst_counter++;
					  end
					endcase
				 end

				 I_TYPE: begin
					risc_rd_reg_value = (top.soc0.core0.DPTR==0)? top.soc0.core0.REGS[`DPTR] : `RMDATA;
					if(top.soc0.core0.FCT3 == 3'b101) begin
					   case(top.soc0.core0.XIDATA[31:25])
						 10'h000: begin //srli
							ex_dbuf.inst = "SRLI";
							ex_dbuf.instruccion = SRLI;
							// i_type_cheker_rd_rs1_imm("SRLI",SRLI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_w("srli", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SRLI)?"SRLI":"FUNC ERROR");
						 end
						 10'h020: begin //srai
							ex_dbuf.inst = "SRAI";
							ex_dbuf.instruccion = SRAI;
							// i_type_cheker_rd_rs1_imm("SRAI",SRAI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
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
						 10'h000: begin //slli
							ex_dbuf.inst = "SLLI";
							ex_dbuf.instruccion = SLLI;
							// i_type_cheker_rd_rs1_imm("SLLI",SLLI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
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
							ex_dbuf.inst = "ADDI";
							ex_dbuf.instruccion = ADDI;
							// i_type_cheker_rd_rs1_imm("ADDI", ADDI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_w("addi", `RMDATA, sb_rd_reg_value, ((sb.rx_funct==ADDI)?"ADDI":"FUNC ERROR"));
						 end
						 SLTI_FC:begin //slti
							ex_dbuf.inst = "SLTI";
							ex_dbuf.instruccion = SLTI;
							// i_type_cheker_rd_rs1_imm("SLTI",SLTI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_bb("slti", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLTI)?"SLTI":"FUNC ERROR");					 
						 end
						 SLTIU_FC:begin //sltiu
							ex_dbuf.inst = "SLTIU";
							ex_dbuf.instruccion = SLTIU;
							// i_type_cheker_rd_rs1_imm("SLTIU", SLTIU, `DPTR, risc_rd_reg_value, `S1PTR, `U1REG, `XUIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_bb("sltiu", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==SLTIU)?"SLTIU":"FUNC ERROR");
						 end
						 XORI_FC:begin //xori
							ex_dbuf.inst = "XORI";
							ex_dbuf.instruccion = XORI;
							// i_type_cheker_rd_rs1_imm("XORI", XORI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_w("xori", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==XORI)?"XORI":"FUNC ERROR");
						 end
						 ORI_FC:begin //ori
							ex_dbuf.inst = "ORI";
							ex_dbuf.instruccion = ORI;
							// i_type_cheker_rd_rs1_imm("ORI", ORI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
							// cp_mem_w("ori", top.soc0.core0.RMDATA, sb_rd_reg_value, (sb.rx_funct==ORI)?"ORI":"FUNC ERROR");
						 end
						 ANDI_FC:begin //andi
							ex_dbuf.inst = "ANDI";
							ex_dbuf.instruccion = ANDI;
							// i_type_cheker_rd_rs1_imm("ANDI", ANDI, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
							// 						 sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
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
				 
				 I_L_TYPE: begin
					risc_rd_reg_value = (top.soc0.core0.DPTR==0)? top.soc0.core0.REGS[`DPTR] : `LDATA;
					case(top.soc0.core0.FCT3)
					  LB_FC: begin //lb
						 ex_dbuf.inst = "LB";
						 ex_dbuf.instruccion = LB;
						 //  i_l_type_cheker_rd_imm_rs1("LB", LB, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
						 // 							sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
						 //  $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
						 //cp_mem_b("lb" ,top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.DATAI[7:0]);//top.soc0.core0.LDATA[7:0]
						 //$display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
					  end
					  LH_FC: begin //lh
						 ex_dbuf.inst = "LH";
						 ex_dbuf.instruccion = LH;
						 //  i_l_type_cheker_rd_imm_rs1("LH", LH, `DPTR, risc_rd_reg_value/*`LDATA*/, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
						 // 							sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
						 //  $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
						 //  cp_mem_h("lh" ,top.soc0.core0.LDATA[15:0], sb.DATAI[15:0]);
						 //  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
					  end
					  LW_FC: begin //lw
						 ex_dbuf.inst = "LW";
						 ex_dbuf.instruccion = LW;
						 //  i_l_type_cheker_rd_imm_rs1("LW", LW, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
						 // 							sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);//top.soc0.core0.REGS[`DPTR]
						 //  $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
						 //  cp_mem_w("lw" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LW)?"LW":"FUNC ERROR");
						 //  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);
					  end
					  LBU_FC: begin //lbu
						 ex_dbuf.inst = "LBU";
						 ex_dbuf.instruccion = LBU;
						 //  i_l_type_cheker_rd_imm_rs1("LBU", LBU, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
						 // 							sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
						 //  $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
						 //  cp_mem_w("lbu" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LBU)?"LBU":"FUNC ERROR");
						 //  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
					  end
					  LHU_FC: begin //lhu
						 ex_dbuf.inst = "LHU";
						 ex_dbuf.instruccion = LHU;
						 //  i_l_type_cheker_rd_imm_rs1("LHU", LHU, `DPTR, risc_rd_reg_value, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
						 // 							sb.rs1, sb.rs1_val_ini, sb.imm_val_sign_ext);
						 //  $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
						 //  cp_mem_w("lhu" ,top.soc0.core0.LDATA, sb.DATAI, (sb.rx_funct==LHU)?"LHU":"FUNC ERROR");
						 //  $display("rc_imm = %d  ,  sb_imm = %d", $signed(top.soc0.core0.XSIMM), sb.imm_val_sign_ext);	
					  end
					  default: begin
`ifdef __DB_ENABLE__ 
						 $display("**** Instruccion type IL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
						 $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
`endif
						 err_count++;
						 //  inst_counter++;
					  end
					endcase
				 end
				 I_JALR_TYPE: begin //jalr
					case(top.soc0.core0.FCT3)
					  JALR_C: begin
						 // inst_counter++;
						 // $display("*********************ALERTA**********************     I_JALR    ");
					  end
					  default: begin
`ifdef __DB_ENABLE__ 
						 $display("**** Instruccion type I_JARL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
						 $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
`endif
						 err_count++;
						 //inst_counter++;
					  end
					endcase
				 end	
				 S_TYPE: begin
					case(top.soc0.core0.FCT3)
					  SB_FC:begin //sb
						 ex_dbuf.inst = "SB";
						 ex_dbuf.instruccion = SB;
						 //  s_type_cheker_rv2_imm_rs1("SB", SB, `SDATA, `S2PTR, `S2REG, `XSIMM, `S1PTR, `S1REG, sb.DATAO, sb.rs2, 
						 // 						   sb.rs2_val_ini, sb.imm_val_sign_ext, sb.rs1, sb.rs1_val_ini);
						 // cp_mem_b("sb", top.soc0.core0.SDATA[7:0], sb.DATAO[7:0]);
						 // $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);					 
					  end
					  SH_FC:begin //sh
						 ex_dbuf.inst = "SH";
						 ex_dbuf.instruccion = SH;
						 //  s_type_cheker_rv2_imm_rs1("SH", SH, `SDATA, `S2PTR, `S2REG, `XSIMM, `S1PTR, `S1REG, sb.DATAO, sb.rs2, 
						 // 						   sb.rs2_val_ini, sb.imm_val_sign_ext, sb.rs1, sb.rs1_val_ini);
						 // cp_mem_h("sh", top.soc0.core0.SDATA[15:0], sb.DATAO[15:0]);
						 // $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);			
					  end
					  SW_FC:begin //sw
						 ex_dbuf.inst = "SW";
						 ex_dbuf.instruccion = SW;
						 //  s_type_cheker_rv2_imm_rs1("SW", SW, `SDATA, `S2PTR, `S2REG, `XSIMM, `S1PTR, `S1REG, sb.DATAO, sb.rs2, 
						 // 						   sb.rs2_val_ini, sb.imm_val_sign_ext, sb.rs1, sb.rs1_val_ini);
						 // cp_mem_w("sw", top.soc0.core0.SDATA, sb.DATAO, (sb.rx_funct==SW)?"SW":"FUNC ERROR");
						 // $display("rc_imm = %d  ,  sb_imm = %d", top.soc0.core0.XSIMM, sb.imm_val_sign_ext);
					  end
					  default: begin
`ifdef __DB_ENABLE__ 
						 $display("**** Instruccion type S not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
						 $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
`endif
						 err_count++;
						 // inst_counter++;
					  end
					endcase  
				 end	
				 S_B_TYPE: begin
					case(top.soc0.core0.FCT3)
					  BEQ_FC: begin //beq
						 // inst_counter++;
`ifdef  __DB_ENABLE__
						 $display("*********************ALERTA**********************     BEQ    ");
`endif
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
`ifdef  __DB_ENABLE__
					$display("*********************ALERTA**********************     J_TYPE    ");
`endif
				 end
				 LUI_TYPE: begin
					// inst_counter++;
`ifdef  __DB_ENABLE__
					$display("*********************ALERTA**********************     LUI    ");
`endif
				 end	
				 AUIPC_TYPE: begin
					// inst_counter++;
`ifdef  __DB_ENABLE__
					// $display("*********************ALERTA**********************     AUIPC    ");
`endif
				 end	
				 
				 default: begin
					if(top.soc0.core0.XIDATA != 0) begin
`ifdef __DB_ENABLE__ 
					   $display("**** Instruccion not found ****");
					   $display("-> UNKOWN: %b , PC : %h<-", top.soc0.core0.XIDATA, top.soc0.core0.PC);
`endif
					   err_count++; 
					end
					
				 end
				 
			   endcase
			   //   debug_counter_num_inst = debug_counter_num_inst+1;  
			   ex_dbuf = '{inst: ex_dbuf.inst, instruccion : ex_dbuf.instruccion, risc_rd_p : `DPTR, risc_rd_v : risc_rd_reg_value, risc_rs1_p : `S1PTR, 
						   risc_rs1_v : `S1REG, risc_rs2_p : `S2PTR, risc_rs2_v : `S2REG, risc_imm : (ex_dbuf.instruccion == SLTIU ? `XUIMM : `XSIMM), sb_rd_p : sb.rdd, sb_rd_v : sb_rd_reg_value,
						   sb_rs1_p : sb.rs1, sb_rs1_v : sb.rs1_val_ini, sb_rs2_p : sb.rs2, sb_rs2_v : sb.rs2_val_ini, sb_imm : sb.imm_val_sign_ext,
						   inst_PC : `CORE.PC, inst_XIDATA : `CORE.XIDATA, sb_DADDR : sb.DADDR, sb_DATAI : sb.DATAI};
			   inst_counter++;   
			end
			
			//  end//Work out of reset
		 end
		 //end
		 //  @ (top.soc0.core0.IADDR);//begin
		 // $display("IADDR = %h, Instruction %s", top.soc0.core0.IADDR, ex_dbuf.inst);
		 // this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
		 // risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
		 // sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0};
		 //end
	  end
	  $display("Total error count : %d", err_count);
	  $display("------------------------------ End of checks ------------------------------ ");


   endtask

   //    task s_and_b_print(input logic [7:0]num, input logic [6:0]opcode, input logic [4:0]rs1, input logic [4:0]rs2, input logic [4:0]rd, input logic [20:0]imm);
   // 	  //$display("RISC PC | SB PC VAL IN | SB PC |Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", num, opcode, rs1, rs2, imm);
   // 	  //$display("-----------------------------------------------------------------------------------------------");
   //    endtask

   //    task cp_mem_b(string inst ,input logic [7:0] risc_mem, input logic [7:0] sb_mem);
   // 	  inst = inst_resize(inst);
   // 	  if(risc_mem != sb_mem)begin
   // 		 // $display(" %h | %h |       %d         |      %s     |    %h     |    %h     | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X");
   // 		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
   // `ifdef __DB_ENABLE__
   // 		 $display("rc_pc = %h, rc_rd_p =%h, rc_sr1_p =%h, rc_rs1 =%d, rc_rs2_p =%h rc_rs2 =%d | sb_pc = %h, sb_rd_p =%h, sb_sr1_p =%h, sb_rs1 =%d, sb_rs2_p =%h sb_rs2 =%d", top.soc0.core0.PC, top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.pc_val, sb.rdd, sb.rs1, sb.ref_model.REGS[sb.rs1],sb.rs2, sb.ref_model.REGS[sb.rs2]);
   // `endif
   // 		 err_count++;
   // 	  end else begin
   // 		 //$display(" %h | %h |        %d         |      %s     |    %h     |    %h     | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS");
   // 	  end
   // 	  //   inst_counter++;
   //    endtask

   //    task cp_mem_h(string inst ,input logic [15:0] risc_mem, input logic [15:0] sb_mem);
   // 	  inst = inst_resize(inst);
   // 	  if(risc_mem != sb_mem)begin
   // 		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 //$display(" %h | %h |        %d         |      %s     |   %h    |   %h    | %s ", top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X");
   // 		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
   // `ifdef __DB_ENABLE__
   // 		 $display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1 =%d, rc_rs2_p =%d rc_rs2 =%d| sb_rd_p =%d, sb_sr1_p =%d, sb_rs1 =%d, sb_rs2_p =%d sb_rs2 =%d", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.rdd, sb.rs1, sb.ref_model.REGS[sb.rs1],sb.rs2, sb.ref_model.REGS[sb.rs2]);
   // `endif			
   // 		 err_count++;
   // 	  end else begin
   // 		 //$display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 //$display(" %h | %h |        %d         |      %s     |   %h    |   %h    | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS");
   // 	  end

   // 	  //   inst_counter++;
   //    endtask

   //    task cp_mem_bb( string inst,input logic risc_mem, input logic sb_mem, string rx_funct);
   // 	  inst = inst_resize(inst);
   // 	  if(risc_mem != sb_mem)begin
   // 		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 //$display(" %h | %h |        %d         |      %s     |     %h     |     %h     | %s | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "X", rx_funct);
   // 		 //$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
   // 		 //$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
   // `ifdef __DB_ENABLE__
   // 		 $display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1 =%d, rc_rs2_p =%d rc_rs2 =%d, rc_imm = %b | sb_rd_p =%d, sb_sr1_p =%d, sb_rs1 =%d, sb_rs2_p =%d sb_rs2 =%d, sb_imm = %b ", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, top.soc0.core0.XUIMM, sb.rdd, sb.rs1, sb.ref_model.REGS[sb.rs1],sb.rs2, sb.ref_model.REGS[sb.rs2], sb.imm_val_sign_ext);
   // `endif			
   // 		 err_count++;
   // 	  end else begin
   // 		 //$display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 //$display(" %h | %h |        %d         |      %s     |     %h     |     %h     | %s | %s ",  top.soc0.core0.IADDR, sb.pc_val, inst_counter, inst, risc_mem, sb_mem, "PASS", rx_funct);
   // 		 //$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
   // 	  end
   // 	  //   inst_counter++;
   //    endtask

   task automatic i_type_cheker_rd_rs1_imm(
										   string			  inst,
										   input logic [7:0]  instruccion,
										   input logic [31:0] risc_rd_p, // riscv rd register pointer
										   input logic [31:0] risc_rd_v, // riscv rd register value
										   input logic [31:0] risc_rs1_p, // riscv rs1 register pointer
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
		 //  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
		 // 											 sb.rs1, sb.ref_model.REGS[sb.rs1], sb.imm_val_sign_ext);
		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
			$display("PC = %h, inst = %h", top.soc0.core0.PC, `XIDATA);
			$display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
			err_count++; 
		 end else begin
			general_check = `TRUE;//Si paso la prueba
`ifdef __DB_PASS__ 
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
					 $display("PC = %h, inst = %h", top.soc0.core0.PC, `XIDATA);
					 $display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
					 // $display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %s", 
			// inst_counter, inst, function_check?"OK":"X", risc_rd_p, sb_rd_p, rd_p_check?"OK":"X", risc_rd_v, sb_rd_v, rd_v_check?"OK":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"OK":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"OK":"X", risc_imm, sb_imm, imm_check?"OK":"X", general_check?"OK":"X");
`endif
		 end
	  end
   endtask: i_type_cheker_rd_rs1_imm

   task r_type_cheker_rd_rs1_rs2(
								 string				inst,
								 input logic [7:0]	instruccion,
								 input logic [31:0]	risc_rd_p, // riscv rd register pointer
								 input logic [31:0]	risc_rd_v, // riscv rd register value
								 input logic [31:0]	risc_rs1_p, // riscv rs1 register pointer
								 input logic [31:0]	risc_rs1_v, // riscv rs1 register value
								 input logic [31:0]	risc_rs2_p, // riscv rs2 register pointer
								 input logic [31:0]	risc_rs2_v, // riscv rs2 register value
								 input logic [31:0]	sb_rd_p, // sb rd register pointer
								 input logic [31:0]	sb_rd_v, // sb rd register value
								 input logic [31:0]	sb_rs1_p, // sb rs1 register pointer
								 input logic [31:0]	sb_rs1_v, // sb rs1 register value
								 input logic [31:0]	sb_rs2_p, // sb rs1 register pointer
								 input logic [31:0]	sb_rs2_v ); // sb immidiate value

	  bit											function_check;
	  bit											rd_p_check;	  
	  bit											rd_v_check;
	  bit											rs1_p_check;
	  bit											rs1_v_check;
	  bit											rs2_p_check;
	  bit											rs2_v_check;
	  bit											general_check;

	  begin
		 
		 inst = inst_resize(inst);
		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
		 rs2_p_check = (risc_rs2_p == sb_rs2_p) ? `TRUE : `FALSE;
		 rs2_v_check = (risc_rs2_v == sb_rs2_v) ? `TRUE : `FALSE;
		 //  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
		 // 											 sb.rs1, sb.ref_model.REGS[sb.rs1], sb.imm_val_sign_ext);
		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !rs2_p_check || !rs2_v_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", general_check?"PASS":"ERROR");
			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
			err_count++; 
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

   task automatic i_l_type_cheker_rd_imm_rs1(
											 string				inst,
											 input logic [7:0]	instruccion,
											 input logic [31:0]	risc_rd_p, // riscv rd register pointer
											 input logic [31:0]	risc_rd_v, // riscv rd register value
											 input logic [31:0]	risc_rs1_p, // riscv rs1 register pointer
											 input logic [31:0]	risc_rs1_v, // riscv rs1 register value
											 input logic [31:0]	risc_imm, // riscv immidiate value
											 input logic [31:0]	sb_rd_p, // sb rd register pointer
											 input logic [31:0]	sb_rd_v, // sb rd register value
											 input logic [31:0]	sb_rs1_p, // sb rs1 register pointer
											 input logic [31:0]	sb_rs1_v, // sb rs1 register value
											 input logic [31:0]	sb_imm); // sb immidiate value

	  bit														function_check;
	  bit														rd_p_check;	  
	  bit														rd_v_check;
	  bit														rs1_p_check;
	  bit														rs1_v_check;
	  bit														imm_check;
	  bit														general_check;

	  begin

		 inst = inst_resize(inst);
		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
		 //  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
		 // 											 sb.rs1, sb.ref_model.REGS[sb.rs1], sb.imm_val_sign_ext);
		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
			err_count++; 
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
   endtask: i_l_type_cheker_rd_imm_rs1

   task automatic s_type_cheker_rv2_imm_rs1(
											string			   inst,
											input logic [7:0]  instruccion,
											input logic [31:0] risc_datao_v, // riscv datao register value
											input logic [31:0] risc_rs2_p, // riscv rs2 register pointer
											input logic [31:0] risc_rs2_v, // riscv rs2 register value
											input logic [31:0] risc_imm, // riscv immidiate value
											input logic [31:0] risc_rs1_p, // riscv rs1 register pointer
											input logic [31:0] risc_rs1_v, // riscv rs1 register value
											input logic [31:0] sb_datao_v, // sb dato register value
											input logic [31:0] sb_rs2_p, // sb rs2 register pointer
											input logic [31:0] sb_rs2_v, // sb rs2 register value
											input logic [31:0] sb_imm, // sb immidiate value
											input logic [31:0] sb_rs1_p, // sb rs1 register pointer
											input logic [31:0] sb_rs1_v); // sb rs1 register value

	  bit													   function_check;
	  bit													   datao_v_check;
	  bit													   rs1_p_check;
	  bit													   rs1_v_check;
	  bit													   rs2_p_check;
	  bit													   rs2_v_check;
	  bit													   imm_check;
	  bit													   general_check;

	  begin

		 inst = inst_resize(inst);
		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
		 datao_v_check = (risc_datao_v == sb_datao_v) ? `TRUE : `FALSE;
		 rs2_p_check = (risc_rs2_p == sb_rs2_p) ? `TRUE : `FALSE;
		 rs2_v_check = (risc_rs2_v == sb_rs2_v) ? `TRUE : `FALSE;
		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
		 //  , `DPTR, `RMDATA, `S1PTR, `S1REG, `XSIMM, sb.rdd, sb_rd_reg_value,
		 // 											 sb.rs1, sb.ref_model.REGS[sb.rs1], sb.imm_val_sign_ext);
		 if(!function_check || !datao_v_check || !rs2_p_check || !rs2_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
			general_check = `FALSE;//No paso la pueba
			$display(" %d | %s | %s | -------- | DATAO--> | --- | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_datao_v, sb_datao_v, datao_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
			err_count++; 
		 end else begin
			general_check = `TRUE;//Si paso la prueba
`ifdef __DB_PASS__ 
			$display(" %d | %s | %s | -------- | DATAO--> | --- | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s |                              *** %s ***", 
					 inst_counter, inst, function_check?"PASS":"X", risc_datao_v, sb_datao_v, datao_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
			// $display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %s", 
			// inst_counter, inst, function_check?"OK":"X", risc_rd_p, sb_rd_p, rd_p_check?"OK":"X", risc_rd_v, sb_rd_v, rd_v_check?"OK":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"OK":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"OK":"X", risc_imm, sb_imm, imm_check?"OK":"X", general_check?"OK":"X");
`endif
		 end
	  end
   endtask: s_type_cheker_rv2_imm_rs1

   //    task cp_mem_w(string inst ,input logic [31:0] risc_mem, input logic [31:0] sb_mem, string rx_funct);
   // 	  inst = inst_resize(inst);
   // 	  if(risc_mem != sb_mem)begin
   // 		 //$display("Inst. N | Inst.Dec/Ex | Darck Inst | SB Inst | Risc MEM | SB MEM | STATUS ");
   // 		 //$display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 $display(" %d | %h | %s | %s | %h | %h | %s ", inst_counter, top.soc0.core0.XIDATA, inst, rx_funct, risc_mem, sb_mem, "X");
   // 		 //--$display(" Counter: %d         |      %s     | riscv_mem:%h  | sb_mem:%h  | %s | rx_f:%s",   inst_counter, inst, risc_mem, sb_mem, "X", rx_funct);
   // 		 //--$display("riscv_opcode %h", top.soc0.core0.OPCODE);
   // 		 //--$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
   // `ifdef __DB_ENABLE__
   // 		 //$display("rc_rd_p =%d, rc_sr1_p =%d, rc_rs1 =%d, rc_rs2_p =%d rc_rs2 =%d| sb_rd_p =%d, sb_sr1_p =%d, sb_rs1 =%d, sb_rs2_p =%d sb_rs2 =%d", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.rdd, sb.rs1, sb.ref_model.REGS[sb.rs1],sb.rs2, sb.ref_model.REGS[sb.rs2]);
   // `endif
   // 		 err_count++;
   // 	  end else begin
   // 		 // $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
   // 		 //--$display(" Counter: %d         |      %s     | riscv_mem:%h  | sb_mem:%h  | %s | rx_f:%s",  inst_counter, inst, risc_mem, sb_mem, "PASS", rx_funct);
   // 		 //--$display("Instruction Decode/Execute %h", top.soc0.core0.XIDATA);
   // 		 $display(" %d | %h | %s | %s | %h | %h | %s", inst_counter, top.soc0.core0.XIDATA, inst, rx_funct, risc_mem, sb_mem, "PASS");
   // 		 //  $display("FUNCT 7 = %b , FUNC 3 = %b", top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]);
   // 	  end
   
   //    endtask

   function automatic string inst_resize(string inst);
	  inst = (inst.len() < 3) ? {inst, "   "} :
			 (inst.len() < 4) ? {inst, "  "} :
			 (inst.len() < 5) ? {inst, " "} : inst;
	  return inst;
   endfunction

endclass
