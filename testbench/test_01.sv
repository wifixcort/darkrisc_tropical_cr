class test_01 extends uvm_test;

  `uvm_component_utils(test_01)
 
  function new (string name="test_01", uvm_component parent=null);
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

  gen_sequence seq;

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);

    ///// CONFIGURACION DE CONTROLABILIDAD  /////
    //seq.gen_instructs_R_I();                     // Generar instrucciones tipo R, I, L y S
    //seq.set_regs();             
    //seq.gen_instructs_R_I_L_S();                 // Generar instrucciones tipo R, I, L y S
    //seq.loop_end_of_program(1);                  // Forzar instrucciones al final del programa para dejarlo loopeado
    //seq.opt_addr(1);                             // Forzar direcciones validas para las instrucciones Load y Store
    //seq.print_mem();                             // Imprimir el resultado de la memoria de instrucciones
    //seq.write_mem();                             // Escribir archivo .mem
    
    seq = gen_sequence::type_id::create("seq");
    seq.start(env.uvc1_env.agent_active.seqr);

 	  //env.uvc1_env.agent_active.drv.mem_load();
 	  env.uvc1_env.agent_active.drv.reset();

    // Tiempo de simulación
    //#50000 //50 us
    #7860
    //env.uvc1_env.agent_active.drv.reset();
 
    phase.drop_objection (this);
  endtask

endclass