class darksocv_agent_active extends uvm_agent;
  `uvm_component_utils(darksocv_agent_active)
  function new(string name="darksocv_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  darksocv_driver drv;
  sequencer #(sequence_item_rv32i_instruction)	seqr;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    drv = darksocv_driver::type_id::create ("drv", this); 
    seqr = uvm_sequencer#(sequence_item_rv32i_instruction)::type_id::create("seqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass