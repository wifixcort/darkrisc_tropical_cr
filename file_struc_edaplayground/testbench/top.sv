module top();
  
   // external clk generator
  reg clk = 0;
  initial while(1) #(500e6/`BOARD_CK) clk = !clk; // clock generator w/ freq defined by config.vh
  
   // Interface
  intf_soc intf(clk);

  
  // DUT connection	
  darksocv soc0(
    .XCLK(clk),
    .XRES(intf.rst),
    .UART_RXD(intf.uart_rx),
    .UART_TXD(intf.uart_tx),
    .LED(led),
    .DEBUG(debug)
  );

  
  // .vcd generator
  integer i;
  initial begin
      $dumpfile("darksocv.vcd");
      $dumpvars();
      for(i=0;i!=`RLEN;i=i+1) begin
          $dumpvars(0,soc0.core0.REGS[i]);
      end
      //$display("reset (startup)");
      //#1e3    intf.rst = 0;            // wait 1us in reset state
  end
  

  
  //Test case
  testcase test(intf);

endmodule