`uvm_analysis_imp_decl( _mon1 )
`uvm_analysis_imp_decl( _mon2 ) 
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)
    uvm_analysis_imp_mon1#(monitor_tr, my_scoreboard) txn_mon1;
    uvm_analysis_imp_mon2#(monitor_tr, my_scoreboard) txn_mon2;

    // Queue for STORING decoded instructions from Monitor
    logic [75:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1_val, rs2_val, rdd_val, imm_val
	
    // Handle of Reference Model
    riscv_ref_model ref_model;

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

    logic [31:0] rs1_val_final;
    logic [31:0] rs2_val_final;
    logic [31:0] rdd_val_final;
    
    logic [31:0] rs1_val_init;
    logic [31:0] rs2_val_init;
    logic [31:0] rdd_val_init;

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
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      txn_mon1 = new("txn_mon1", this);
      txn_mon2 = new("txn_mon2", this);
      ref_model = riscv_ref_model::type_id::create("ref_model", this);
      endfunction

    function void  write_mon2(monitor_tr tr);
        uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
        // Process instruction that is inside queue
        process_inst();
        //
        // print();
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
    endfunction

    function void  write_mon1(monitor_tr tr);
        uvm_report_info(get_full_name(), $sformatf("\n Received transaction mon1: %h, %h, %h", tr.pc_val_mon1, tr.rx_funct_mon1, tr.imm_val_mon1), UVM_LOW);
        print();
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
        push_instruction(tr.pc_val_mon1, tr.rx_funct_mon1, tr.imm_val_mon1, tr.rs1_val_mon1, tr.rs2_val_mon1, tr.rdd_val_mon1);
    endfunction

     // Function to push instruction to the queue
    function push_instruction(logic [31:0] pc_val_in, logic [7:0] rx_funct_in, logic signed [20:0] imm_val_in, logic [4:0] rs1_val_in, logic [4:0] rs2_val_in, logic [4:0] rdd_val_in);
        decoded_inst_q.push_back({pc_val_in, rx_funct_in, imm_val_in, rs1_val_in, rs2_val_in, rdd_val_in});
    endfunction

        // Function to get values from the queue and procces instruction in our model
    function process_inst();
        if (decoded_inst_q.size()!=0) begin
            // Send transaction to Reference Model
            decoded_inst_x = decoded_inst_q.pop_front();

            pc_val = decoded_inst_x[75:44];
            rx_funct = decoded_inst_x[43:36];
            imm_val  = decoded_inst_x[35:15];
            rs1_val  = decoded_inst_x[14:10];
            rs2_val  = decoded_inst_x[9:5];
            rdd_val  = decoded_inst_x[4:0];

            // Predict function 
            ref_model.predict(pc_val,rx_funct,imm_val,rs1_val,rs2_val,rdd_val);

            imm_val_sign_ext = ref_model.imm_val_sign_ext;
            rs1_val = ref_model.rs1_val_upd;
            rs2_val = ref_model.rs2_val_upd;
            rdd_val = ref_model.rdd_val_upd;

            rs1_val_init = ref_model.rs1_val_init;
            rs2_val_init = ref_model.rs2_val_init;
            rdd_val_init = ref_model.rdd_val_init;

            rs1_val_final = ref_model.rs1_val_final;
            rs2_val_final = ref_model.rs2_val_final;
            rdd_val_final = ref_model.rdd_val_final;

            DATAI = ref_model.DATAI;
            DATAO = ref_model.DATAO;
            DADDR = ref_model.DADDR;
            pc_val = ref_model.pc_val_upd;
            //rx_funct

        end else begin
        // Queue is empty, handle the case 
        // $display("Queue is empty!");
        end
    endfunction
  endclass