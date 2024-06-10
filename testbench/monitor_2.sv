class uvc2_mon extends uvm_monitor;

    `uvm_component_utils(uvc2_mon)
  
    function new (string name = "uvc2_mon", uvm_component parent = null);
      super.new (name, parent);
    endfunction
        
  
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

        
      uvm_report_info(get_full_name(),"End_of_build_phase Monitor 2", UVM_LOW);
      print();
  
    endfunction
  
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    //   drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        uvm_report_info(get_full_name(),"Monitor 2 running........", UVM_LOW);
    endtask
  
  endclass
