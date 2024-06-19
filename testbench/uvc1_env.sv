class darksocv_uvc1_env extends uvm_env;

    `uvm_component_utils(darksocv_uvc1_env)
  
    function new (string name = "darksocv_uvc1_env", uvm_component parent = null);
      super.new (name, parent);
    endfunction
    
    darksocv_agent_active agent_active;
     
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      agent_active = darksocv_agent_active::type_id::create ("agent_active", this); 
      uvm_config_db #(uvm_bitstream_t)::set(this, "agent_active", "is_active", UVM_ACTIVE);
      uvm_report_info(get_full_name(),"End_of_build_phase UVC 1", UVM_LOW);
      print();
  
    endfunction
  
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
  
  endclass