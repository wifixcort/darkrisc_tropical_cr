import instructions_data_struc::*;

`define __DB_ENABLE__
// `define XIDATA_P top.soc0.core0.XIDATA
class monitor2;
	// scoreboard sb = new();
	scoreboard sb;

   logic [15:0] inst_counter = 0;
   int err_count;
   int display_one = 1;

//    function new(); //scoreboard sb
	function new(scoreboard sb); //
      $display("Creating monitor 2");
	  //     this.intf = intf;
	  this.sb = sb;
   endfunction

   task check();
	
      err_count = 0;
	  	
      forever
		@ (posedge top.CLK) begin
		// @ (top.soc0.core0.PC) begin
		// @ (posedge (top.CLK && (top.soc0.core0.XLUI || top.soc0.core0.XAUIPC || top.soc0.core0.XJAL || top.soc0.core0.XJALR || top.soc0.core0.XBCC || top.soc0.core0.XLCC || top.soc0.core0.XSCC || top.soc0.core0.XMCC || top.soc0.core0.XRCC || top.soc0.core0.XCUS || top.soc0.core0.XCCC))) begin			
			sb.process_inst();
			`ifdef __DB_ENABLE__
			if(display_one)begin
				$display("Instrucction number | Instruction |  DUT REG  |  SB REG   | STATUS ");
				display_one = 0;
			end
			`endif
           case (top.soc0.core0.XIDATA[6:0])
             R_TYPE: begin
