class darksocv_env extends uvm_env;

  `uvm_component_utils(darksocv_env)

  function new (string name = "darksocv_env", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual intf_soc intf;
  darksocv_driver drv;
  uvm_sequencer #(sequence_item_rv32i_instruction)	seqr;
  

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    drv = darksocv_driver::type_id::create ("drv", this); 
    
    seqr = uvm_sequencer#(sequence_item_rv32i_instruction)::type_id::create("seqr", this);
    
    // legacy del ejemplo del arbitro
    //uvm_config_db #(virtual intf_soc)::set (null, "uvm_test_top.darksocv_env.*", "VIRTUAL_INTERFACE", intf);    
      
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass





	//	LEGACY ENV
/* 
class darksocv_environment;
   driver drvr;
   stimulus sti;
   virtual intf_soc intf;
   scoreboard sb;
   monitor2 mntr2;
   instr_monitor mntr1;
   function new(virtual intf_soc in_intf);
      $display("Creating darksocv_environment");
      intf = in_intf;
      sti  = new();
      drvr = new(intf, sti);
      sb = new();
      mntr2 = new(sb);
      mntr1 = new(sb);
      fork
		 mntr2.check();
		 mntr1.check(0); //Debug-ability : No=0, Yes=1
      join_none
   endfunction
   
endclass

*/
