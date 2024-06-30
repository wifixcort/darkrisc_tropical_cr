/* ============================================
    darksocv inputs and outputs interface
 ============================================ */

interface intf_dmp(input clk);
  //Data being produced or used in the ALU(s)
  //Produced
  logic [31:0] sb_dump;
  // logic [31:0]  REGS [0:31];
endinterface
