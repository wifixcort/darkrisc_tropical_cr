/* ============================================
    darksocv inputs and outputs interface
 ============================================ */

interface intf_mem_rd(input clk);
    logic [31:0]    IADDR;
    logic [31:0]    IDATA;
endinterface
