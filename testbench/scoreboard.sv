/*
Ports declarations?
`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon )
*/

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard);

    // Analysis ports 
    uvm_analysis_imp  #(mon1_t, scoreboard) ap_mon1;
    uvm_analysis_port #(mon2_t, scoreboard) ap_mon2;

    // Queue for STORING decoded instructions from Monitor
    logic [75:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1_val, rs2_val, rdd_val, imm_val
	
    // Internal Signals for decoded_inst proccessing
    logic [75:0] decoded_inst_x;
    logic [7:0] rx_funct;
    logic signed [20:0]  imm_val;
    logic signed [31:0]  imm_val_sign_ext;
    logic [4:0] rs1_val;
    logic [4:0] rs2_val;
    logic [4:0] rdd_val;
    logic [31:0] DATAI;
    logic [31:0] DATAO;
    logic [31:0] DADDR;
    logic [31:0] pc_val;
  
    // Reference Model Instance
    riscv_ref_model ref_model;

    // Scoreboard Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        rx_funct = '0;
        imm_val = '0;
        rs1_val = '0;
        rs2_val = '0;
        rdd_val = '0;
        DATAI = '0;
        DATAO = '0;
        DADDR = '0;
        pc_val = '0;
        ref_model = new();
    endfunction

    // Build Phase 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Instance of the analysis ports
        ap_mon1 = new("ap_mon1", this);
        ap_mon2 = new("ap_mon2", this);

        // Should I create the mon1 and mon2 because there is no environment?? (only for scoreboard_test_env)
    endfunction

    // Connect Phase (only for scoreboard_test_env)
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Handles of monitors
        my_monitor mon1;
        my_monitor mon2;

        // Connect the analysis ports of the monitors to the scoreboard's analysis imp ports
        mon1.ap_mon1.connect(ap_mon1);
        mon2.ap_mon2.connect(ap_mon2);
    endfunction

    // Method to handle received transactions from mon_1 (Store in Queue)
    function void write(mon1_t t);
        // Push extracted fields into the queue
        push_instruction(t.pc_val_in, t.rx_funct_in, t.imm_val_in, t.rs1_val_in, t.rs2_val_in, t.rdd_val_in);
    endfunction

    // Function to push instruction to the queue
    function push_instruction(logic [31:0] pc_val_in, logic [7:0] rx_funct_in, logic signed [20:0] imm_val_in, logic [4:0] rs1_val_in, logic [4:0] rs2_val_in, logic [4:0] rdd_val_in);
        decoded_inst_q.push_back({pc_val_in, rx_funct_in, imm_val_in, rs1_val_in, rs2_val_in, rdd_val_in});
    endfunction
  
    // Function to get values from the queue and procces instruction in our model
    function process_inst();
        if (decoded_inst_q.size()!=0) begin
            // Assign values to internal signals
            decoded_inst_x = decoded_inst_q.pop_front();   
            pc_val   = decoded_inst_x[75:44];
            rx_funct = decoded_inst_x[43:36];
            imm_val  = decoded_inst_x[35:15];
            rs1_val  = decoded_inst_x[14:10];
            rs2_val  = decoded_inst_x[9:5];
            rdd_val  = decoded_inst_x[4:0];
      
            // Predict with Reference Model
            ref_model.predict(pc_val,rx_funct, imm_val, rs1_val, rs2_val, rdd_val);
            imm_val_sign_ext = ref_model.imm_val_sign_ext;
            rs1_val = ref_model.rs1_val_upd;
            rs2_val = ref_model.rs2_val_upd;
            rdd_val = ref_model.rdd_val_upd;
            DATAI = ref_model.DATAI;
            DATAO = ref_model.DATAO;
            DADDR = ref_model.DADDR;
            pc_val = ref_model.pc_val_upd;
            //rx_funct

            // Write to ap_mon2
            my_transaction_mon2 transaction = new();
            transaction.imm_val_sign_ext = ref_model.imm_val_sign_ext;
            transaction.rs1_val = ref_model.rs1_val_upd;
            transaction.rs2_val = ref_model.rs2_val_upd;
            transaction.rdd_val = ref_model.rdd_val_upd;
            transaction.DATAI = ref_model.DATAI;
            transaction.DATAO = ref_model.DATAO;
            transaction.DADDR = ref_model.DADDR;
            transaction.pc_val = ref_model.pc_val_upd;
            // Write to the analysis port
            analysis_port.write(transaction);

            /*
            // Dump Model Registers
            top.scbdreg_dmpd0 = ref_model.REGS[0];
            top.scbdreg_dmpd1 = ref_model.REGS[1];
            top.scbdreg_dmpd2 = ref_model.REGS[2];
            top.scbdreg_dmpd3 = ref_model.REGS[3];
            top.scbdreg_dmpd4 = ref_model.REGS[4];
            top.scbdreg_dmpd5 = ref_model.REGS[5];
            top.scbdreg_dmpd6 = ref_model.REGS[6];
            top.scbdreg_dmpd7 = ref_model.REGS[7];
            top.scbdreg_dmpd8 = ref_model.REGS[8];
            top.scbdreg_dmpd9 = ref_model.REGS[9];
            top.scbdreg_dmpd10 = ref_model.REGS[10];
            top.scbdreg_dmpd11 = ref_model.REGS[11];
            top.scbdreg_dmpd12 = ref_model.REGS[12];
            top.scbdreg_dmpd13 = ref_model.REGS[13];
            top.scbdreg_dmpd14 = ref_model.REGS[14];
            top.scbdreg_dmpd15 = ref_model.REGS[15];
            top.scbdreg_dmpd16 = ref_model.REGS[16];
            top.scbdreg_dmpd17 = ref_model.REGS[17];
            top.scbdreg_dmpd18 = ref_model.REGS[18];
            top.scbdreg_dmpd19 = ref_model.REGS[19];
            top.scbdreg_dmpd20 = ref_model.REGS[20];
            top.scbdreg_dmpd21 = ref_model.REGS[21];
            top.scbdreg_dmpd22 = ref_model.REGS[22];
            top.scbdreg_dmpd23 = ref_model.REGS[23];
            top.scbdreg_dmpd24 = ref_model.REGS[24];
            top.scbdreg_dmpd25 = ref_model.REGS[25];
            top.scbdreg_dmpd26 = ref_model.REGS[26];
            top.scbdreg_dmpd27 = ref_model.REGS[27];
            top.scbdreg_dmpd28 = ref_model.REGS[28];
            top.scbdreg_dmpd29 = ref_model.REGS[29];
            top.scbdreg_dmpd30 = ref_model.REGS[30];
            top.scbdreg_dmpd31 = ref_model.REGS[31]; 
            */
        end else begin
        // Queue is empty, handle the case 
        // $display("Queue is empty!");
        end
    endfunction
endclass