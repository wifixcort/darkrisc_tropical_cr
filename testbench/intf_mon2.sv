/* ============================================
    darksocv inputs and outputs interface
 ============================================ */

interface intf_mon2(input clk, input res);
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
  //MEM Interface
  logic [31:0]  DADDR;
  // logic [31:0]  REGS [0:31];
endinterface

module mon2_assertion (
    input logic CLK,
    input logic RES,
    input logic [31:0] XIDATA,
    input logic [31:0] DADDR
);

    assert property (
        @(posedge CLK) disable iff (RES === 1)
        ( XIDATA[6:0]==I_L_TYPE |-> ((DADDR/4)>511) && ((DADDR/4)<1024) )
    );

endmodule
