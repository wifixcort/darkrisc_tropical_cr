import instructions_data_struc::*;

class darksocv_driver extends uvm_driver #(sequence_item_rv32i_instruction);

  //==============================================================
  //       UVM  Configuration and steps 
  //==============================================================

  `uvm_component_utils (darksocv_driver)
   function new (string name = "darksocv_driver", uvm_component parent = null);
     super.new (name, parent);
   endfunction

   virtual intf_soc intf;

   virtual function void build_phase (uvm_phase phase);
     super.build_phase (phase);
     if(uvm_config_db #(virtual intf_soc)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction


  // virtual task run_phase(uvm_phase phase);
  //   super.run_phase(phase);
  //   forever begin
  //     sequence_item_rv32i_instruction i_item;
  //     `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
  //     seq_item_port.get_next_item(i_item);
  //     //Drive tasks here  **************** Nunca ha sido necesario drivear nada directamente
  //     /*fork
  //       mem_load();
  //       reset();
  //     join*/
  //     seq_item_port.item_done();
  //   end
  // endtask    

  //==============================================================
  //         Driver Functions
  //==============================================================
  gen_sequence seq;
  // Load values to .mem file
  //*******************************************************
  
  function mem_load();  
    seq = gen_sequence::type_id::create("seq");
    $display("driver: Invoked mem_load()  -> load MEM to SoC");
    seq.mem_generate();
    seq.set_program_format();
    seq.opt_addr(1);
    seq.print_mem();
    $writememh("darksocv.mem", seq.MEM);
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  // Send reset and clear soc inputs
  //*******************************************************
  virtual task reset();  
    $display("driver: Invoked reset()     -> send RESET signal to SoC");
    intf.rst = 0;
    intf.uart_rx = 0;
    //intf.uart_tx = 0;
    intf.rst = 1;
    @ (negedge intf.clk);
    intf.rst = 0;
  endtask   
  
endclass







// LEGACY DRIVER

/*
class driver;
  stimulus sti;
  virtual intf_soc intf;
  
  function new(virtual intf_soc in_intf, stimulus in_sti);
        this.sti  = in_sti;
        this.intf = in_intf;
  endfunction
  
  //====================================================================
  //========================= Methods ==================================
  //====================================================================

  // Load values from .mem file
  function mem_load();
    $display("\n******************************************************************************************");
    $display("driver: Invoked mem_loadt() -> load MEM to SoC");
    $display("******************************************************************************************");
    sti.mem_generate();
    sti.set_program_format();
    sti.opt_addr();
    //sti.print_mem();
    $writememh("darksocv.mem", sti.MEM);
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  task reset(); 
    $display("\n******************************************************************************************");
    $display("driver: Invoked reset() -> send RESET signal to SoC");
    $display("******************************************************************************************");
    //$display("Executing Reset\n");
    intf.rst = 0;
    intf.uart_rx = 0;
    intf.uart_tx = 0;
    intf.rst = 1;
    @ (negedge intf.clk);
    intf.rst = 0;
  endtask
  
endclass 

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/

*/
