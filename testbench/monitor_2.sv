class uvc2_mon extends uvm_monitor;

    `uvm_component_utils(uvc2_mon)
  
    function new (string name = "uvc2_mon", uvm_component parent = null);
      super.new (name, parent);
    endfunction
    
    // virtual intf_soc intf2;
    // darksocv_agent_passive agent_passive;
    // darksocv_driver drv;
    // uvm_sequencer #(rv32i_instruction)	seqr;
    
  
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
    //   if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf2) == 0) begin
    //     `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    //   end
    
      
    //   seqr = uvm_sequencer#(rv32i_instruction)::type_id::create("seqr", this);
      
      // legacy del ejemplo del arbitro
      //uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.darksocv_env.*", "VIRTUAL_INTERFACE", intf);    
        
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
