`define RTL_PATH top.soc0.core0

module assertions (
    input logic CLK,
    input logic RES
);

    check_daddr_within_valid_ranges: assert property (
        @(posedge CLK) disable iff (RES === 1)
        ( `RTL_PATH.XIDATA[6:0]==I_L_TYPE |-> ((`RTL_PATH.DADDR/4)>511) && ((`RTL_PATH.DADDR/4)<1024) )
    );

    // Aserción para verificar que cuando HLT esté en 1, LCC también lo esté
    check_htl_and_lcc_valid_status: assert property (
        @(posedge CLK) disable iff (RES === 1) (`RTL_PATH.HLT == 1) |-> (`RTL_PATH.LCC == 1))
        else $fatal("A fatal error has occurred HLT & LCC mismatch");

endmodule