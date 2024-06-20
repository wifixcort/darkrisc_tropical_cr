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
     if(uvm_config_db #(virtual intf_soc)::get(this, "*", "VIRTUAL_INTERFACE", intf) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  //==============================================================
  //         Driver Functions
  //==============================================================
  
  // Load values to .mem file
  //*******************************************************
  
  // Load .mem in SoC MEM
  //*******************************************************
  function mem_load();  
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  // Send reset and clear soc inputs
  //*******************************************************
  virtual task reset();  
    $display("driver: Invoked reset()     -> send RESET signal to SoC");
    intf.rst = 0;
    intf.uart_rx = 0;
    intf.uart_tx = 0;
    intf.rst = 1;
    @ (negedge intf.clk);
      intf.rst = 0;
  endtask   
  
endclass

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/