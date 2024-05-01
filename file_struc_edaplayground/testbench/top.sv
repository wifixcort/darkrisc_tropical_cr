module top();
//   reg _clk = 0;
//   initial // clock generator
//   forever #5 _clk = ~_clk;
   
    reg CLK = 0;
    
    reg RES = 1;

    initial while(1) #(500e6/`BOARD_CK) CLK = !CLK; // clock generator w/ freq defined by config.vh
  
	integer i;
  
  // Interface

  wire TX;
  wire RX = 1;

  
  // DUT connection	
	darksocv soc0
    (
        .XCLK(CLK),
        .XRES(|RES),
        .UART_RXD(RX),
        .UART_TXD(TX)
    );
  
  initial begin
    `ifdef __ICARUS__
            $dumpfile("darksocv.vcd");
            $dumpvars();

        `ifdef __REGDUMP__
            for(i=0;i!=`RLEN;i=i+1)
            begin
                $dumpvars(0,soc0.core0.REGS[i]);
            end
        `endif
    `endif
      
        $display("reset (startup)");
        #1e3    RES = 0;            // wait 1us in reset state
  end
  
  //Test case
  
  testcase test();

endmodule
