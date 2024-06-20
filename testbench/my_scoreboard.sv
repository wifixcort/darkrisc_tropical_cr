`uvm_analysis_imp_decl( _mon1 )
`uvm_analysis_imp_decl( _mon2 ) 
class my_scoreboard extends uvm_scoreboard;

   `uvm_component_utils(my_scoreboard)
   uvm_analysis_imp_mon1#(monitor_tr, my_scoreboard) txn_mon1;
   uvm_analysis_imp_mon2#(monitor_tr, my_scoreboard) txn_mon2;

   function new(string name, uvm_component parent);
      super.new(name, parent);
      txn_mon1 = new("txn_mon1", this);
      txn_mon2 = new("txn_mon2", this);
   endfunction
   
   virtual function void build_phase(uvm_phase phase);

   endfunction

   // virtual function void connect_phase(uvm_phase phase);
   //     super.connect_phase(phase);
   //   endfunction

   function void  write_mon2(monitor_tr tr);
      uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
      // print();
      //R TYPE
      if(tr.instruction == ADD || tr.instruction == SUB || tr.instruction == SLL || tr.instruction == SLT || 
		 tr.instruction == SLTU || tr.instruction == XOR || tr.instruction == SRL || tr.instruction == SRA || 
		 tr.instruction == AND || tr.instruction == OR)begin
		 //  $display("-------------------------------------------------------------------------------------------->");
		 $display("------------------------- R type -------------------------");
		 //  r_type_cheker_rd_rs1_rs2(tr.inst ,tr.instruction, tr.risc_rd_p, `CORE.REGS[tr.risc_rd_p], 
		 //             tr.risc_rs1_p, tr.risc_rs1_v, tr.risc_rs2_p, tr.risc_rs2_v, tr.sb_rd_p,
		 //             tr.sb_rd_v, tr.sb_rs1_p, tr.sb_rs1_v, tr.sb_rs2_p, tr.sb_rs2_v);
		 // tr.risc_rd_v = `CORE.REGS[tr.risc_rd_p];
		 //  $display("--------------------------------------------------------------------------------------------<");

		 //I TYPE
	  end	else if(tr.instruction == ADDI || tr.instruction == SLTI || tr.instruction == SLTIU || tr.instruction == XORI ||
					tr.instruction == ORI || tr.instruction == ANDI || tr.instruction == SLLI || tr.instruction == SRLI ||
					tr.instruction == SRAI)begin
		 //  $display("-------------------------------------------------------------------------------------------->");
		 $display("------------------------- I type -------------------------");
		 // i_type_cheker_rd_rs1_imm(tr.inst ,tr.instruction, tr.risc_rd_p, `CORE.REGS[tr.risc_rd_p], 
		 //            tr.risc_rs1_p, tr.risc_rs1_v, tr.risc_imm, tr.sb_rd_p, tr.sb_rd_v,
		 //            tr.sb_rs1_p, tr.sb_rs1_v, tr.sb_imm, tr.inst_counter);
		 //  $display("--------------------------------------------------------------------------------------------<");

		 //I_L TYPE
	  end else if(tr.instruction == LB || tr.instruction == LH || tr.instruction == LW || tr.instruction == LBU || 
				  tr.instruction == LHU) begin
		 //  $display("-------------------------------------------------------------------------------------------->");
		 $display("------------------------- IL type -------------------------");
		 //  i_l_type_cheker_rd_imm_rs1(tr.inst ,tr.instruction, tr.risc_rd_p, `CORE.REGS[tr.risc_rd_p], 
		 //               tr.risc_rs1_p, tr.risc_rs1_v, tr.risc_imm, tr.sb_rd_p, tr.sb_rd_v,
		 //               tr.sb_rs1_p, tr.sb_rs1_v, tr.sb_imm);
		 //  $display("--------------------------------------------------------------------------------------------<");

	  end
      //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
   endfunction

   function void  write_mon1(monitor_tr tr);
      //uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
      //print();
      //$display("hello mon1 working on SCB");
      //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
   endfunction

//    task automatic i_type_cheker_rd_rs1_imm(
// 										   string			  inst,
// 										   input logic [7:0]  instruccion,
// 										   input logic [31:0] risc_rd_p, // riscv rd register pointer
// 										   input logic [31:0] risc_rd_v, // riscv rd register value
// 										   input logic [31:0] risc_rs1_p, // riscv rs1 register pointer
// 										   input logic [31:0] risc_rs1_v, // riscv rs1 register value
// 										   input logic [31:0] risc_imm, // riscv immidiate value
// 										   input logic [31:0] sb_rd_p, // sb rd register pointer
// 										   input logic [31:0] sb_rd_v, // sb rd register value
// 										   input logic [31:0] sb_rs1_p, // sb rs1 register pointer
// 										   input logic [31:0] sb_rs1_v, // sb rs1 register value
// 										   input logic [31:0] sb_imm); // sb immidiate value

