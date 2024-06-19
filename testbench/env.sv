class darksocv_env extends uvm_env;
  my_scoreboard scoreboard;
  `uvm_component_utils(darksocv_env)

  function new (string name = "darksocv_env", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  darksocv_uvc1_env uvc1_env;
  darksocv_uvc2_env uvc2_env;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    uvc1_env  = darksocv_uvc1_env::type_id::create ("uvc1_env", this);
    uvc2_env  = darksocv_uvc2_env::type_id::create ("uvc2_env", this);
  
    scoreboard = my_scoreboard::type_id::create("scoreboard", this);

    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uvc2_env.agent_passive.monitor2.mon2_txn.connect(scoreboard.mon2_txn);
  endfunction

endclass