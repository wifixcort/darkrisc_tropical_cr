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

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sequence_item_rv32i_instruction item;
      //`uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(item);
      fork
        add_instruct_to_mem(item);
        //drive_fifo(item);
        //read_fifo(item);     //Con esta funcion se implementa la lectura de pines, el sequencer debe ser bidireccional para que esto pueda interactuar con el sequence
        //****
      join
      seq_item_port.item_done();
    end
endtask  

  //==============================================================
  //         Driver Functions
  //==============================================================
  
  logic [31:0]	  MEM [0:2**`MLEN/4-1];
  integer         i = 0;

  // For build .mem file instruction by instruction
  //*******************************************************
  function add_instruct_to_mem(sequence_item_rv32i_instruction item);
    MEM[i] = item.full_inst;
    i = i+1;
    // Si ya era la ultima instruccion
    if (i == 2**`MLEN/(4*2))
      write_mem_file();
  endfunction


  // Write .mem file
  //*******************************************************
  function write_mem_file (); 
    //Llenar memoria de datos con 0x00000000
    while (i <= 2**`MLEN/(4)) begin
      if (i < 2**`MLEN/(4))
        MEM[i] = 32'h00000000; //Llenar memoria de datos con 0s
      //si ya era el ultimo espacio de memoria
      else if (i == 2**`MLEN/(4)) //-1
        $writememh("darksocv.mem", MEM);
      i = i+1;
    end 
  endfunction
  

  // Load .mem in SoC MEM
  //*******************************************************
  function mem_load();                                        //No necesario porque ya lo hace el soc
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

  // Imprimir la memoria de instrucciones local (de esta clase, no del .mem, deberian ser iguales)
  //**********************************************************************************************
  function print_mem();
    $display("\nprint_mem():");
    for (int j=0;j!=2**`MLEN/(4);j=j+1) begin
        //`uvm_info( ), UVM_MEDIUM)
        $display("Instruction #%d:\t%h\topcode: %b ", j[15:0], MEM[j], MEM[j][6:0]);
    end
  endfunction
  
endclass

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/
// For reference while creating a driver, this is useful: https://www.chipverify.com/uvm/uvm-using-get-next-item