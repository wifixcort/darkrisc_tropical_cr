`include "uvm_macros.svh"
import uvm_pkg::*;

module top();

   // external clk generator
   reg CLK = 1;
   always begin
      #(500e6/`BOARD_CK) CLK = !CLK;
   end 
   
   // Interface
   intf_soc intf(CLK);
   intf_mon2 intf2(CLK);
   intf_mem_rd mem_rd_chan(CLK);
   intf_dmp int_dmp(CLK);
   //logic reset_x;

   //Assign data to the virtual interface used by the monitor 1
   assign mem_rd_chan.IADDR = soc0.IADDR;
   assign mem_rd_chan.IDATA = soc0.IDATA;


   //Assign data to the virtual interface used by the monitor 2
   assign intf2.RMDATA = top.soc0.core0.RMDATA;
   assign intf2.LDATA  = top.soc0.core0.LDATA;
   assign intf2.SDATA  = top.soc0.core0.SDATA;

   assign intf2.XSIMM  = top.soc0.core0.XSIMM;
   assign intf2.XUIMM  = top.soc0.core0.XUIMM;
   assign intf2.XIDATA = top.soc0.core0.XIDATA;

   assign intf2.DPTR   = top.soc0.core0.DPTR;
   assign intf2.S1PTR  = top.soc0.core0.S1PTR;
   assign intf2.S1REG  = top.soc0.core0.S1REG;
   assign intf2.U1REG  = top.soc0.core0.U1REG;
   assign intf2.S2PTR  = top.soc0.core0.S2PTR;
   assign intf2.S2REG  = top.soc0.core0.S2REG;
   assign intf2.U2REG  = top.soc0.core0.U2REG;
   assign intf2.DATAO  = top.soc0.core0.DATAO;
   assign intf2.DATAI  = top.soc0.core0.DATAI;
   assign intf2.HLT    = top.soc0.core0.HLT;
   // assign intf2.REGS = top.soc0.core0.REGS;

   // DUT connection	
   darksocv soc0 (
				  .XCLK(CLK),
				  .XRES(intf.rst),
     			  .UART_RXD(intf.uart_rx),
				  .UART_TXD(intf.uart_tx),
				  .LED(intf.leds),
				  .DEBUG(intf.debug));

   // generate dumps

   genvar q;
   generate 
      for(q=0; q<32; q=q+1)begin 
    	 logic [31:0] reg_dmpd;
         assign reg_dmpd = soc0.core0.REGS[q];
      end
   endgenerate
    /*  
   genvar			  inst;
   generate
      // for(inst=(2**`MLEN/4)-5; inst<(2**`MLEN/4); inst=inst+1)begin
      for(inst=0; inst<20; inst=inst+1)begin
         logic [31:0] inst_dmpd;
         assign inst_dmpd = soc0.MEM[inst];
      end
   endgenerate

   // .vcd generator
   */

   initial begin
        $dumpfile("darksocv.vcd");
        $dumpvars();
        uvm_config_db #(virtual intf_soc)::set (null, "*", "VIRTUAL_INTERFACE", intf);
        uvm_config_db #(virtual intf_mon2)::set (null, "*", "VIRTUAL_INTERFACE_MONITOR2", intf2);
        uvm_config_db #(virtual intf_mem_rd)::set (null, "*", "VIRTUAL_INTERFACE_MEM_RD", mem_rd_chan);
        uvm_config_db #(virtual intf_dmp)::set (null, "*", "VIRTUAL_INTERFACE_DMP", int_dmp);
     	//reset_x = 1;
     	//#3000
     	//reset_x = 0;
   end
   
   //Test case
   //testcase test(intf);  Para el port a UVM esta linea se pone en el top_hvl  

   /*
   logic [31:0] scbdreg_dmpd1;
   logic [31:0]	scbdreg_dmpd0;
   logic [31:0]	scbdreg_dmpd2;
   logic [31:0]	scbdreg_dmpd3;
   logic [31:0]	scbdreg_dmpd4;
   logic [31:0]	scbdreg_dmpd5;
   logic [31:0]	scbdreg_dmpd6;
   logic [31:0]	scbdreg_dmpd7;
   logic [31:0]	scbdreg_dmpd8;
   logic [31:0]	scbdreg_dmpd9;
   logic [31:0]	scbdreg_dmpd10;
   logic [31:0]	scbdreg_dmpd11;
   logic [31:0]	scbdreg_dmpd12;
   logic [31:0]	scbdreg_dmpd13;
   logic [31:0]	scbdreg_dmpd14;
   logic [31:0]	scbdreg_dmpd15;
   logic [31:0]	scbdreg_dmpd16;
   logic [31:0]	scbdreg_dmpd17;
   logic [31:0]	scbdreg_dmpd18;
   logic [31:0]	scbdreg_dmpd19;
   logic [31:0]	scbdreg_dmpd20;
   logic [31:0]	scbdreg_dmpd21;
   logic [31:0]	scbdreg_dmpd22;
   logic [31:0]	scbdreg_dmpd23;
   logic [31:0]	scbdreg_dmpd24;
   logic [31:0]	scbdreg_dmpd25;
   logic [31:0]	scbdreg_dmpd26;
   logic [31:0]	scbdreg_dmpd27;
   logic [31:0]	scbdreg_dmpd28;
   logic [31:0]	scbdreg_dmpd29;
   logic [31:0]	scbdreg_dmpd30;
   logic [31:0]	scbdreg_dmpd31;  
   */


endmodule