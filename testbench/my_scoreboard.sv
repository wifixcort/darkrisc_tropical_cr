`uvm_analysis_imp_decl( _mon1 )
`uvm_analysis_imp_decl( _mon2 ) 
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)
    uvm_analysis_imp_mon1#(monitor_tr, my_scoreboard) txn_mon1;
    uvm_analysis_imp_mon2#(monitor_tr, my_scoreboard) txn_mon2;

    // Queue for STORING decoded instructions from Monitor
    logic [75:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1_val, rs2_val, rdd_val, imm_val
	
    // Analysis FIFO to store predictions from ref_model
    //uvm_analysis_fifo#(pred_t) ref_model_fifo;

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
      endfunction

    // virtual function void connect_phase(uvm_phase phase);
    //     super.connect_phase(phase);
    //   endfunction

    function void  write_mon2(monitor_tr tr);
        uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
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
  endclass