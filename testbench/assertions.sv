`define RTL_PATH top.soc0.core0

module assertions (
    input logic CLK,
    input logic RES
);
    // Aserción para cumplir que las instrucciones se encuentren dentro de su rango de memoria asignado 
    check_daddr_within_valid_ranges: assert property (
        @(posedge CLK) disable iff (RES === 1)
        ( `RTL_PATH.XIDATA[6:0]==I_L_TYPE |-> ((`RTL_PATH.DADDR/4)>511) && ((`RTL_PATH.DADDR/4)<1024) )
    );

    // Aserción conflicto de instrucciones. No puede estarse cargando más de un tipo de instrucción
    assert property (@(posedge CLK) (count_ones({`RTL_PATH.RCC, `RTL_PATH.LCC, `RTL_PATH.SCC, `RTL_PATH.MCC,
    `RTL_PATH.LUI, `RTL_PATH.AUIPC, `RTL_PATH.JAL, `RTL_PATH.JALR, `RTL_PATH.BCC}) <= 1)); // 9 aserstion en 1

    // Aserción conflicto de instrucciones. No puede estarse cargando ninguna instrucción en IDLE
    assert property (@(posedge CLK) ((`RTL_PATH.IDLE == 1) |-> (!`RTL_PATH.RCC && !`RTL_PATH.LCC && !`RTL_PATH.SCC && !`RTL_PATH.MCC && !`RTL_PATH.LUI && !`RTL_PATH.AUIPC && !`RTL_PATH.JAL && !`RTL_PATH.JALR && !`RTL_PATH.BCC)));
 // 9 aserstion en 1

    // Aserción conflicto de instrucciones. No puede estarse cargando ninguna instrucción en IDLE
    assert property (@(posedge CLK) ((`RTL_PATH.FLUSH == 1) |-> (!`RTL_PATH.RCC && !`RTL_PATH.LCC && !`RTL_PATH.SCC && !`RTL_PATH.MCC && !`RTL_PATH.LUI && !`RTL_PATH.AUIPC && !`RTL_PATH.JAL && !`RTL_PATH.JALR && !`RTL_PATH.BCC)));
 // 9 aserstion en 1

    // Aserción para verificar que cuando RD esté en 1, indica LCC(carga de datos), se hace un halt(HLT) para no modificar otros registros
    check_rd_and_lcc_valid_status: assert property (
        @(posedge CLK) disable iff (RES) (`RTL_PATH.RD == 1) |-> (`RTL_PATH.LCC == 1)); //(`RTL_PATH.LCC == 1) & (`RTL_PATH.HLT == 1)

    // Aserción para verificar que cuando  WR esté en 1, indica SCC(salvado de datos)
        check_wr_and_scc_valid_status: assert property (
            @(posedge CLK) disable iff (RES) (`RTL_PATH.WR == 1) |-> (`RTL_PATH.SCC == 1));

    // Aserción para verificar que el reloj tenga transiciones de 0 a 1
        check_clk_one : assert property (
            @(posedge CLK) disable iff (RES) (CLK == 0));
    
    // Aserción para verificar que el reloj tenga transiciones de 1 a 0
        check_clk_cero : assert property (
            @(negedge CLK) disable iff (RES) (CLK == 1));

    // Función para contar el número de señales en 1
        function automatic int count_ones(input logic [8:0] sig);
            int count;
            count = 0;
            for (int i = 0; i < 9; i++) begin
                count += sig[i];
            end
            return count;
        endfunction

endmodule