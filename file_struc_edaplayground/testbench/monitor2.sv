import instructions_data_struc::*;

`define __DB_ENABLE__ 1
class monitor2;
   //   scoreboard sb;
   //   virtual intf_cnt intf;

   //   logic [7:0] sb_value;
   int err_count;

   localparam DEBUG_ENABLED = 0;
   function new(); //scoreboard sb
      $display("Creating monitor 2");
	  //     this.intf = intf;
	  //     this.sb = sb;
   endfunction

   task check();
      err_count = 0;
      forever
		@ (posedge top.CLK) begin
           case (top.soc0.core0.XIDATA[6:0])
             R_TYPE: begin
`ifdef __DB_ENABLE__
               	$display("-> R_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
              	$display("-> func3 func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]});
`endif
				case({top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]})
                  9'h000: begin //add
`ifdef __DB_ENABLE__
                  	 $display("-> func: ADD <-");
                  	 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  9'h100: begin //sub 
`ifdef __DB_ENABLE__
                  	 $display("-> func: SUB <-");
`endif
					 //                   if(sb.procec.rx_func == SUB)begin
					 //                     if(sb.rd == ADDDR)begin
					 //                       ok
					 //                     end else begin
					 //                       $display("Error FX code R_TYPE SUB");
					 //                     end
					 //                   end
                  end
                  SLL_FC: begin //sll
`ifdef __DB_ENABLE__
                     $display("-> func: SLL <-");
`endif
                  end
                  SLT_FC: begin //slt
`ifdef __DB_ENABLE__ 
					 $display("-> func: SLT <-");
`endif
                  end
                  SLTU_FC: begin //sltu
`ifdef __DB_ENABLE__
					 $display("-> func: SLTU <-");
`endif
                  end
                  XOR_FC: begin //xor
`ifdef __DB_ENABLE__
					 $display("-> func: XOR <-");
`endif
                  end
                  9'h005: begin //srl
`ifdef __DB_ENABLE__
					 $display("-> func: SRL <-");
`endif
                  end
                  9'h105: begin //sra
`ifdef __DB_ENABLE__ 
					 $display("-> func: SRA <-");
`endif
                  end
                  OR_FC: begin //or
`ifdef __DB_ENABLE__
                 	 $display("-> func: OR <-");
`endif
                  end
                  AND_FC: begin //and
`ifdef __DB_ENABLE__
					 $display("-> func: AND <-");
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type R not found");
`endif
					 err_count++;
                  end
				endcase
             end
             I_TYPE: begin                  
`ifdef __DB_ENABLE__ 
				$display("-> I_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
				if(top.soc0.core0.XIDATA[14:12] == 3'b101) begin
                   case(top.soc0.core0.XIDATA[31:25])
					 9'h000: begin //srli
`ifdef __DB_ENABLE__ 
						$display("-> func3 + func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]});
						$display("-> func: SRLI <-");
`endif
					 end
					 9'h020: begin //srai
`ifdef __DB_ENABLE__ 
						$display("-> func3 + func7 = %b <-", {top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]});
						$display("-> func: SRAI <-");
`endif
					 end
					 default: begin
`ifdef __DB_ENABLE__ 
						$display("**** Instruccion type I not found ****");
`endif
						err_count++;
					 end
                   endcase
				end else begin
`ifdef __DB_ENABLE__ 
				   $display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
`endif
                   case(top.soc0.core0.XIDATA[14:12])
					 ADDI_FC:begin //addi
`ifdef __DB_ENABLE__ 
						$display("-> func: ADDI <-");
`endif
					 end
					 SLTI_FC:begin //slti
`ifdef __DB_ENABLE__ 
						$display("-> func: SLTI <-");
`endif
					 end
					 SLTIU_FC:begin //sltiu
`ifdef __DB_ENABLE__ 
						$display("-> func: SLTIU <-");
`endif                       
					 end
					 XORI_FC:begin //xori
`ifdef __DB_ENABLE__ 
						$display("-> func: XORI <-");
`endif
					 end
					 ORI_FC:begin //ori
`ifdef __DB_ENABLE__ 
						$display("-> func: ORI <-");
`endif
					 end
					 ANDI_FC:begin //andi
`ifdef __DB_ENABLE__ 
						$display("-> func: ANDI <-");
`endif
					 end
					 default: begin
`ifdef __DB_ENABLE__ 
						$display("**** Instruccion type I not found ****");
`endif
						err_count++;
					 end
                   endcase                  
                   
				end
                
             end	
             I_L_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> I_L_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				$display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
`endif
				case(top.soc0.core0.XIDATA[14:12])
                  LB_FC: begin //lb
`ifdef __DB_ENABLE__ 
					 $display("-> func: LB <-");
					 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  LH_FC: begin //lh
`ifdef __DB_ENABLE__ 
					 $display("-> func: LH <-");
					 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  LW_FC: begin //lw
`ifdef __DB_ENABLE__ 
					 $display("-> func: LW <-");
					 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  LBU_FC: begin //lbu
`ifdef __DB_ENABLE__ 
					 $display("-> func: LBU <-");
					 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  LHU_FC: begin //lhu
`ifdef __DB_ENABLE__ 
					 $display("-> func: LHU <-");
					 $display("-> R : %h<-", top.soc0.core0.DADDR);
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type I_L not found ****");
`endif
					 err_count++;
                  end
				endcase
             end
             I_JALR_TYPE: begin //jalr
`ifdef __DB_ENABLE__ 
				$display("-> I_JALR_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				$display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
`endif
				case(top.soc0.core0.XIDATA[14:12])
                  JALR_C: begin 
`ifdef __DB_ENABLE__ 
					 $display("-> func: JALR <-");
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type I_JALR not found ****");
`endif
					 err_count++;
                  end
				endcase
             end	
             S_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> S_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				$display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
`endif
                case(top.soc0.core0.XIDATA[14:12])
                  SB_FC:begin //sb
`ifdef __DB_ENABLE__ 
					 $display("-> func: SB <-");
`endif
                  end
                  SH_FC:begin //sh
`ifdef __DB_ENABLE__ 
					 $display("-> func: SH <-");
					 $display("-> func: store halfword <-");
					 $display("Instruction number=%d | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", 0, top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[19:15], top.soc0.core0.XIDATA[24:20], {top.soc0.core0.XIDATA[31:25],top.soc0.core0.XIDATA[11:7]});
					 $display("                               | op=%b  |  rs1=%d  |  rs2=%d  | imm=%d", sb.rx_funct, sb.rs1_val, sb.rs2_val, sb.imm_val);
					 $display("REG = %h , S1REG = %h", sb.riscv_ref_model.REGS[sb.rs1_val], top.soc0.core0.S1REG);
					 $display("-----------------------------------------------------------------------------------------------");
`endif
                  end
                  SW_FC:begin //sw
`ifdef __DB_ENABLE__ 
					 $display("-> func: SW <-");
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instrucciontype S not found ****");
`endif
                     err_count++;
                  end
                endcase  
             end	
             S_B_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> S_B_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				$display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
`endif
				case(top.soc0.core0.XIDATA[14:12])
                  BEQ_FC: begin //beq
`ifdef __DB_ENABLE__ 
					 $display("-> func: BEQ <-");
`endif
                  end
                  BNE_FC: begin //bne
`ifdef __DB_ENABLE__ 
					 $display("-> func: BNE <-");
`endif
                  end
                  BLT_FC: begin //blt
`ifdef __DB_ENABLE__ 
					 $display("-> func: BLT <-");
`endif
                  end
                  BGE_FC: begin //beg
`ifdef __DB_ENABLE__ 
					 $display("-> func: BEG <-");
`endif
                  end
                  BLTU_FC: begin //bltu
`ifdef __DB_ENABLE__ 
					 $display("-> func: BLTU <-");
`endif
                  end
                  BGEU_FC: begin //bgeu
`ifdef __DB_ENABLE__ 
					 $display("-> func: BGEU <-");
`endif
                  end
                  default: begin
`ifdef __DB_ENABLE__ 
					 $display("**** Instruccion type S_B not found ****");
`endif
					 err_count++;
                  end
				endcase
             end	
             J_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> J_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
				$display("-> func3 = %b <-", top.soc0.core0.XIDATA[14:12]);
				$display("-> func: JAL <-");
`endif
             end
             LUI_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> LUI_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
             end	
             AUIPC_TYPE: begin
`ifdef __DB_ENABLE__ 
				$display("-> AUIPC_TYPE: %b <-", top.soc0.core0.XIDATA[6:0]);
`endif
             end	
             
           	 //2'b01: out = b;
             
             default: begin
				if(top.soc0.core0.XIDATA != 0) begin
`ifdef __DB_ENABLE__ 
				   $display("**** Instruccion not found ****");
				   $display("-> UNKOWN: %b <-", top.soc0.core0.XIDATA);
`endif
                   err_count++; // Manejar otros casos'
				end
             end
           endcase     
		   //       begin
		   //         @ (posedge top.CLK)
           
		   //         if (top.soc0.core0.XIDATA[6:0] == I_TYPE)
		   //         begin
		   //           `ifdef __DB_ENABLE__ 
		   //		   $display("-> OPCODE: %h == %h <-", top.soc0.core0.OPCODE, top.soc0.core0.XIDATA[6:0]);
		   //		   $display("PC: %h", top.soc0.core0.REGS[1]);
		   // `endif
		   //         sb_value = sb.store.pop_back();
		   //           if( sb_value != intf.data_out) begin // Get expected value from scoreboard and compare with DUT output
		   //             `ifdef __DB_ENABLE__ 
		   //		   $display(" * ERROR * DUT data is %b :: SB data is %b ", intf.data_out,sb_value );
		   //`endif
		   //             err_count++;
		   //           end
		   //           else begin
		   //             `ifdef __DB_ENABLE__ 
		   //		   $display(" * PASS * DUT data is %b :: SB data is %b ", intf.data_out,sb_value );
		   //`endif
		   //           end
		   //         end
		end
   endtask
endclass