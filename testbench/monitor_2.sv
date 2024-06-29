import instructions_data_struc::*;

`define CORE top.soc0.core0

`define FALSE 0
`define TRUE 1

typedef struct {
   string            inst;
   logic [7:0]       instruccion;

   logic [4:0]       risc_rd_p;     // riscv rd register pointer
   logic [31:0]      risc_rd_v;     // riscv rd register value
   logic [4:0]       risc_rs1_p;    // riscv rs1 register pointer
   logic [31:0]      risc_rs1_v;    // riscv rs1 register value
   logic [4:0]       risc_rs2_p;    // riscv rs1 register pointer
   logic [31:0]      risc_rs2_v;    // riscv rs1 register value
   logic [31:0]      risc_imm;      // riscv immidiate value
   // logic [31:0]   sb_rd_p;    // sb rd register pointer
   // logic [31:0]   sb_rd_v;    // sb rd register value
   // logic [31:0]   sb_rs1_p;   // sb rs1 register pointer
   // logic [31:0]   sb_rs1_v;   // sb rs1 register value
   // logic [31:0]   sb_rs2_p;   // sb rs1 register pointer
   // logic [31:0]   sb_rs2_v;   // sb rs1 register value
   // logic [31:0]   sb_imm;  // sb immidiate value
   logic [31:0]      inst_PC;
   logic [31:0]      inst_XIDATA;
   logic [15:0]      inst_counter;
   logic [31:0]      risc_sdata;
   logic [31:0]      risc_daddr;
   bit               be;
   // logic [31:0]	sb_DADDR;
   // logic [31:0]	sb_DATAI;
}ExData;


class uvc2_mon extends uvm_monitor;
   uvm_analysis_port #(monitor_tr) mon2_txn;
   // UVM Factory Registration Macro
   `uvm_component_utils(uvc2_mon)
   
   
   
   ExData            ex_dbuf;

   //Auxiliar variables (Instead of creating a lot of virt interfaces or anything similar, we
   //take the data from our available sources)

   logic [2:0]       FCT3;
   logic [6:0]       FCT7;

   logic [15:0]	   inst_counter;
   int			      err_count;
   logic [15:0]	   display_one;
   logic [31:0]	   sinc_count = 0;
