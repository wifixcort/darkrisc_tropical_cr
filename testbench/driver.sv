import instructions_data_struc::*;


// // sequence generator <- legacy class stimulus
// class gen_sequence extends uvm_sequence;

//   //==============================================================
//   //         Configuration and steps of UVM
//   //==============================================================
//   `uvm_object_utils(gen_sequence)
//   function new(string name="gen_sequence");
//     super.new(name);
//   endfunction

//   /*
//   // TODO: estas dos lineas pueden ser util para escribir ROM con una cantidad aleatoria de instrucciones
//   rand int num; 	// Config total number of items to be sent
//  constraint c1 { num inside {[2:5]}; }

  
//   virtual task body();
//     sequence_item_rv32i_instruction i_item = sequence_item_rv32i_instruction::type_id::create("i_item");
//     for (int i = 0; i < num; i ++) begin
//         start_item(i_item);
//     	i_item.randomize();
//     	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
//     	i_item.print();
//         finish_item(i_item);
//         //`uvm_do(i_item);
//     end
//     `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
//   endtask
// */

//   //==============================================================
//   //         Generate memory and instruction sequences 
//   //         (legacy class stimulus)        
//   //==============================================================
//   logic [31:0]	   MEM [0:2**`MLEN/4-1];
//   logic [4:0]	   reg_addr;
//   logic [31:0]	   effective_addr = 32'h00000000;
//   int			   min_data_addr = 2**`MLEN/(4*2);
//   int			   max_data_addr = 2**`MLEN/4-1;
   
//    // fulling the MEM array
//    //**********************************************************
//   function void mem_generate(logic DBG_HIGH_VERBOSITY=0);
//       //$display("INSIDE OF mem_generate");
//       sequence_item_rv32i_instruction inst_gen0; 
//       inst_gen0 = new; 
//       $display("\n********************************************************************************");
//       $display("Stimulus: Invoked mem_generate() -> proced to generate random instructions array");
//       $display("********************************************************************************");
//       // inicializate MEM to 0
//       for(int i=0;i!=2**`MLEN/4;i=i+1) begin
//          MEM[i] = 32'd0; //This is completely necessary, otherwise there are x's in the RAM 
//       end
//       // set instructions in MEM
//       for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
// 		 inst_gen0.randomize();
// 		 MEM[i] = inst_gen0.full_inst;
// 		 //Verbosity for each instruction
// 		 if (DBG_HIGH_VERBOSITY)
//            $display("Instruction generated #%d:\t%h\topcode: %b ", i[15:0], inst_gen0.full_inst, inst_gen0.opcode);
//       end
//    endfunction

//   function void print_mem(logic DBG_HIGH_VERBOSITY=0);  //el argumento no se usa en esta función, se pone para que todas las funciones lo tengan
//       $display("\n******************************************************************************************");
//       $display("Stimulus: Invoked print_mem() -> print the actual state of MEM");
//       $display("******************************************************************************************");
//       foreach (MEM[i]) begin
// 		 $display("Instruction #%d:\t%h\topcode: %b ", i[15:0], MEM[i], MEM[i][6:0] );
//       end   
//   endfunction
//    //referencia: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
//    // filminas 8 y 9

// endclass


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

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sequence_item_rv32i_instruction i_item;
      //`uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(i_item);
      //Drive tasks here  **************** Nunca ha sido necesario drivear nada directamente
      /*fork
        mem_load();
        reset();
      join*/
      seq_item_port.item_done();
    end
  endtask    

  //==============================================================
  //         Driver Functions
  //==============================================================
  gen_sequence seq;
  // Load values to .mem file
  //*******************************************************
  
  function mem_load();  
    seq = gen_sequence::type_id::create("seq");
    `uvm_info("Driver", $sformatf("Loading memory in SoC"), UVM_MEDIUM)
    seq.mem_generate();
    //seq.set_program_format();
    //seq.opt_addr();
    //seq.print_mem();
    $writememh("darksocv.mem", seq.MEM);
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  // Send reset and clear soc inputs
  //*******************************************************
  virtual task reset(); 
    `uvm_info("Driver", $sformatf("Sending RESET signal to SoC"), UVM_MEDIUM)
    intf.rst = 0;
    intf.uart_rx = 0;
    intf.uart_tx = 0;
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
