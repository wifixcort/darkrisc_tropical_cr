`define RTL_PATH top.soc0.core0

module assertions (
				   input logic CLK,
				   input logic RES
				   );
   // Aserción para cumplir que las instrucciones se encuentren dentro de su rango de memoria asignado 
   check_daddr_within_valid_ranges: assert property (
													 @(posedge CLK) disable iff (RES === 1)
													 ( `RTL_PATH.XIDATA[6:0]==I_L_TYPE |-> ((`RTL_PATH.DADDR/4)>511) && ((`RTL_PATH.DADDR/4)<1023) )
													 );

   // Aserción conflicto de instrucciones. No puede estarse cargando más de un tipo de instrucción
   check_one_instruction_at_a_time: assert property (
													 @(posedge CLK) (count_ones({`RTL_PATH.RCC, `RTL_PATH.LCC, `RTL_PATH.SCC, `RTL_PATH.MCC,
																				 `RTL_PATH.LUI, `RTL_PATH.AUIPC, `RTL_PATH.JAL, `RTL_PATH.JALR, `RTL_PATH.BCC}) <= 1)); 
   // 9 aserstion en 1

   // Aserción conflicto de instrucciones. No se puede hacer WB de ninguna instrucción en IDLE
   check_no_instruction_on_idle: assert property (
												  @(posedge CLK) ((`RTL_PATH.IDLE == 1) |-> (!`RTL_PATH.RCC && !`RTL_PATH.LCC && !`RTL_PATH.SCC && !`RTL_PATH.MCC && !`RTL_PATH.LUI && !`RTL_PATH.AUIPC && !`RTL_PATH.JAL && !`RTL_PATH.JALR && !`RTL_PATH.BCC)));
   // 9 aserstion en 1

   // Aserción conflicto de instrucciones. No se puede hacer WB de ninguna instrucción en FLUSH
   check_no_instruction_on_flush: assert property (@(posedge CLK) ((`RTL_PATH.FLUSH == 1) |-> (!`RTL_PATH.RCC && !`RTL_PATH.LCC && !`RTL_PATH.SCC && !`RTL_PATH.MCC && !`RTL_PATH.LUI && !`RTL_PATH.AUIPC && !`RTL_PATH.JAL && !`RTL_PATH.JALR && !`RTL_PATH.BCC)));
   // 9 aserstion en 1

   // Aserción para verificar que cuando RD esté en 1, indica LCC(carga de datos)
   check_rd_and_lcc_valid_status: assert property (@(posedge CLK) disable iff (RES) (`RTL_PATH.RD == 1) |-> (`RTL_PATH.LCC == 1)); 

   // Aserción en lectura se hace un halt(HLT) para darle un ciclo de tiempo al procesador a acceder al dato en memoria
   check_rd_and_hlt_valid_status: assert property (@(posedge CLK) disable iff (RES) $rose(`RTL_PATH.RD) |-> (`RTL_PATH.HLT == 1) ##1 (`RTL_PATH.HLT == 0));

   // Aserción para verificar que cuando WR esté en 1, indica SCC(salvado de datos)
   check_wr_and_scc_valid_status: assert property (@(posedge CLK) disable iff (RES) (`RTL_PATH.WR == 1) |-> (`RTL_PATH.SCC == 1));

   // Aserción para verificar que el reloj tenga transiciones de 0 a 1
   check_clk_one : assert property (@(posedge CLK) disable iff (RES) (CLK == 0));
   
   // Aserción para verificar que el reloj tenga transiciones de 1 a 0
   check_clk_cero : assert property (@(negedge CLK) disable iff (RES) (CLK == 1));

   // Aserción el valor al registro cero, siempre es cero
   reg_cero : assert property( @(negedge CLK)  (`RTL_PATH.REGS[0] == '0));

   // Aserción para verificar que cuando se cumple condicion de salto se pida un JREQ
   check_jump_jreq : assert property (@(posedge CLK) disable iff (RES) (`RTL_PATH.JAL || `RTL_PATH.JALR || (`RTL_PATH.BCC && `RTL_PATH.BMUX)) |-> (`RTL_PATH.JREQ == 1));
  
   // Aserción que dos ciclos después de un JREQ el PC cambia
   check_jreq_pc_n : assert property (@(posedge CLK) (`RTL_PATH.JREQ == 1) |-> ##2 (`RTL_PATH.PC != $past(`RTL_PATH.PC, 2)));

   // Aserción PC no cambia dentro de HLT
   check_pc_hlt : assert property (@(posedge CLK) disable iff (RES) $rose(`RTL_PATH.HLT) |-> ##1 (`RTL_PATH.PC == $past(`RTL_PATH.PC, 1)));

   // Aserción PC changes after reset
   check_pc_res_fall : assert property (@(posedge CLK) $fell(`RTL_PATH.XRES) |-> ##3 (`RTL_PATH.PC != 0)) ;

   // Aserción PC goes to 0 when reset activates
   check_pc_init_res : assert property (@(posedge CLK) (`RTL_PATH.XRES == 1) |-> ##3 (`RTL_PATH.PC == 0)) ;

   // Aserción FLUSH no cambia dentro de HLT
   check_flush_hlt : assert property (@(posedge CLK) disable iff (RES) $rose(`RTL_PATH.HLT) |-> $stable(`RTL_PATH.FLUSH));
   
   // Aserción PC is stable during reset after 3 cycles, if reset keeps being 1


   // Aserción Overflow
   

   // Función para contar el número de señales en 1
   function automatic int count_ones(input logic [8:0] sig);
      int					   count;
      count = 0;
      for (int i = 0; i < 9; i++) begin
         count += sig[i];
      end
      return count;
   endfunction

endmodule