// logic [31:0]	   sb_rd_reg_value;
   logic [31:0]	   risc_rd_reg_value;
   int			      debug_counter_num_inst;
   string		      rx_funct_str = "";

   virtual intf_mon2 intf2;

   // Standard UVM Methods:
   extern function new (string name = "uvc2_mon", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   
   //Non Standard UVM Methods:
   extern function string inst_resize(string inst);
   

endclass:uvc2_mon

function uvc2_mon::new (string name = "uvc2_mon", uvm_component parent = null);
   super.new (name, parent);
   inst_counter = '0;
   err_count = '0;
   display_one = '0;
   sinc_count = 0;
   // logic [31:0]	sb_rd_reg_value;
   risc_rd_reg_value = '0;
   debug_counter_num_inst = '0;
   rx_funct_str = "";
   this.ex_dbuf = '{ inst        : "",    instruccion  : '0, risc_rd_p  : '0, risc_rd_v   : '0, risc_rs1_p  : '0, 
					      risc_rs1_v  : '0,    risc_rs2_p   : '0, risc_rs2_v : '0, risc_imm    : '0, inst_PC     : '0, 
					      inst_XIDATA : '0,    inst_counter : '0, risc_sdata : '0, risc_daddr  : '0, be          : '0};//
endfunction

task uvc2_mon:: run_phase(uvm_phase phase);
   // monitor_tr mn_txn; //Instancia par la transacción
   monitor_tr mn_txn = monitor_tr::type_id::create("tr", this);
   super.run_phase(phase);
   uvm_report_info(get_full_name(),"Start run phase monitor 2", UVM_LOW);

   forever begin

      @ (posedge intf2.clk);// begin//

      //Creates auxiliar variables
      FCT3 = intf2.XIDATA[14:12];
      FCT7 = intf2.XIDATA[31:25];
      
      if(`CORE.NXPC != 0)begin //Revisar un ciclo despues
         if (`CORE.HLT == 0) begin
			// mn_txn = monitor_tr::type_id::create("tr", this);
			// mn_txn.data = '0; //Generar el dato a enviar

			//R TYPE
			if(ex_dbuf.instruccion == ADD || ex_dbuf.instruccion == SUB || ex_dbuf.instruccion == SLL || ex_dbuf.instruccion == SLT || 
               ex_dbuf.instruccion == SLTU || ex_dbuf.instruccion == XOR || ex_dbuf.instruccion == SRL || ex_dbuf.instruccion == SRA || 
               ex_dbuf.instruccion == AND || ex_dbuf.instruccion == OR)begin
               // $display("------------------------- R type -------------------------");
               ex_dbuf.risc_rd_v = `CORE.REGS[ex_dbuf.risc_rd_p];
         //I TYPE
         end else if(ex_dbuf.instruccion == ADDI || ex_dbuf.instruccion == SLTI || ex_dbuf.instruccion == SLTIU || ex_dbuf.instruccion == XORI ||
               ex_dbuf.instruccion == ORI || ex_dbuf.instruccion == ANDI || ex_dbuf.instruccion == SLLI || ex_dbuf.instruccion == SRLI ||
               ex_dbuf.instruccion == SRAI)begin
            // $display("------------------------- I type -------------------------");
               ex_dbuf.risc_rd_v = `CORE.REGS[ex_dbuf.risc_rd_p];
         //I_L TYPE
			end else if(ex_dbuf.instruccion == LB || ex_dbuf.instruccion == LH || ex_dbuf.instruccion == LW || ex_dbuf.instruccion == LBU || 
               ex_dbuf.instruccion == LHU) begin
            // $display("------------------------- IL type -------------------------");
               $display("DATAI mon2 = %h", top.soc0.MEM[ex_dbuf.risc_daddr[`MLEN-1:2]]);
               ex_dbuf.risc_rd_v = `CORE.REGS[ex_dbuf.risc_rd_p];			   
			end else if(ex_dbuf.instruccion == SB || ex_dbuf.instruccion == SH || ex_dbuf.instruccion == SW) begin
			      // $display("------------------------- IL type -------------------------");
			      ex_dbuf.risc_rs2_v = `CORE.REGS[ex_dbuf.risc_rs2_p];
               // Ver cuando es cual y sacar de la memoria los datos
               if(ex_dbuf.instruccion == SB )begin
                  case (ex_dbuf.be)
                     4'b1000: begin 
                           ex_dbuf.risc_sdata = top.soc0.MEM[`CORE.DADDR[`MLEN-1:2]][31:24];
                     end 
                     4'b0100: begin
                           ex_dbuf.risc_sdata = top.soc0.MEM[`CORE.DADDR[`MLEN-1:2]][23:16];
                     end
                     4'b0010: begin 
                           ex_dbuf.risc_sdata = top.soc0.MEM[`CORE.DADDR[`MLEN-1:2]][15:8];
                     end
                     4'b0001: begin 
                           ex_dbuf.risc_sdata = top.soc0.MEM[ex_dbuf.risc_daddr[`MLEN-1:2]][7:0];
                     end
                  endcase
               end else if(ex_dbuf.instruccion == SH) begin
                  case (ex_dbuf.be)
                     4'b1100: begin 
                        ex_dbuf.risc_sdata = top.soc0.MEM[ex_dbuf.risc_daddr[`MLEN-1:2]][31:16];
                     end
                     4'b0011: begin 
                        ex_dbuf.risc_sdata = top.soc0.MEM[ex_dbuf.risc_daddr[`MLEN-1:2]][15:0];
                     end 
                  endcase
               end else if(ex_dbuf.instruccion == SW) begin
                  ex_dbuf.risc_sdata = top.soc0.MEM[ex_dbuf.risc_daddr[`MLEN-1:2]];
                  // ex_dbuf.risc_sdata = intf2.SDATA;
               end			   
			end
			// ex_dbuf.risc_rd_v = `CORE.REGS[ex_dbuf.risc_rd_p];

			mn_txn.inst         = this.ex_dbuf.inst;
			mn_txn.instruction  = this.ex_dbuf.instruccion;
			mn_txn.risc_rd_p    = this.ex_dbuf.risc_rd_p;
			mn_txn.risc_rd_v    = this.ex_dbuf.risc_rd_v;
			mn_txn.risc_rs1_p   = this.ex_dbuf.risc_rs1_p;
			mn_txn.risc_rs1_v   = this.ex_dbuf.risc_rs1_v;
			mn_txn.risc_rs2_p   = this.ex_dbuf.risc_rs2_p;
			mn_txn.risc_rs2_v   = this.ex_dbuf.risc_rs2_v;
			mn_txn.risc_imm     = this.ex_dbuf.risc_imm;
			// mn_txn.risc_datai = `DATAI;
			// mn_txn.risc_datao = `DATAO;
			mn_txn.inst_PC      = this.ex_dbuf.inst_PC;
			mn_txn.inst_XIDATA  = this.ex_dbuf.inst_XIDATA;
			mn_txn.inst_counter = this.ex_dbuf.inst_counter;
			mn_txn.risc_sdata   = ex_dbuf.risc_sdata;
			//  $display("%s, %h", mn_txn.instruction, this.ex_dbuf.instruccion);

			mon2_txn.write(mn_txn);
			//Clear this buffer
			//  this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
			//           risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, sb_rd_p : '0, sb_rd_v : '0,
			//           sb_rs1_p : '0, sb_rs1_v : '0, sb_rs2_p : '0, sb_rs2_v : '0, sb_imm : '0, inst_PC : '0, 
			//           inst_XIDATA : '0, sb_DADDR : '0, sb_DATAI : '0};
			this.ex_dbuf = '{inst : "", instruccion : '0, risc_rd_p : '0, risc_rd_v : '0, risc_rs1_p : '0, 
							 risc_rs1_v : '0, risc_rs2_p : '0, risc_rs2_v : '0, risc_imm : '0, inst_PC : '0, 
							 inst_XIDATA : '0, inst_counter : '0, risc_sdata : '0, risc_daddr : '0, be : '0};//
         end
      end
      
      if (`CORE.IADDR != 0)begin //Waits for first instruction out of reset. // !top.soc0.core0.XRES && |top.soc0.core0.IADDR
         if (`CORE.HLT == 0) begin //For get correct values from two clock cicle instructions
            // if (inst_counter == 0)begin
            //  sb.process_inst(); 		//Fixes a bug which requires initializing the SB by processing the very first instruction
            //  inst_counter++;
            //  continue; //Jump to the start of forever to avoid first invalid instruction from the scoreboard
            // end
            // sb.process_inst();						//Pop scoreboard info to compare it against actual instruction.
            // if(this.display_one == 1)begin
            //  $display(" # | Type | Stat | risv rd p | SB   rd p  | Stat |  Riscv rs1 p | SB   rs1 p | Stat |  Riscv rs2 p | SB   rs2 p | Stat |  Riscv rs2 v | SB   rs2 v | Stat |  Riscv imm v | SB   imm v | Stat | Gen. STATUS ");
            //  this.display_one = 0;
            // end
            // sb_rd_reg_value = sb.ref_model.REGS[sb.rdd];//(top.soc0.core0.DPTR==0)? sb.ref_model.fake_reg0 : sb.ref_model.REGS[sb.rdd];
            // // end 
            case (intf2.XIDATA[6:0])
               ////////////////////////////////////////////////////////////
               //          R-Type instruction was detected
               ////////////////////////////////////////////////////////////
               R_TYPE: begin //Begin R_TYPE
                  risc_rd_reg_value = (intf2.DPTR==0)? `CORE.REGS[intf2.DPTR] : intf2.RMDATA;
                  case({intf2.XIDATA[31:25], intf2.XIDATA[14:12]})
                        10'h0: begin //add
                           //   $display("------------- ADD -------------");
                           ex_dbuf.inst = "ADD";
                           ex_dbuf.instruccion = ADD;
                        end
                        10'b0100000000: begin //sub
                           //   $display("------------- SUB -------------");
                           ex_dbuf.inst = "SUB";
                           ex_dbuf.instruccion = SUB;
                        end
                        SLL_FC: begin //sll
                           //   $display("------------- SLL -------------");
                           ex_dbuf.inst = "SLL";
                           ex_dbuf.instruccion = SLL;
                        end
                        SLT_FC: begin //slt
                           //   $display("------------- SLT -------------");
                           ex_dbuf.inst = "SLT";
                           ex_dbuf.instruccion = SLT;
                        end
                        SLTU_FC: begin //sltu
                           //   $display("------------- SLTU -------------");
                           ex_dbuf.inst = "SLTU";
                           ex_dbuf.instruccion = SLTU;
                        end
                        XOR_FC: begin //xor
                           //   $display("------------- XOR -------------");
                           ex_dbuf.inst = "XOR";
                           ex_dbuf.instruccion = XOR;
                        end
                        9'h005: begin //srl
                           //   $display("------------- SRL -------------");
                           ex_dbuf.inst = "SRL";
                           ex_dbuf.instruccion = SRL;
                        end
                        9'h105: begin //sra
                           //   $display("------------- SRA -------------");
                           ex_dbuf.inst = "SRA";
                           ex_dbuf.instruccion = SRA;
                        end
                        OR_FC: begin //or
                           //   $display("------------- OR -------------");
                           ex_dbuf.inst = "OR";
                           ex_dbuf.instruccion = OR;
                        end
                        AND_FC: begin //and
                           //   $display("------------- AND -------------");
                           ex_dbuf.inst = "AND";
                           ex_dbuf.instruccion = AND;
                        end
                        default: begin
                           // `ifdef __DB_ENABLE__ 
                           // $display("**** Instruccion type R not found = %b PC:%h, sb_pc:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC, sb.pc_val);
                           // $display("FC7 = %b, FC3 = %b", top.soc0.core0.XIDATA[31:25], top.soc0.core0.XIDATA[14:12]);
                           // $display("sb_rd_p = %h, sb_rd_val = %d, sb_rs1_p = %h, sb_rs1 = %d, sb_imm = %d ", sb.rdd, sb_rd_reg_value, sb.rs1, $signed(sb.rs1_val_ini), sb.imm_val_sign_ext);
                           err_count++;
                        end
                  endcase
               end //End R_TYPE
               ////////////////////////////////////////////////////////////
               //          I-Type instruction was detected
               ////////////////////////////////////////////////////////////			  
               I_TYPE: begin
                  risc_rd_reg_value = (intf2.DPTR==0)? `CORE.REGS[intf2.DPTR] : intf2.RMDATA;
                  if(FCT3 == 3'b101) begin
                     case(intf2.XIDATA[31:25])
                     10'h000: begin //srli
                        //  $display("------------- SRLI -------------");
                        ex_dbuf.inst = "SRLI";
                        ex_dbuf.instruccion = SRLI;
                     end
                     10'h020: begin //srai
                        ex_dbuf.inst = "SRAI";
                        ex_dbuf.instruccion = SRAI;
                     end
                     default: begin
                        //  `ifdef __DB_ENABLE__ 
                        //  $display("**** Instruccion type I not found = %b PC:%h, sb_pc:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC, sb.pc_val);
                        $display("FC3 = %b", intf2.XIDATA[14:12]);
                        err_count++;
                        // inst_counter++;
                     end
                     endcase
                  end else if(FCT3 == 3'b001)begin
                     case(intf2.XIDATA[31:25])
                     10'h000: begin //slli
                        ex_dbuf.inst = "SLLI";
                        ex_dbuf.instruccion = SLLI;
                     end
                     default: begin

                        `uvm_error("Instruction type I not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                        //  $display("FC3 = %b", top.soc0.core0.XIDATA[14:12]);
                        err_count++;
                     end
                     endcase
                  end else begin
                     case(FCT3)
                     ADDI_FC:begin //addi , logic'(ADDI)
                        ex_dbuf.inst = "ADDI";
                        ex_dbuf.instruccion = ADDI;
                     end
                     SLTI_FC:begin //slti
                        ex_dbuf.inst = "SLTI";
                        ex_dbuf.instruccion = SLTI;				 
                     end
                     SLTIU_FC:begin //sltiu
                        ex_dbuf.inst = "SLTIU";
                        ex_dbuf.instruccion = SLTIU;
                     end
                     XORI_FC:begin //xori
                        ex_dbuf.inst = "XORI";
                        ex_dbuf.instruccion = XORI;
                     end
                     ORI_FC:begin //ori
                        ex_dbuf.inst = "ORI";
                        ex_dbuf.instruccion = ORI;
                     end
                     ANDI_FC:begin //andi
                        ex_dbuf.inst = "ANDI";
                        ex_dbuf.instruccion = ANDI;
                     end
                     default: begin
                        `uvm_error("Instruction type I not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                        //  $display("**** Instruccion type I not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                        //  $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
                        err_count++;
                     end
                     endcase                  
                     
                  end
               end //End I_TYPE
               ////////////////////////////////////////////////////////////
               //          I(Load)-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               I_L_TYPE: begin
                  risc_rd_reg_value = (intf2.DPTR==0)? `CORE.REGS[intf2.DPTR] : intf2.LDATA;
                  case(FCT3)
                     LB_FC: begin //lb
                        ex_dbuf.inst = "LB";
                        ex_dbuf.instruccion = LB;	
                     end
                     LH_FC: begin //lh
                        ex_dbuf.inst = "LH";
                        ex_dbuf.instruccion = LH;
                     end
                     LW_FC: begin //lw
                        ex_dbuf.inst = "LW";
                        ex_dbuf.instruccion = LW;
                     end
                     LBU_FC: begin //lbu
                        ex_dbuf.inst = "LBU";
                        ex_dbuf.instruccion = LBU;	
                     end
                     LHU_FC: begin //lhu
                        ex_dbuf.inst = "LHU";
                        ex_dbuf.instruccion = LHU;
                     end
                     default: begin
                        `uvm_error("Instruction type L not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                     //   $display("**** Instruccion type IL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                     //   $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
                        err_count++;
                     end
                  endcase
               end //End I_L_TYPE
               ////////////////////////////////////////////////////////////
               //          I(JALR)-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               I_JALR_TYPE: begin //jalr
                  case(FCT3)
                     JALR_C: begin
                        // inst_counter++;
                        //  $display("*********************ALERTA**********************     I_JALR    ");
                     end
                     default: begin
                        `uvm_error("Instruction type I_JARL not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                        //   $display("**** Instruccion type I_JARL not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                        //   $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
                        err_count++;
                     end
                  endcase
               end //End I_JALR_TYPE
               ////////////////////////////////////////////////////////////
               //          S-Type instruction was detected
               ////////////////////////////////////////////////////////////                	
               S_TYPE: begin
                  case(FCT3)
                     SB_FC:begin //sb
                        ex_dbuf.inst = "SB";
                        ex_dbuf.instruccion = SB;			 
                     end
                     SH_FC:begin //sh
                        ex_dbuf.inst = "SH";
                        ex_dbuf.instruccion = SH;		
                     end
                     SW_FC:begin //sw
                        ex_dbuf.inst = "SW";
                        ex_dbuf.instruccion = SW;
                     end
                     default: begin
                        `uvm_error("Instruction type S not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                        //   $display("**** Instruccion type S not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                        //   $display("OPCODE = %b, FC3 = %b", top.soc0.core0.XIDATA[6:0], top.soc0.core0.XIDATA[14:12]);
                        err_count++;
                     end
                  endcase  
               end //End S_TYPE
               ////////////////////////////////////////////////////////////
               //          S-B-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               S_B_TYPE: begin
                  case(FCT3)
                     BEQ_FC: begin //beq
                        `uvm_info("ALERTA", "BEQ instruction found", UVM_MEDIUM);
                     //$display("*********************ALERTA**********************     BEQ    ");
                     end
                     BNE_FC: begin //bne 
                        //$display("-> func: BNE <-");
                        `uvm_info("ALERTA", "BNE instruction found", UVM_MEDIUM);
                        //$display("*********************ALERTA**********************     BNE    ");
                     end
                     BLT_FC: begin //blt
                        //$display("-> func: BLT <-");
                        `uvm_info("ALERTA", "BLT instruction found", UVM_MEDIUM);
                        //$display("*********************ALERTA**********************     BLT    ");
                     end
                     BGE_FC: begin //beg
                        //$display("-> func: BEG <-");
                        `uvm_info("ALERTA", "BEG instruction found", UVM_MEDIUM);
                        //$display("*********************ALERTA**********************     BEG    ");
                     end
                     BLTU_FC: begin //bltu
                        //$display("-> func: BLTU <-");
                        `uvm_info("ALERTA", "BLTU instruction found", UVM_MEDIUM);
                        //$display("*********************ALERTA**********************     BLTU   ");
                     end
                     BGEU_FC: begin //bgeu
                        //$display("-> func: BGEU <-");
                        `uvm_info("ALERTA", "BGEU instruction found", UVM_MEDIUM);
                        //$display("*********************ALERTA**********************     BGEU    ");
                     end
                     default: begin
                        `uvm_error("Instruction type S_B not found", $sformatf("\nIDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                        //$display("**** Instruccion type S_B not found = %b PC:%h****", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                        err_count++;
                     end
                  endcase
               end //End S_B_TYPE
               ////////////////////////////////////////////////////////////
               //          J-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               J_TYPE: begin
                  `uvm_info("ALERTA", "J_TYPE instruction found", UVM_MEDIUM);
                  //  $display("*********************ALERTA**********************     J_TYPE    ");
               end
               ////////////////////////////////////////////////////////////
               //          LUI-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               LUI_TYPE: begin
                  `uvm_info("ALERTA", "J_TYPE instruction found", UVM_MEDIUM);
                  //  $display("*********************ALERTA**********************     LUI    ");
               end
               ////////////////////////////////////////////////////////////
               //          AUIPC-Type instruction was detected
               ////////////////////////////////////////////////////////////               
               AUIPC_TYPE: begin
                  // $display("*********************ALERTA**********************     AUIPC    ");
               end	
               
               default: begin
                  if(intf2.XIDATA != 0) begin
                     `uvm_error("Instruction UNKOWN", $sformatf("\n IDATA = %b PC:%h", intf2.XIDATA, top.soc0.core0.PC))
                     // $display("**** Instruccion not found ****");
                     // $display("-> UNKOWN: %b , PC : %h<-", top.soc0.core0.XIDATA, top.soc0.core0.PC);
                     err_count++; 
                  end				 
               end              
            endcase
            
            inst_counter++;
            // ex_dbuf = '{inst: ex_dbuf.inst, instruccion : ex_dbuf.instruccion, risc_rd_p : `DPTR, risc_rd_v : risc_rd_reg_value, risc_rs1_p : `S1PTR, 
            //       risc_rs1_v : `S1REG, risc_rs2_p : `S2PTR, risc_rs2_v : `S2REG, risc_imm : (ex_dbuf.instruccion == SLTIU ? `XUIMM : `XSIMM), sb_rd_p : sb.rdd, sb_rd_v : sb_rd_reg_value,
            //       sb_rs1_p : sb.rs1, sb_rs1_v : sb.rs1_val_ini, sb_rs2_p : sb.rs2, sb_rs2_v : sb.rs2_val_ini, sb_imm : sb.imm_val_sign_ext,
            //       inst_PC : `CORE.PC, inst_XIDATA : `CORE.XIDATA, sb_DADDR : sb.DADDR, sb_DATAI : sb.DATAI};
            ex_dbuf = '{inst: ex_dbuf.inst, instruccion : ex_dbuf.instruccion, risc_rd_p : intf2.DPTR, risc_rd_v : risc_rd_reg_value, risc_rs1_p : intf2.S1PTR, 
						risc_rs1_v : intf2.S1REG, risc_rs2_p : intf2.S2PTR, risc_rs2_v : intf2.S2REG, risc_imm : (ex_dbuf.instruccion == SLTIU ? intf2.XUIMM : intf2.XSIMM),
						inst_PC : `CORE.PC, inst_XIDATA : `CORE.XIDATA, inst_counter : '0, risc_sdata : intf2.SDATA, risc_daddr : `CORE.DADDR, be : `CORE.BE};//
            
         end         
         //  end//Work out of reset
      end
   end
endtask

function void uvc2_mon::build_phase(uvm_phase phase);
   super.build_phase(phase);

   mon2_txn = new("mon2_txn", this);
   if(uvm_config_db #(virtual intf_mon2)::get(this, "", "VIRTUAL_INTERFACE_MONITOR2", intf2) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface 2 for the TB")
   end
   
   uvm_report_info(get_full_name(),"End_of_build_phase Monitor 2", UVM_LOW);
   print();
endfunction

function void uvc2_mon::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //   drv.seq_item_port.connect(seqr.seq_item_export);
endfunction

function string uvc2_mon::inst_resize(string inst);
   inst = (inst.len() < 3) ? {inst, "   "} :
          (inst.len() < 4) ? {inst, "  "} :
          (inst.len() < 5) ? {inst, " "} : inst;
   return inst;
endfunction

// function void notify_transaction(ExData data);
//    return transactions
//    wb_mon_ap.write(data);
// endfunction : notify_transaction
