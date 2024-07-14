//**************************************************************************
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
    #16000
    //#21000 //50 us

    phase.drop_objection (this);
  endtask

endclass



//**************************************************************************
class test_R extends test_basic;

  `uvm_component_utils(test_R)
 
  function new (string name="test_R", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();    
    super.build_phase(phase);
        
    factory.set_type_override_by_name("gen_sequence", "gen_sequence_R");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase
endclass



//**************************************************************************
class test_LOAD extends test_basic;

  `uvm_component_utils(test_LOAD)
 
  function new (string name="test_LOAD", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get(); 
    
    super.build_phase(phase);
        
    factory.set_type_override_by_name("gen_sequence", "gen_sequence_LOAD");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

endclass



//**************************************************************************
class test_STORE extends test_basic;

  `uvm_component_utils(test_STORE)
 
  function new (string name="test_STORE", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get(); 
    
    super.build_phase(phase);
        
    factory.set_type_override_by_name("gen_sequence", "gen_sequence_STORE");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

endclass



//**************************************************************************
class test_LUI_AUIPC extends test_basic;

  `uvm_component_utils(test_LUI_AUIPC)
 
  function new (string name="test_LUI_AUIPC", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get(); 
    
    super.build_phase(phase);
        
    factory.set_type_override_by_name("gen_sequence", "gen_sequence_LUI_AUIPC");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

endclass


//**************************************************************************
class test_I extends test_basic;

  `uvm_component_utils(test_I)
 
  function new (string name="test_I", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get(); 
    
    super.build_phase(phase);
        
    factory.set_type_override_by_name("gen_sequence", "gen_sequence_I");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

endclass



// No se hace factory override porque se necesita aumentar el tiempo de simulacion en este test
//*********************************************************************************************
class test_BRANCH extends test_basic;

  `uvm_component_utils(test_BRANCH)
 
  function new (string name="test_BRANCH", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get(); 
    
    super.build_phase(phase);
        
    //factory.set_type_override_by_name("gen_sequence", "gen_sequence_BRANCH");

    // Print factory configuration
    factory.print();
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase

  gen_sequence_BRANCH   seq;
  virtual task run_phase(uvm_phase phase);   
    phase.raise_objection (this);  

    seq = gen_sequence_BRANCH::type_id::create("seq");
    seq.start(env.uvc1_env.agent_active.seqr);

    // Tiempo de simulación
    #45000

    phase.drop_objection (this);
  endtask

endclass