// 	  bit													  function_check;
// 	  bit													  rd_p_check;	  
// 	  bit													  rd_v_check;
// 	  bit													  rs1_p_check;
// 	  bit													  rs1_v_check;
// 	  bit													  imm_check;
// 	  bit													  general_check;

// 	  begin

// 		 inst = inst_resize(inst);
// 		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
// 		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
// 		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
// 		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
// 		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
// 		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
// 		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
// 			general_check = `FALSE;//No paso la pueba
// 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
// 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
// 			$display("PC = %h, inst = %h", top.soc0.core0.PC, `XIDATA);
// 			$display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
// 			err_count++; 
// 		 end else begin
// 			general_check = `TRUE;//Si paso la prueba
// `ifdef __DB_PASS__ 
// 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
// 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
// 			$display("PC = %h, inst = %h", top.soc0.core0.PC, `XIDATA);
// 			$display("sb DADDR = %h , sb DATAI = %h", sb.ref_model.DADDR, sb.ref_model.DATAI);
// `endif
// 		 end
// 	  end
//    endtask: i_type_cheker_rd_rs1_imm

   //    task r_type_cheker_rd_rs1_rs2(
   // 								 string				inst,
   // 								 input logic [7:0]	instruccion,
   // 								 input logic [31:0]	risc_rd_p, // riscv rd register pointer
   // 								 input logic [31:0]	risc_rd_v, // riscv rd register value
   // 								 input logic [31:0]	risc_rs1_p, // riscv rs1 register pointer
   // 								 input logic [31:0]	risc_rs1_v, // riscv rs1 register value
   // 								 input logic [31:0]	risc_rs2_p, // riscv rs2 register pointer
   // 								 input logic [31:0]	risc_rs2_v, // riscv rs2 register value
   // 								 input logic [31:0]	sb_rd_p, // sb rd register pointer
   // 								 input logic [31:0]	sb_rd_v, // sb rd register value
   // 								 input logic [31:0]	sb_rs1_p, // sb rs1 register pointer
   // 								 input logic [31:0]	sb_rs1_v, // sb rs1 register value
   // 								 input logic [31:0]	sb_rs2_p, // sb rs1 register pointer
   // 								 input logic [31:0]	sb_rs2_v ); // sb immidiate value

   // 	  bit											function_check;
   // 	  bit											rd_p_check;	  
   // 	  bit											rd_v_check;
   // 	  bit											rs1_p_check;
   // 	  bit											rs1_v_check;
   // 	  bit											rs2_p_check;
   // 	  bit											rs2_v_check;
   // 	  bit											general_check;

   // 	  begin

   // 		 inst = inst_resize(inst);
   // 		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
   // 		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
   // 		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
   // 		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
   // 		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
   // 		 rs2_p_check = (risc_rs2_p == sb_rs2_p) ? `TRUE : `FALSE;
   // 		 rs2_v_check = (risc_rs2_v == sb_rs2_v) ? `TRUE : `FALSE;
   // 		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !rs2_p_check || !rs2_v_check)begin
   // 			general_check = `FALSE;//No paso la pueba
   // 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", general_check?"PASS":"ERROR");
   // 			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
   // 			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
   // 			err_count++; 
   // 		 end else begin
   // 			general_check = `TRUE;//Si paso la prueba
   // `ifdef __DB_PASS__ 
   // 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", general_check?"PASS":"ERROR");
   // `endif
   // 		 end
   // 	  end
   //    endtask: r_type_cheker_rd_rs1_rs2

   //    task automatic i_l_type_cheker_rd_imm_rs1(
   // 											 string				inst,
   // 											 input logic [7:0]	instruccion,
   // 											 input logic [31:0]	risc_rd_p, // riscv rd register pointer
   // 											 input logic [31:0]	risc_rd_v, // riscv rd register value
   // 											 input logic [31:0]	risc_rs1_p, // riscv rs1 register pointer
   // 											 input logic [31:0]	risc_rs1_v, // riscv rs1 register value
   // 											 input logic [31:0]	risc_imm, // riscv immidiate value
   // 											 input logic [31:0]	sb_rd_p, // sb rd register pointer
   // 											 input logic [31:0]	sb_rd_v, // sb rd register value
   // 											 input logic [31:0]	sb_rs1_p, // sb rs1 register pointer
   // 											 input logic [31:0]	sb_rs1_v, // sb rs1 register value
   // 											 input logic [31:0]	sb_imm); // sb immidiate value

   // 	  bit														function_check;
   // 	  bit														rd_p_check;	  
   // 	  bit														rd_v_check;
   // 	  bit														rs1_p_check;
   // 	  bit														rs1_v_check;
   // 	  bit														imm_check;
   // 	  bit														general_check;

   // 	  begin

   // 		 inst = inst_resize(inst);
   // 		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
   // 		 rd_p_check = (risc_rd_p == sb_rd_p) ? `TRUE : `FALSE;
   // 		 rd_v_check = (risc_rd_v == sb_rd_v) ? `TRUE : `FALSE;
   // 		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
   // 		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
   // 		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
   // 		 if(!function_check || !rd_p_check || !rd_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
   // 			general_check = `FALSE;//No paso la pueba
   // 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
   // 			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
   // 			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
   // 			err_count++; 
   // 		 end else begin
   // 			general_check = `TRUE;//Si paso la prueba
   // `ifdef __DB_PASS__ 
   // 			$display(" %d | %s | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | -------- | -------- | --- | -------- | -------- | --- | %h | %h | %s |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_rd_p, sb_rd_p, rd_p_check?"PASS":"X", risc_rd_v, sb_rd_v, rd_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
   // `endif
   // 		 end
   // 	  end
   //    endtask: i_l_type_cheker_rd_imm_rs1

   //    task automatic s_type_cheker_rv2_imm_rs1(
   // 											string			   inst,
   // 											input logic [7:0]  instruccion,
   // 											input logic [31:0] risc_datao_v, // riscv datao register value
   // 											input logic [31:0] risc_rs2_p, // riscv rs2 register pointer
   // 											input logic [31:0] risc_rs2_v, // riscv rs2 register value
   // 											input logic [31:0] risc_imm, // riscv immidiate value
   // 											input logic [31:0] risc_rs1_p, // riscv rs1 register pointer
   // 											input logic [31:0] risc_rs1_v, // riscv rs1 register value
   // 											input logic [31:0] sb_datao_v, // sb dato register value
   // 											input logic [31:0] sb_rs2_p, // sb rs2 register pointer
   // 											input logic [31:0] sb_rs2_v, // sb rs2 register value
   // 											input logic [31:0] sb_imm, // sb immidiate value
   // 											input logic [31:0] sb_rs1_p, // sb rs1 register pointer
   // 											input logic [31:0] sb_rs1_v); // sb rs1 register value

   // 	  bit													   function_check;
   // 	  bit													   datao_v_check;
   // 	  bit													   rs1_p_check;
   // 	  bit													   rs1_v_check;
   // 	  bit													   rs2_p_check;
   // 	  bit													   rs2_v_check;
   // 	  bit													   imm_check;
   // 	  bit													   general_check;

   // 	  begin

   // 		 inst = inst_resize(inst);
   // 		 function_check = (sb.rx_funct == instruccion) ? `TRUE : `FALSE;
   // 		 datao_v_check = (risc_datao_v == sb_datao_v) ? `TRUE : `FALSE;
   // 		 rs2_p_check = (risc_rs2_p == sb_rs2_p) ? `TRUE : `FALSE;
   // 		 rs2_v_check = (risc_rs2_v == sb_rs2_v) ? `TRUE : `FALSE;
   // 		 rs1_p_check = (risc_rs1_p == sb_rs1_p) ? `TRUE : `FALSE;
   // 		 rs1_v_check = (risc_rs1_v == sb_rs1_v) ? `TRUE : `FALSE;
   // 		 imm_check = (risc_imm == sb_imm) ? `TRUE : `FALSE;
   // 		 if(!function_check || !datao_v_check || !rs2_p_check || !rs2_v_check || !rs1_p_check || !rs1_v_check || !imm_check)begin
   // 			general_check = `FALSE;//No paso la pueba
   // 			$display(" %d | %s | %s | -------- | DATAO--> | --- | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_datao_v, sb_datao_v, datao_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
   // 			$display("PC = %h, inst = %h", ex_dbuf.inst_PC, ex_dbuf.inst_XIDATA );
   // 			$display("sb DADDR = %h , sb DATAI = %h", ex_dbuf.sb_DADDR, ex_dbuf.sb_DATAI);
   // 			$display("sb MEM[DADDR] = %h ", sb.ref_model.MEM[ex_dbuf.sb_DADDR]);

   // 			err_count++; 
   // 		 end else begin
   // 			general_check = `TRUE;//Si paso la prueba
   // `ifdef __DB_PASS__ 
   // 			$display(" %d | %s | %s | -------- | DATAO--> | --- | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s | %h | %h | %s |                              *** %s ***", 
   // 					 inst_counter, inst, function_check?"PASS":"X", risc_datao_v, sb_datao_v, datao_v_check?"PASS":"X", risc_rs1_p, sb_rs1_p, rs1_p_check?"PASS":"X", risc_rs1_v, sb_rs1_v, rs1_v_check?"PASS":"X", risc_rs2_p, sb_rs2_p, rs2_p_check?"PASS":"X", risc_rs2_v, sb_rs2_v, rs2_v_check?"PASS":"X", risc_imm, sb_imm, imm_check?"PASS":"X", general_check?"PASS":"ERROR");
   // `endif
   // 		 end
   // 	  end
   //    endtask: s_type_cheker_rv2_imm_rs1
   function automatic string inst_resize(string inst);
	  inst = (inst.len() < 3) ? {inst, "   "} :
			 (inst.len() < 4) ? {inst, "  "} :
			 (inst.len() < 5) ? {inst, " "} : inst;
	  return inst;
   endfunction

endclass
