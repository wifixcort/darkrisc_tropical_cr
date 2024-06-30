/* ============================================
    darksocv inputs and outputs interface
 ============================================ */

interface intf_mon2(input clk);
  //Data being produced or used in the ALU(s)
  //Produced
  logic [31:0]	RMDATA;
  logic [31:0]	LDATA;
  logic [31:0]	SDATA;
  //Used
  logic [31:0]  XSIMM;
  logic [31:0]  XUIMM;
  logic [31:0]  XIDATA;
  //Register connections
  logic [4:0]   DPTR;
  logic [4:0]   S1PTR;
  logic [31:0]  S1REG;
  logic [31:0]  U1REG;
  logic [4:0]   S2PTR;
  logic [31:0]  S2REG;
  logic [31:0]  U2REG;
  logic [31:0]  DATAO;
  logic [31:0]  DATAI;
  bit           HLT;
  // logic [31:0]  REGS [0:31];
endinterface
