import instructions_data_struc::*;

`define IDATA_PATH top.soc0.core0.IDATA
`define IADDR_PATH top.soc0.core0.IADDR
`define CLK_PATH top.soc0.core0.CLK

class instr_monitor;

    logic [7:0]     rx_funct;
    logic [7:0]     pc_val;
    logic signed [20:0]    imm_val;
    logic signed [31:0]    imm_val_ext_full;
    logic [4:0]     rs1_val;
    logic [4:0]     rs2_val;
    logic [4:0]     rdd_val;
    logic [6:0]     opcode;

    logic [2:0]     fct3;
    logic [6:0]     fct7;
  
    logic [31:0]    IADDR, IADDR_old;
    logic [31:0]    IDATA;

    scoreboard      sb;

    //====================================================================
    //========================= Metodos ==================================
    //====================================================================
    // Construct driver
    function new(scoreboard sb);
        rx_funct = '0;
        pc_val  = '0;
        imm_val = '0;
        pc_val  = '0;
        rs1_val = '0;
        rs2_val = '0;
        rdd_val = '0;
        opcode  = '0;
        fct3    = '0;
        fct7    = '0;
        this.sb = sb;
    endfunction

    function decodify_instruction(reg [31:0] rx_pc_val, reg [31:0] rx_instruction, reg DBG_HIGH_VERBOSITY=0);
        rx_funct = '0;
        pc_val  = '0;
        imm_val = '0; //Update this depending on opcode+function values.PO
        rs1_val = rx_instruction[19:15];
        rs2_val = rx_instruction[24:20];
        rdd_val = rx_instruction[11:7];
        opcode  = rx_instruction[OPCODE_SIZE-1:0];
        fct3    = rx_instruction[14:12];
        fct7    = rx_instruction[31:25];

        //$display("Monitor 1 reportando instrucción %h", rx_instruction);
        //Build immediate value, which may be used for instruction decoding.
        case (opcode)
            R_TYPE      : imm_val = '0;
            I_TYPE      : imm_val = { { 9{(rx_instruction[31])}} , rx_instruction[31:20]}; //Concatenates sign, imm[11:0]
            I_L_TYPE    : imm_val = { { 9{(rx_instruction[31])}} , rx_instruction[31:20]}; //Concatenates sign, imm[11:0]
            I_JALR_TYPE : imm_val = { { 9{(rx_instruction[31])}} , rx_instruction[31:20]}; //Concatenates sign, imm[11:0]
            S_TYPE      : imm_val = { { 9{(rx_instruction[31])}} , rx_instruction[31:25] , rx_instruction[11:7]}; //Concatenates sign, imm[11:5] and imm[4:0]
            S_B_TYPE    : imm_val = { { 8{(rx_instruction[31])}} , rx_instruction[31] , rx_instruction[7] , rx_instruction[30:25] , rx_instruction[11:8] , 1'b0}; //Concatenates: imm[12], imm[11], imm[10:5] imm[4:1]
            LUI_TYPE    : imm_val = { { 1{(rx_instruction[31])}} , rx_instruction[31:12]}; //The program sees this as correct, but consider that U types 12 LSB set to 0
            AUIPC_TYPE  : imm_val = { { 1{(rx_instruction[31])}} , rx_instruction[31:12]}; //The program sees this as correct, but consider that U types 12 LSB set to 0
            J_TYPE      : imm_val = { { 1{(rx_instruction[31])}} , rx_instruction[31], rx_instruction[19:12], rx_instruction[20] , rx_instruction[30:21] , 1'b0}; //Concatenates imm[20], imm[19:12], imm[11], imm[10:1]
            default     : imm_val = '0;
        endcase

        imm_val_ext_full = {(imm_val[20])? '1 : '0, rx_instruction};

        //Decode instruction
        //R-arithmetic      
        if (opcode==R_TYPE)begin
            case (fct3)
                ADD_o_SUB_FC    : rx_funct = (fct7=='h00)? ADD : SUB;
                XOR_FC          : rx_funct = XOR;
                OR_FC           : rx_funct = OR;
                AND_FC          : rx_funct = AND;
                SLL_FC          : rx_funct = SLL;
                SRL_o_SRA_FC    : rx_funct = (fct7=='h00)? SRL : SRA;
                SLT_FC          : rx_funct = SLT;
                SLTU_FC         : rx_funct = SLTU;
                default         : rx_funct = ADD; 
            endcase
        end
        //Immediate ones
        else if (opcode==I_TYPE) begin
            case (fct3)
                ADDI_FC         : rx_funct = ADDI;
                XORI_FC         : rx_funct = XORI;
                ORI_FC          : rx_funct = ORI;
                ANDI_FC         : rx_funct = ANDI;
                SLLI_FC         : rx_funct = SLLI;
                SRLI_FC         : rx_funct = (imm_val[6:0]=='h00)? SRLI : SRAI;
                SLTI_FC         : rx_funct = SLTI;
                SLTIU_FC        : rx_funct = SLTIU;
                default         : rx_funct = ADDI; 
            endcase
        end
        //Loads
        else if (opcode==I_L_TYPE)begin
            case (fct3)
                LB_FC           : rx_funct = LB;
                LH_FC           : rx_funct = LH;
                LW_FC           : rx_funct = LW;
                LBU_FC          : rx_funct = LBU;
                LHU_FC          : rx_funct = LHU;
                default         : rx_funct = LB;
            endcase            
        end
        //Store
        else if (opcode==S_TYPE)begin
            case (fct3)
                SB_FC           : rx_funct = SB;
                SH_FC           : rx_funct = SH;
                SW_FC           : rx_funct = SW;
                default         : rx_funct = SB;
            endcase            
        end
        else if (opcode==S_B_TYPE)begin
            case (fct3)
                BEQ_FC          : rx_funct = BEQ;
                BNE_FC          : rx_funct = BNE;
                BLT_FC          : rx_funct = BLT;
                BGE_FC          : rx_funct = BGE;
                BLTU_FC         : rx_funct = BLTU;
                BGEU_FC         : rx_funct = BGEU;
                default         : rx_funct = BEQ;
            endcase            
        end
        else begin
            rx_funct =  (opcode == J_TYPE)?       JAL     :
                        (opcode == I_JALR_TYPE)?  JALR    :
                        (opcode == LUI_TYPE)?     LUI     :
                        (opcode == AUIPC_TYPE)?   AUIPC   :
                        AUIPC;
        end
        
        if (DBG_HIGH_VERBOSITY) begin //Only for debugging. This prints all the fields (some may not be correct due to instruction type, be aware)
//            $display("Function: %d, r1=%d, r2=%d, rd=%d, imm=%d, imm_binary=%b", rx_funct, rs1_val, rs2_val, rdd_val, imm_val, imm_val_ext_full);
            $display("instrucción=%d, rs1=%d, rs2=%d, rdd=%d, imm=%d", rx_funct, rs1_val, rs2_val, rdd_val, imm_val);
        end

    endfunction //decodify_instruction

  task automatic check (logic DBG_HIGH_VERBOSITY=1);
        forever begin
            @(posedge `CLK_PATH);
            IADDR = `IADDR_PATH;
            IDATA = `IDATA_PATH;
            if (IADDR!==IADDR_old)begin
                decodify_instruction(IADDR, IDATA, 0);
                this.sb.push_instruction(IADDR, rx_funct, imm_val, rs1_val, rs2_val, rdd_val);
                if (DBG_HIGH_VERBOSITY) begin //Only for debugging. This prints all the fields (some may not be correct due to instruction type, be aware)
                    $display("================================");
                    $display("Change on IADDR detected %h", IADDR);
                    $display("Current IADDR %h", IADDR);
                    $display("Previous IADDR %h", IADDR_old);
                    $display("================================");
                end
            end
            IADDR_old = IADDR;
        end
    endtask //automatic
    
endclass //className

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/
//About cases: https://fpgainsights.com/blog/case-statement-systemverilog-a-comprehensive-guide-to-using-case-statements-in-systemverilog/#:~:text=In%20SystemVerilog%2C%20the%20case%20statement,used%20to%20implement%20a%20multiplexer.
