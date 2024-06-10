class darksocv_agent_passive extends uvm_agent;
    `uvm_component_utils(darksocv_agent_passive)
    function new(string name="darksocv_agent_passive", uvm_component parent=null);
      super.new(name, parent);
    endfunction
    
    uvc2_mon monitor2;
  
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(get_is_active() == UVM_PASSIVE) begin
        monitor2 = uvc2_mon::type_id::create("monitor2", this);
        `uvm_info(get_full_name(), "This is Passive agent", UVM_LOW);
      end

    endfunction
  
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      $display("Passive agent connect phase");
    //   drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        $display("Passive agent run phase");
    endtask
  
  endclass
  