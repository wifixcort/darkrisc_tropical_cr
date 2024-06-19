import instructions_data_struc::*;

class monitor_1 extends uvm_monitor;

    `uvm_component_utils(monitor_1)

    logic [7:0]             rx_funct;
    logic [7:0]             pc_val;
    logic signed [20:0]     imm_val;
    logic signed [31:0]     imm_val_ext_full;
    logic [4:0]             rs1_val;
    logic [4:0]             rs2_val;
    logic [4:0]             rdd_val;
    logic [6:0]             opcode;

    logic [2:0]             fct3;
    logic [6:0]             fct7;
  
    logic [31:0]            IADDR, IADDR_old;
    logic [31:0]            IDATA;
    logic [31:0]            counter_inst = 0;

    virtual intf_mem_rd     mem_rd_chan;
    uvm_analysis_port #(mon1_t) mon1_analysis_port;

    // ================= Methodos =================

    function new (string name = "monitor_1", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(uvm_config_db #(virtual intf_mem_rd)::get(this, "*", "VIRTUAL_INTERFACE_MEM_RD", mem_rd_chan) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the memory read channel")
        end

        mon1_analysis_port = new("monitor_1_analysis_port", this);

    endfunction

//=================================================
//          Monitor "monitoring" action
//=================================================
    virtual task run_phase (uvm_phase phase);
        `uvm_info("Monitor 1", "Run Phase initialized", UVM_LOW)
        forever begin
            @(posedge mem_rd_chan.clk);
            IADDR = mem_rd_chan.IADDR;
            IDATA = mem_rd_chan.IDATA;
            if (IADDR!==IADDR_old)begin
                mon1_t tx_instr = mon1_t::type_id::create("tx_instr");                
                decodify_instruction(IADDR, IDATA, 0);
                counter_inst = counter_inst+1;
                
                tx_instr.pc_val   = pc_val;
                tx_instr.rx_funct = rx_funct;
                tx_instr.imm_val  = imm_val;
                tx_instr.rs1_val  = rs1_val;
                tx_instr.rs2_val  = rs2_val;
                tx_instr.rdd_val  = rdd_val;
                mon1_analysis_port.write(tx_instr);
            end
            IADDR_old = IADDR;
        end
    endtask

//=================================================
//           Monitor method to decodify
//=================================================

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
                // SRLI_FC         : rx_funct = (imm_val[6:0]=='h00)? SRLI : SRAI;
                SRLI_FC         : rx_funct = (imm_val[11:5]=='0)? SRLI : SRAI;
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
        
        if (counter_inst < 150) begin //Only for debugging. This prints all the fields (some may not be correct due to instruction type, be aware)    
            $display("Function: %d, r1=%d, r2=%d, rd=%d, imm=%d, imm_binary=%b", rx_funct, rs1_val, rs2_val, rdd_val, imm_val, imm_val_ext_full);
            // $display("instrucción=%d, rs1=%d, rs2=%d, rdd=%d, imm=%d", rx_funct, rs1_val, rs2_val, rdd_val, imm_val);
            //$display("instrucción=%d, rs1=%d, rs2=%d, rdd=%d, imm=%d, testing_imm[11:5]=%h", rx_funct, rs1_val, rs2_val, rdd_val, imm_val, imm_val[11:5]);
        end

    endfunction //decodify_instruction    



endclass //className