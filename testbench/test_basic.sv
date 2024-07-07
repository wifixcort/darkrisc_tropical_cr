class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)
 
  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
  
  darksocv_env env;  
  
  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
        
    env  = darksocv_env::type_id::create ("env", this);

  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

  
  gen_sequence   seq;
  virtual task run_phase(uvm_phase phase);
    
    phase.raise_objection (this);
    
    seq = gen_sequence::type_id::create("seq");
    seq.start(env.uvc1_env.agent_active.seqr);

    // Tiempo de simulación
    #21000 //50 us

    //env.uvc1_env.agent_active.drv.reset();    // se llama desde el driver para que se ejecute despues de escribir el .mem
    //env.uvc1_env.agent_active.drv.mem_load(); // ya lo hace el SoC

    phase.drop_objection (this);
  endtask

endclass