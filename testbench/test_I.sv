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