`ifdef __DB_ENABLE__
               	// $display("-> R_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
              	// $display("-> func3 func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.FCT3});
`endif
				case({top.soc0.core0.XIDATA[31:25], top.soc0.core0.FCT3})
                  9'h000: begin //add
                  	//  $display("-> func: ADD <-");
					// cp_mem_w("add", top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.ref_model.REGS[sb.rdd_val]);
					cp_mem_w("add", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
					`ifdef __DB_ENABLE__
					$display("rc_rd_p = %d, rc_sr1_p = %d, rc_rs1_val = %d, rc_rs2_p = %d rc_rs2_val = %d| sb_rd_val = %d, sb_rs1_val = %d, sb_rs2_val = %d", top.soc0.core0.DPTR, top.soc0.core0.S1PTR, top.soc0.core0.S1REG, top.soc0.core0.S2PTR, top.soc0.core0.S2REG, sb.rdd_val, sb.rs1_val, sb.rs2_val);
                 `endif
				end
                  9'h100: begin //sub 
                  	//  $display("-> func: SUB <-");
					cp_mem_w("sbu", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  SLL_FC: begin //sll
                    //  $display("-> func: SLL <-");
					cp_mem_w("sll", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  SLT_FC: begin //slt
					//  $display("-> func: SLT <-");
					cp_mem_w("slt", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  SLTU_FC: begin //sltu
					//  $display("-> func: SLTU <-");
					cp_mem_w("sltu", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  XOR_FC: begin //xor
					//  $display("-> func: XOR <-");
					cp_mem_w("xor", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  9'h005: begin //srl
					//  $display("-> func: SRL <-");
					cp_mem_w("srl", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  9'h105: begin //sra
					//  $display("-> func: SRA <-");
					cp_mem_w("sra", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  OR_FC: begin //or
                 	//  $display("-> func: OR <-");
					cp_mem_w("or", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  AND_FC: begin //and
					//  $display("-> func: AND <-");
					cp_mem_w("and", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type R not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
					 err_count++;
					 inst_counter++;
                  end
				endcase
             end
             I_TYPE: begin                  
`ifdef __DB_ENABLE__ 
				// $display("-> I_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
				if(top.soc0.core0.FCT3 == 3'b101) begin
                   case(top.soc0.core0.XIDATA[31:25])
					 9'h000: begin //srli
						// $display("-> func3 + func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.FCT3});
						// $display("-> func: SRLI <-");
						cp_mem_w("srli", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
					 end
					 9'h020: begin //srai
						// $display("-> func3 + func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.FCT3});
						// $display("-> func: SRAI <-");
						cp_mem_w("srai", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
					 end
					 default: begin
`ifdef __DB_ENABLE__ 
						$display("**** Instruccion type I not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
						err_count++;
						inst_counter++;
					 end
                   endcase
				end else begin
                   case(top.soc0.core0.FCT3)
					 ADDI_FC:begin //addi
						// rd = rs1 + imm
						// Check and print Add Intermediate instrucction
						cp_mem_w("addi", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
						// $display("RD %h, rd %h, PC %h", top.soc0.core0.DPTR, sb.rdd_val, top.soc0.core0.PC);
						// $display("rs1 = %b, imm = %b | rs1 = %b, imm = %b", top.soc0.core0.S1PTR, $signed(top.soc0.core0.XSIMM), sb.rs1_val, sb.imm_val_sign_ext);
					 end
					 SLTI_FC:begin //slti
						// $display("-> func: SLTI <-");
						cp_mem_bb("slti", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
						// $display("RD %h, rd %h", top.soc0.core0.DPTR, sb.rdd_val);
						// $display("rs1 = %d, imm = %d | rs1 = %d, imm = %d", top.soc0.core0.S1PTR, $signed(top.soc0.core0.XSIMM), sb.rs1_val, sb.imm_val_sign_ext);
					 
					 end
					 SLTIU_FC:begin //sltiu
						cp_mem_bb("sltiu", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
						// $display("-> func: SLTIU <-");
					 end
					 XORI_FC:begin //xori
						// $display("-> func: XORI <-");
						cp_mem_w("xori", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
						// $display("RD %h, rd %h, PC %h", top.soc0.core0.DPTR, sb.rdd_val, top.soc0.core0.PC);
						// $display("rs1 = %b, imm = %b | rs1 = %b, imm = %b", top.soc0.core0.S1PTR, $signed(top.soc0.core0.XSIMM), sb.rs1_val, sb.imm_val_sign_ext);
					 
					 end
					 ORI_FC:begin //ori
						// $display("-> func: ORI <-");
						// cp_mem_w("ori", top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.ref_model.REGS[sb.rdd_val]);
						cp_mem_w("ori", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
						// $display("RD %h, rd %h", top.soc0.core0.DPTR, sb.rdd_val);
						// $display("rs1 = %b, imm = %b | rs1 = %b, imm = %b", top.soc0.core0.S1PTR, $signed(top.soc0.core0.XSIMM), sb.rs1_val, sb.imm_val_sign_ext);
					 
					 end
					 ANDI_FC:begin //andi
						// $display("-> func: ANDI <-");
						cp_mem_w("andi", top.soc0.core0.RMDATA, sb.ref_model.REGS[sb.rdd_val]);
					 end
					 default: begin
`ifdef __DB_ENABLE__ 
						$display("**** Instruccion type I not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
						err_count++;
						inst_counter++;
					 end
                   endcase                  
                   
				end
                
             end	
             I_L_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> I_L_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				// $display("-> func3 = %b <-", top.soc0.core0.FCT3);
`endif
				case(top.soc0.core0.FCT3)
                  LB_FC: begin //lb
					//  $display("-> func: LB <-");
					//  $display("-> R : %h<-", top.soc0.core0.DADDR);
					//  cp_mem_b("lb" ,top.soc0.core0.REGS[top.soc0.core0.DPTR][7:0], sb.ref_model.REGS[sb.rdd_val][7:0]);
					cp_mem_b("lb" ,top.soc0.core0.LDATA[7:0], sb.DATAI[7:0]);
                  end
                  LH_FC: begin //lh
					//  $display("-> func: LH <-");
					//  $display("-> R : %h<-", top.soc0.core0.DADDR);
					// cp_mem_h("lh" ,top.soc0.core0.REGS[top.soc0.core0.DPTR][15:0], sb.ref_model.REGS[sb.rdd_val][15:0]);
					// cp_mem_h("lh" ,top.soc0.core0.DATAI[15:0], sb.DATAI[15:0]);
					cp_mem_h("lh" ,top.soc0.core0.LDATA[15:0], sb.ref_model.REGS[sb.rdd_val][15:0]);
					`ifdef __DB_ENABLE__
					$display("RD %h, rd %h, PC %h", top.soc0.core0.DPTR, sb.rdd_val, top.soc0.core0.PC);
					$display("rs1 = %d, imm = %d | rs1 = %d, imm = %d", top.soc0.core0.S1REG, $signed(top.soc0.core0.XSIMM), sb.rs1_val, sb.imm_val_sign_ext);
					 `endif
                  end
                  LW_FC: begin //lw
					//  $display("-> func: LW <-");
					// cp_mem_w("lw" ,top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.ref_model.REGS[sb.rdd_val]);
					// cp_mem_w("lw" ,top.soc0.core0.DATAI, sb.DATAI);
					cp_mem_w("lw" ,top.soc0.core0.LDATA, sb.ref_model.REGS[sb.rdd_val]);
					`ifdef __DB_ENABLE__
					$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
					$display("riscv_rs1_p = %h riscv_rs1_val = %d, riscv_imm = %d | sb_rs1_val = %d, sb_imm = %d", top.soc0.core0.S1PTR, top.soc0.core0.S1REG, $signed(top.soc0.core0.XSIMM),sb.rs1_val, sb.imm_val_sign_ext);
					 `endif
                  end
                  LBU_FC: begin //lbu
`ifdef __DB_ENABLE__ 
					//  $display("-> func: LBU <-");
					//  $display("-> R : %h<-", top.soc0.core0.DADDR);
					cp_mem_w("lbu" ,top.soc0.core0.DATAI, sb.DATAI);
`endif
                  end
                  LHU_FC: begin //lhu
`ifdef __DB_ENABLE__ 
					//  $display("-> func: LHU <-");
					//  $display("-> R : %h<-", top.soc0.core0.DADDR);
					// inst_counter++;
					cp_mem_w("lhu" ,top.soc0.core0.REGS[top.soc0.core0.DPTR], sb.ref_model.REGS[sb.rdd_val]);
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type I_L not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
					 err_count++;
					 inst_counter++;
                  end
				endcase
             end
             I_JALR_TYPE: begin //jalr
`ifdef __DB_ENABLE__ 
				// $display("-> I_JALR_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				// $display("-> func3 = %b <-", top.soc0.core0.FCT3);
`endif
				case(top.soc0.core0.FCT3)
                  JALR_C: begin 
`ifdef __DB_ENABLE__ 
					//  $display("-> func: JALR <-");
					
`endif
					// inst_counter++;
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type I_JALR not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
					 err_count++;
					 inst_counter++;
                  end
				endcase
             end	
             S_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> S_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				// $display("-> func3 = %b <-", top.soc0.core0.FCT3);
`endif
                case(top.soc0.core0.FCT3)
                  SB_FC:begin //sb
					//  s_and_b_print(0, top.soc0.core0.XIDATA[6:0], top.soc0.core0.S1PTR, 
					 			// top.soc0.core0.S2PTR, 0, {top.soc0.core0.XIDATA[31:25],top.soc0.core0.XIDATA[11:7]});
					//  $display("                               | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", sb.rx_funct, sb.rs1_val, sb.rs2_val, sb.imm_val);
					// Check and print Store Byte instrucction
					cp_mem_b("sb", top.soc0.core0.DATAO[7:0], sb.DATAO[7:0]);					 
                  end
                  SH_FC:begin //sh
					// Check and print Store halfword instrucction 
					// cp_mem_h("sh", top.soc0.core0.REGS[{top.soc0.core0.XIDATA[31:25],top.soc0.core0.XIDATA[11:7]}+top.soc0.core0.S1REG][15:0], sb.ref_model.REGS[sb.imm_val+sb.rs1_val][15:0]);
					cp_mem_h("sh", top.soc0.core0.DATAO[15:0], sb.DATAO[15:0]);
					`ifdef __DB_ENABLE__
					$display("RD %h, rd %h, PC %h", top.soc0.core0.DPTR, sb.rdd_val, top.soc0.core0.PC);
					$display("riscv_rs1_p = %h riscv_rs1_val = %d, riscv_imm = %d | sb_rs1_val = %d, sb_imm = %d", top.soc0.core0.S1PTR, top.soc0.core0.S2REG, $signed(top.soc0.core0.XSIMM),sb.rs1_val, sb.imm_val_sign_ext);
					 `endif
					
				end
                  SW_FC:begin //sw
					// Check and print Store word instrucction
					cp_mem_w("sw", top.soc0.core0.DATAO, sb.DATAO);
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instrucciontype S not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
                     err_count++;
					 inst_counter++;
                  end
                endcase  
             end	
             S_B_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> S_B_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				// $display("-> func3 = %b <-", top.soc0.core0.FCT3);
`endif
				case(top.soc0.core0.FCT3)
                  BEQ_FC: begin //beq
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BEQ <-");
`endif
					// inst_counter++;
                  end
                  BNE_FC: begin //bne
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BNE <-");
`endif
                  end
                  BLT_FC: begin //blt
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BLT <-");
`endif
					// inst_counter++;
                  end
                  BGE_FC: begin //beg
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BEG <-");
`endif
					inst_counter++;
                  end
                  BLTU_FC: begin //bltu
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BLTU <-");
`endif
					inst_counter++;
                  end
                  BGEU_FC: begin //bgeu
`ifdef __DB_ENABLE__ 
					//  $display("-> func: BGEU <-");
`endif
					inst_counter++;
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type S_B not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
					 err_count++;
					 inst_counter++;
                  end
				endcase
             end	
             J_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> J_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				// $display("-> func3 = %b <-", top.soc0.core0.FCT3);
				// $display("-> func: JAL <-");
`endif
				// inst_counter++;
             end
             LUI_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> LUI_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
				inst_counter++;
             end	
             AUIPC_TYPE: begin
`ifdef __DB_ENABLE__ 
				// $display("-> AUIPC_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
				inst_counter++;
             end	
             
             default: begin
				if(top.soc0.core0.XIDATA != 0) begin
`ifdef __DB_ENABLE__ 
				   $display("**** Instruccion not found ****");
				   $display("-> UNKOWN: %b , PC : %h<-", top.soc0.core0.XIDATA, top.soc0.core0.XIDATA[6:0]);
`endif
                   err_count++; // Manejar otros casos'
					inst_counter++;
				end
				
             end
           endcase     
		end
   endtask

   task s_and_b_print(input logic [7:0]num, input logic [6:0]opcode, input logic [4:0]rs1, input logic [4:0]rs2, input logic [4:0]rd, input logic [20:0]imm);
	$display("Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", num, opcode, rs1, rs2, imm);
	$display("-----------------------------------------------------------------------------------------------");
   endtask

    task cp_mem_b(string inst ,input logic [7:0] risc_mem, input logic [7:0] sb_mem);
		inst = inst_resize(inst);
		if(risc_mem != sb_mem)begin
			$display("        %d         |      %s     |    %h     |    %h     | %s ", inst_counter, inst, risc_mem, sb_mem, "X");
			// $display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			err_count++;
		end else begin
			// $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     |    %h     |    %h     | %s ", inst_counter, inst, risc_mem, sb_mem, "PASS");
		end
		$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
		inst_counter++;
	endtask

	task cp_mem_h(string inst ,input logic [15:0] risc_mem, input logic [15:0] sb_mem);
		inst = inst_resize(inst);
		if(risc_mem != sb_mem)begin
			// $display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     |   %h    |   %h    | %s ", inst_counter, inst, risc_mem, sb_mem, "X");
			err_count++;
		end else begin
			// $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     |   %h    |   %h    | %s ", inst_counter, inst, risc_mem, sb_mem, "PASS");
		end
		$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
		inst_counter++;
	endtask

	task cp_mem_bb( string inst,input logic risc_mem, input logic sb_mem);
		inst = inst_resize(inst);
		if(risc_mem != sb_mem)begin
			// $display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     |     %h     |     %h     | %s ", inst_counter, inst, risc_mem, sb_mem, "X");
			err_count++;
		end else begin
			// $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     |     %h     |     %h     | %s ", inst_counter, inst, risc_mem, sb_mem, "PASS");
		end
		$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
		inst_counter++;
	endtask

	task cp_mem_w(string inst ,input logic [31:0] risc_mem, input logic [31:0] sb_mem);
		inst = inst_resize(inst);
		if(risc_mem != sb_mem)begin
			// $display("%s > * ERROR * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     | %h  | %h  | %s ", inst_counter, inst, risc_mem, sb_mem, "X");
			err_count++;
		end else begin
			// $display("%s > * PASS * DUT data is %h :: SB data is %h ", inst, risc_mem, sb_mem);
			$display("        %d         |      %s     | %h  | %h  | %s ", inst_counter, inst, risc_mem, sb_mem, "PASS");
		end
		$display("riscv_opcode %h, riscv_pc %h, sb_pc %h", top.soc0.core0.OPCODE, top.soc0.core0.PC, sb.pc_val);
		inst_counter++;
	endtask

	function automatic string inst_resize(string inst);
		inst = (inst.len() < 3) ? {inst, "   "} :
		(inst.len() < 4) ? {inst, "  "} :
		(inst.len() < 5) ? {inst, " "} : inst;
		return inst;
	endfunction

endclass