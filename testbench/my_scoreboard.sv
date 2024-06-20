`uvm_analysis_imp_decl( _mon1 )
`uvm_analysis_imp_decl( _mon2 ) 
class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)
    uvm_analysis_imp_mon1#(monitor_tr, my_scoreboard) txn_mon1;
    uvm_analysis_imp_mon2#(monitor_tr, my_scoreboard) txn_mon2;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      txn_mon1 = new("txn_mon1", this);
      txn_mon2 = new("txn_mon2", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);

      endfunction

    // virtual function void connect_phase(uvm_phase phase);
    //     super.connect_phase(phase);
    //   endfunction

    function void  write_mon1(monitor_tr tr);
        uvm_report_info(get_full_name(), $sformatf("\n Received transaction mon1: %h, %h, %h", tr.pc_val_mon1, tr.rx_funct_mon1 , tr.rs1_val_mon1), UVM_LOW);
        print();
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
    endfunction

    function void  write_mon2(monitor_tr tr);
        //uvm_report_info(get_full_name(), $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_LOW);
        //print();
        //$display("hello mon1 working on SCB");
    //   `uvm_info("MY_SCOREBOARD", $sformatf("\n Received transaction: %s, %h, %h", tr.inst, tr.instruction, tr.risc_rd_p), UVM_MEDIUM)
      // Procesar la transacción recibida
    endfunction
  endclass