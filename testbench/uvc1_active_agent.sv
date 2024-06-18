class darksocv_agent_active extends uvm_agent;
  
  `uvm_component_utils(darksocv_agent_active)
  
  function new(string name="darksocv_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_soc intf;
  darksocv_driver drv;
  sequencer seqr;

  // TODO: AQUI VA INSTANCIA DE MONITOR 1

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    drv = darksocv_driver::type_id::create ("drv", this); 
    
    seqr = sequencer::type_id::create("seqr", this);
    
    //fifo_mntr_wr = fifo_monitor_wr::type_id::create ("fifo_mntr_wr", this);
    
    //uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.env.fifo_ag.drv", "VIRTUAL_INTERFACE", intf);    

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass