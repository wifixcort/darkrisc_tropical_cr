`include "../rtl/config.vh"
`include "uvm_macros.svh"
import uvm_pkg::*;


// sequence item  <- legacy class rv32i_instruction
class rv32i_instruction extends uvm_sequence_item;

  // random variables 
  rand bit [31:0] full_inst;
  rand bit [6:0]  opcode;
  rand bit [4:0]  rs1;
  rand bit [4:0]  rs2;
  rand bit [4:0]  rd;
  rand bit [6:0]  funct7;
  rand bit [2:0]  funct3;
  rand bit [11:0] imm;

  // operation variables
  logic opt_addr_select = 1'b0; //optimize for generate address

  //==============================================================
  //         Constraints for instruction generator
  //==============================================================
   
  // Generate the full instruction in last contraint solver
  //**************************************************************
  constraint construct_full_inst{
    solve opcode,rd,rs1,rs2,funct7,funct3,imm before full_inst;
    (opcode == R_TYPE)   -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
    (opcode == I_TYPE)   -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == I_L_TYPE) -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == S_TYPE)   -> full_inst == {imm[11:5],rs2, rs1,funct3,imm[4:0],opcode};   
   }
   
   //********************************************************
  constraint opcode_cases{
    opcode dist {R_TYPE :/ 44,
                I_TYPE  :/ 44
                //I_L_TYPE,
                //S_TYPE  :/ 12
                /*S_B_TYPE,
                J_TYPE,
                I_JALR_TYPE,
                LUI_TYPE,
                AUIPC_TYPE */
                };
  }
   
  // funct3
  //********************************************************
  constraint funct3_cases{
    solve opcode before funct3;
    (opcode == R_TYPE) -> funct3 inside {ADD_o_SUB_FC,
                                        XOR_FC,
                                        OR_FC,
                                        AND_FC,
                                        SLL_FC,
                                        SRL_o_SRA_FC,
                                        SLT_FC,
                                        SLTU_FC};

    (opcode == I_TYPE) -> funct3 inside {ADDI_FC,
                                        XORI_FC,
                                        ORI_FC,
                                        ANDI_FC,
                                        SLLI_FC,
                                        SRLI_FC,
                                        SRAI_FC,
                                        SLTI_FC,
                                        SLTIU_FC};

    (opcode == I_L_TYPE) -> funct3 inside {LB_FC,
                                          LH_FC, 
                                          LW_FC,
                                          LBU_FC,     
                                          LHU_FC};

    (opcode == S_TYPE) -> funct3 inside   {SB_FC,
                                          SH_FC,
                                          SW_FC};
  }

  // for R_TYPE and some I_TYPE instructions
  //********************************************************
  constraint func7_cases{
    solve funct3 before funct7;
    if (opcode == R_TYPE) {
    //fix ||
      (funct3 == ADD_o_SUB_FC) -> funct7 inside {h00_FC7,
                                                    h20_FC7};
      (funct3 == SRL_o_SRA_FC ) -> funct7 inside {h00_FC7,
                                                     h20_FC7};
      (funct3 != ADD_o_SUB_FC ) -> funct7 ==      h00_FC7; 
      (funct3 != SRL_o_SRA_FC ) -> funct7 ==      h00_FC7; 
    } 
    //special cases of I_TYPE instructions
    if (opcode == I_TYPE) { 
      (funct3 == SRLI_FC)  -> imm[11:5] inside {h20_FC7,
                                                   h00_FC7};
      (funct3 == SLLI_FC)  -> imm[11:5]      == h00_FC7;
    }
  }
   
  // special cases for regs
  //************************
  constraint regs {
    (opcode == S_TYPE) -> rs1 !=0;  
   }
   
  // Offseft for calc effective direction should be aligned
  //*******************************************************
  constraint offset_load_store {
    solve funct3 before imm;
    if (!opt_addr_select) {     
      if (opcode == I_L_TYPE){
        (funct3 == LH_FC) 	->	imm[0]   == 1'b0;
        (funct3 == LHU_FC) 	->	imm[0]   == 1'b0;
        (funct3 == LW_FC) 	->	imm[1:0] == 2'b00;
      } else if (opcode == S_TYPE){
        (funct3 == SH_FC) 	->	imm[0]   == 1'b0;
        (funct3 == SW_FC) 	->	imm[1:0] == 2'b00;
      }
      //ACOTADORES de offset a +127 -127
      if(imm[11] == 0){
        //pos sign extend
        imm[10:8] == 3'b000;
      } else if (imm[11] == 1){
        //neg sign extend
        imm[10:8] == 3'b111;
      }
    }
   } 
   
  // UVM requirements
  //*******************************************************
  `uvm_object_utils_begin(rv32i_instruction)
  `uvm_object_utils_end
  function new(string name = "rv32i_instruction");
    super.new(name);
  endfunction
endclass



// sequence generator <- legacy class stimulus
class gen_sequence extends uvm_sequence;

  //==============================================================
  //         Configuration and steps of UVM
  //==============================================================
  `uvm_object_utils(gen_sequence)
  function new(string name="gen_sequence");
    super.new(name);
  endfunction

  // TODO: estas dos lineas pueden ser util para escribir ROM con una cantidad aleatoria de instrucciones
  //rand int num; 	// Config total number of items to be sent
  //constraint c1 { num inside {[2:5]}; }

  /*
  virtual task body();
    rv32i_instruction i_item = rv32i_instruction::type_id::create("i_item");
    for (int i = 0; i < num; i ++) begin
        start_item(i_item);
    	i_item.randomize();
    	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
    	i_item.print();
        finish_item(i_item);
        //`uvm_do(i_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
  */

  //==============================================================
  //         Generate memory and instruction sequences 
  //         (legacy class stimulus)        
  //==============================================================
  logic [31:0]	   MEM [0:2**`MLEN/4-1];
  logic [4:0]	   reg_addr;
  logic [31:0]	   effective_addr = 32'h00000000;
  int			   min_data_addr = 2**`MLEN/(4*2);
  int			   max_data_addr = 2**`MLEN/4-1;
   
   // fulling the MEM array
   //**********************************************************
   function  mem_generate(logic DBG_HIGH_VERBOSITY=0);
      rv32i_instruction inst_gen0; 
      inst_gen0 = new; 
      $display("\n********************************************************************************");
      $display("Stimulus: Invoked mem_generate() -> proced to generate random instructions array");
      $display("********************************************************************************");
      // inicializate MEM to 0
      for(int i=0;i!=2**`MLEN/4;i=i+1) begin
         MEM[i] = 32'd0; //This is completely necessary, otherwise there are x's in the RAM 
      end
      // set instructions in MEM
      for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
		 inst_gen0.randomize();
		 MEM[i] = inst_gen0.full_inst;
		 //Verbosity for each instruction
		 if (DBG_HIGH_VERBOSITY)
           $display("Instruction generated #%d:\t%h\topcode: %b ", i[15:0], inst_gen0.full_inst, inst_gen0.opcode);
      end
   endfunction

  function print_mem(logic DBG_HIGH_VERBOSITY=0);  //el argumento no se usa en esta función, se pone para que todas las funciones lo tengan
      $display("\n******************************************************************************************");
      $display("Stimulus: Invoked print_mem() -> print the actual state of MEM");
      $display("******************************************************************************************");
      foreach (MEM[i]) begin
		 $display("Instruction #%d:\t%h\topcode: %b ", i[15:0], MEM[i], MEM[i][6:0] );
      end   
  endfunction
   //referencia: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
   // filminas 8 y 9

endclass





class darksocv_driver extends uvm_driver #(rv32i_instruction);

  //==============================================================
  //         Configuration and steps of UVM
  //==============================================================

  `uvm_component_utils (arb_driver)
   function new (string name = "darksocv_driver", uvm_component parent = null);
     super.new (name, parent);
   endfunction

   virtual arb_intf intf;

   virtual function void build_phase (uvm_phase phase);
     super.build_phase (phase);
     if(uvm_config_db #(virtual arb_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      rv32i_instruction i_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
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

  // Load values to .mem file
  //*******************************************************
  function mem_load();
    $display("\n******************************************************************************************");
    $display("driver: Invoked mem_load()  -> load MEM to SoC");
    $display("******************************************************************************************");
    sti.mem_generate();
    sti.set_program_format();
    sti.opt_addr();
    //sti.print_mem();
    $writememh("darksocv.mem", sti.MEM);
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  // Send reset and clear soc inputs
  //*******************************************************
  virtual task reset(); 
    $display("\n******************************************************************************************");
    $display("driver: Invoked reset()     -> send RESET signal to SoC");
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
