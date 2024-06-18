class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)
 
  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
  
  virtual intf_soc intf;
  virtual intf_mem_rd mem_rd_chan;
  darksocv_env env;  
  gen_sequence seq;
  
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end

    if(uvm_config_db #(virtual intf_mem_rd)::get(this, "", "VIRTUAL_INTERFACE_MEM_RD", mem_rd_chan) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the memory read channel")
    end
      
    env  = darksocv_env::type_id::create ("env", this);
    seq = gen_sequence::type_id::create("seq");
    uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
    uvm_config_db #(virtual intf_mem_rd)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE_MEM_RD", mem_rd_chan);
      
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
    //seq.set_program_format();
    //seq.opt_addr(1);
    seq.print_mem();

    $writememh("darksocv.mem", seq.MEM);
 
 	  env.uvc1_env.agent_active.drv.mem_load();

 	  env.uvc1_env.agent_active.drv.reset();

    //#10000    //10 us
    #50000 //50 us
    //#1000000; //1ms

    
    phase.drop_objection (this);
  endtask

endclass


//  LEGACY TESCASE
/*   
program testcase(intf_soc intf);
  environment env = new(intf);

  initial begin
    env.drvr.reset();
    env.drvr.mem_load();
    #10000000;  
  end
endprogram
*/
