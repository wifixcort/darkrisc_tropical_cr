/* ============================================
    darksocv inputs and outputs interface
 ============================================ */

interface intf_soc(input clk);
  logic 		  rst;
  logic 		  uart_rx;
  logic 		  uart_tx;
  logic [3:0]	leds;
  logic [3:0]	debug;
endinterface
