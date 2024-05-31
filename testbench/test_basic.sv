`include "uvm_macros.svh"
import uvm_pkg::*;

class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)
 
  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
  
  virtual intf_soc intf;
  darksocv_env env;  
  
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
      
    env  = darksocv_env::type_id::create ("env", this);

    uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
      
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print();
    
  endfunction : end_of_elaboration_phase

  gen_sequenc seq;

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);

    seq = gen_sequenc::type_id::create("seq");
    
    // TODO: hacer mejor
    seq.drvr.reset();
    seq.drvr.mem_load();
    
    phase.drop_objection (this);
  endtask

endclass

/*    /// TEST Delivery01 ///
program testcase(intf_soc intf);
  environment env = new(intf);

  initial begin
    env.drvr.reset();
    env.drvr.mem_load();
    #10000000;  
  end
endprogram
*/