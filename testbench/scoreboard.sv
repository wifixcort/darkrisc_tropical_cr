class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard);

    // Analysis ports 
    uvm_analysis_imp  #(mon1_t, scoreboard) ap_mon1;
    uvm_analysis_imp  #(mon2_t, scoreboard) ap_mon2;
    //uvm_analysis_imp  #(ref_model_t, scoreboard) ap_ref_model;

    // Handle of Reference Model
    riscv_ref_model ref_model;

    // Queue for STORING decoded instructions from Monitor
    logic [75:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1_val, rs2_val, rdd_val, imm_val
	
    // Analysis FIFO to store predictions from ref_model
    uvm_analysis_fifo#(pred_t) ref_model_fifo;

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
  
    // Scoreboard Constructor
    function new(string name = sb, uvm_component parent = environment);
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
    endfunction

    // Build Phase 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Instance of the analysis ports
        ap_mon1 = new("ap_mon1", this);
        ap_mon2 = new("ap_mon2", this);
        ref_model = riscv_ref_model::type_id::create("ref_model", this);
        //ap_ref_model = new("ap_ref_model", this);
        ref_model_fifo = new("ref_model_fifo", this);
    endfunction 

    // Connect Phase 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect the analysis ports
        //ref_model.ap_ref_model.connect(ap_ref_model);
        ref_model.ap_ref_model_pred.connect(ref_model_fifo.analysis_export);
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
  
    // Method to handle received transactions from mon_2 
    function void write(mon2_t t);
        // Process instruction that is inside queue
        process_inst();
        // Compare values from mon_2 and ref_model    
        pred_t ref_transaction;
        if (ref_model_fifo.try_get(ref_transaction)) begin
            // Compare ref_model_t fields with mon2_t fields
            //ref_transaction.pc_val == t.pc_val (example)
        end else begin
            `uvm_error("SCOREBOARD", "No prediction available from ref_model");
        end
    endfunction

    // Function to get values from the queue and procces instruction in our model
    function process_inst();
        if (decoded_inst_q.size()!=0) begin
            // Send transaction to Reference Model
            ref_model_t transaction = new();
            decoded_inst_x = decoded_inst_q.pop_front();
            transaction.pc_val = decoded_inst_x[75:44];
            transaction.rx_funct = decoded_inst_x[43:36];
            transaction.imm_val  = decoded_inst_x[35:15];
            transaction.rs1_val  = decoded_inst_x[14:10];
            transaction.rs2_val  = decoded_inst_x[9:5];
            transaction.rdd_val  = decoded_inst_x[4:0];

            // Predict function 
            ref_model.predict(transaction);

        end else begin
        // Queue is empty, handle the case 
        // $display("Queue is empty!");
        end
    endfunction
endclass