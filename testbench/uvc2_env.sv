class darksocv_uvc2_env extends uvm_env;

    `uvm_component_utils(darksocv_uvc2_env)
  
    function new (string name = "darksocv_uvc2_env", uvm_component parent = null);
      super.new (name, parent);
    endfunction
    
    darksocv_agent_passive agent_passive;
    
  
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      agent_passive = darksocv_agent_passive::type_id::create ("agent_passive", this); 

      uvm_config_db #(uvm_bitstream_t)::set(this, "agent_passive", "is_active", UVM_PASSIVE);
      
        
      uvm_report_info(get_full_name(),"End_of_build_phase UVC 2", UVM_LOW);
      print();
  
    endfunction
  
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    //   drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
  
  endclass
