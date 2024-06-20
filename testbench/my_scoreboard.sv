class my_scoreboard extends uvm_scoreboard;
    // uvm_analysis_imp#(mon2_transaction, my_scoreboard) mon2_txn;
    // uvm_analysis_export#(mon2_transaction) mon2_txn;

    `uvm_component_utils(my_scoreboard)
  
    function new(string name, uvm_component parent);
      super.new(name, parent);
    //   mon2_txn = new("mon2_txn", this);
    endfunction

    uvm_analysis_imp  #(mon1_t, my_scoreboard) mon1_txn;
    uvm_analysis_imp#(mon2_transaction, my_scoreboard) mon2_txn;
    
    virtual function void build_phase(uvm_phase phase);
        mon2_txn = new("mon2_txn", this);
        mon1_txn = new("mon1_txn", this);
      endfunction

    // virtual function void connect_phase(uvm_phase phase);
    //     super.connect_phase(phase);
    //   endfunction

    function void  write(mon2_transaction tr);
        uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
        print();
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
    endfunction

    function void  write(mon1_t tr);
        //uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
        //print();
        display("hello mon1 working on SCB");
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
    endfunction
  endclass