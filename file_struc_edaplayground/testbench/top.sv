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
  
  genvar q;
  generate
    for(q=0; q<32; q=q+1)begin
    	logic [31:0] reg_dmpd;
        assign reg_dmpd = soc0.core0.REGS[q];
    end
  endgenerate
  
  genvar inst;
  generate
    for(inst=0; inst<32; inst=inst+1)begin
        logic [31:0] inst_dmpd;
        assign inst_dmpd = soc0.MEM[inst];
    end
  endgenerate

  
  // DUT connection	
	darksocv soc0
    (
        .XCLK(CLK),
        .XRES(|RES),
        .UART_RXD(RX),
        .UART_TXD(TX)
    );
  reg [31:0][31:0] REGS_DUMP; //Si no funciona, usar
  initial begin
    `ifdef __ICARUS__
            $dumpfile("darksocv.vcd");
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
  end
  
  //Test case
  
  testcase test();

endmodule
