`include "../testbench/testbench.sv"    
module top();
//   reg _clk = 0;
//   initial // clock generator
//   forever #5 _clk = ~_clk;
   
  // external clk generator
  reg CLK = 0;
  always begin
    #(500e6/`BOARD_CK) CLK = !CLK;
  end 
  
  // Interface
  intf_soc intf(CLK);
   
  // DUT connection	
    darksocv soc0 (
	    .XCLK(CLK),
	    .XRES(intf.rst),
	    .UART_RXD(intf.uart_rx),
	    .UART_TXD(intf_uart_tx),
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
  
  genvar inst;
  generate
    // for(inst=(2**`MLEN/4)-5; inst<(2**`MLEN/4); inst=inst+1)begin
    for(inst=0; inst<20; inst=inst+1)begin
        logic [31:0] inst_dmpd;
        assign inst_dmpd = soc0.MEM[inst];
    end
  endgenerate

  // .vcd generator
  integer i;
  initial begin
      $dumpfile("darksocv.vcd");
      $dumpvars();

  end
  
   //Test case
  testcase test(intf);
  
  // Esto queda del top pasado, por si acaso tiene una utilidad que desocnozco lo dejo comentado ATTE: jesus xd
  /*reg [31:0][31:0] REGS_DUMP; //Si no funciona, usar
  initial begin
    `ifdef __ICARUS__
            // $dumpfile("darksocv.vcd"); //Now in dsim simulation config 
            $dumpvars();

        `ifdef __REGDUMP__
            
            for(i=0; i<32; i=i+1)
            begin
              assign REGS_DUMP = soc0.core0.REGS[i];
            end    
//             for(i=0;i!=`RLEN;i=i+1)
//             begin
//                 $dumpvars(0,soc0.core0.REGS[i]);
//             end
        `endif
    `endif
      
        $display("reset (startup)");
        #1e3    RES = 0;            // wait 1us in reset state
  end */
endmodule
