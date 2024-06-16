class darksocv_agent_active extends uvm_agent;
  `uvm_component_utils(darksocv_agent_active)
  function new(string name="darksocv_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_soc intf;
  darksocv_driver drv;
  uvm_sequencer #(sequence_item_rv32i_instruction)	seqr;

  //fifo_monitor_wr fifo_mntr_wr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    drv = darksocv_driver::type_id::create ("drv", this); 
    
    seqr = uvm_sequencer#(sequence_item_rv32i_instruction)::type_id::create("seqr", this);
    
    //fifo_mntr_wr = fifo_monitor_wr::type_id::create ("fifo_mntr_wr", this);
    
    //uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.env.fifo_ag.drv", "VIRTUAL_INTERFACE", intf);    

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass



/*

class darksocv_agent_passive extends uvm_agent;
  `uvm_component_utils(darksocv_agent_passive)
  function new(string name="darksocv_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_soc intf;
  
  //fifo_monitor_rd fifo_mntr_rd;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    //fifo_mntr_rd = fifo_monitor_rd::type_id::create ("fifo_mntr_rd", this);

    //uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.env.fifo_ag.drv", "VIRTUAL_INTERFACE", intf);  


*/
