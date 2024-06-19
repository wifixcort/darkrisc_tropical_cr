class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)
 
  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
  
  darksocv_env env;  
  gen_sequence seq;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
          
    env  = darksocv_env::type_id::create ("env", this);
    seq = gen_sequence::type_id::create("seq");

  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print();
    
  endfunction : end_of_elaboration_phase


  virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);

    ///// CONFIGURACION DE CONTROLABILIDAD  /////
    
    // // todo: programar on/off para los tipos de instrucciones que se generan

    seq.mem_generate();
    seq.loop_end_of_program(1);
    seq.opt_addr(1);
    seq.print_mem();

    $writememh("darksocv.mem", seq.MEM);
 
 	  env.uvc1_env.agent_active.drv.mem_load();

 	  env.uvc1_env.agent_active.drv.reset();

    // Tiempo de simulación
    //#10000    //10 us
    #50000 //50 us
    //#1000000; //1ms
 
    phase.drop_objection (this);
  endtask

endclass