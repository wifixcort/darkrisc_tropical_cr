//`include "uvm_macros.svh"
//import uvm_pkg::*;

import instructions_data_struc::*;
//`include "../rtl/config.vh"


// sequence generator <- legacy class stimulus
class gen_sequence extends uvm_sequence;

  //==============================================================
  //         Configuration and steps of UVM
  //==============================================================
  `uvm_object_utils(gen_sequence)
  function new(string name="gen_sequence");
    super.new(name);
  endfunction

  
   
  // VERSION DEL EJEMPLO
  // rand int num; 	// Config total number of items to be sent
  // constraint c1 { num inside {[2:5]}; }

  // virtual task body();
  //   sequence_item_rv32i_instruction i_item = sequence_item_rv32i_instructionn::type_id::create("i_item");
  //   for (int i = 0; i < num; i ++) begin
  //       start_item(i_item);
  //   	i_item.randomize();
  //   	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
  //   	i_item.print();
  //       finish_item(i_item);
  //       //`uvm_do(i_item);
  //   end
  //   `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  // endtask


  //==============================================================
  //         Generate memory and instruction sequences 
  //==============================================================

  logic [31:0]	   MEM [0:2**`MLEN/4-1];
  logic [4:0]	   reg_addr;
  logic [31:0]	   effective_addr = 32'h00000000;
  int			   min_data_addr = 2**`MLEN/(4*2);
  int			   max_data_addr = 2**`MLEN/4-1;

   
  // fulling the MEM array
  //**********************************************************
  // todo: convertir en funcion para generar instrucciones r,i,l,s
  function void mem_generate(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen0; 
    inst_gen0 = new; 
    //$display("Stimulus: Invoked mem_generate() -> proced to generate random instructions array");
 
    for(int i=0;i!=2**`MLEN/4;i=i+1) begin
      if (i == 0) begin
        inst_gen0.randomize() with {opcode inside {I_TYPE, R_TYPE};};
        MEM[i] = inst_gen0.full_inst;  // Force first instruction
      end else if (i < 2**`MLEN/(4*2)) begin
        inst_gen0.randomize();
		    MEM[i] = inst_gen0.full_inst;  // Instructions memory
      end else begin
        MEM[i] = 32'd0;                // Data memory
      end 

      //Verbosity for each instruction
      if (DBG_HIGH_VERBOSITY) 
        $display("Instruction generated #%d:\t%h\topcode: %b ", i[15:0], inst_gen0.full_inst, inst_gen0.opcode);
    end

  endfunction



     //Setea los registros en las primeras 31 instrucciones
   //Ultima instruccion debe ser bra *
   //*****************************************************
  function  set_program_format(logic DBG_HIGH_VERBOSITY=0);
  	sequence_item_rv32i_instruction inst_gen1;
    inst_gen1 = new;

    $display("\ngen_sequence: set_program_format() -> set first and last instructions");

    // recorrer los 31 registros modificables 
    for(int i=1; i<=31; i=i+1) begin 
		  inst_gen1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==i;};
		  MEM[i-1] = inst_gen1.full_inst;
		  if (DBG_HIGH_VERBOSITY)
        $display("(inicializate reg x%d) Instruction fixed #%d:\t\tnew instruction:%h\tnew opcode: %b ",inst_gen1.rd, i[15:0]-1'b1, inst_gen1.full_inst, inst_gen1.opcode);
    end
      
    //forzar I_TYPE en instruccion 31 para no afectar posterior ejecucion de opt_addr()
    inst_gen1.randomize() with {opcode==I_TYPE;};
    MEM[32] = inst_gen1.full_inst;
    if (DBG_HIGH_VERBOSITY)
		$display("(force I_TYPE) Instruction fixed          #%d:\t\tnew instruction:%h\tnew opcode: %b ", 16'd31, inst_gen1.full_inst, inst_gen1.opcode);
      
    //force loop in the final instruction
    MEM[2**`MLEN/(4*2)-2] = 32'b00000000000000000000000010010111; //auipc x1, 0
    MEM[2**`MLEN/(4*2)-1] = 32'b00000000000000001000000001100111; //jalr x0, 0(x1) puede ser necesario meter -4 de offset
    if (DBG_HIGH_VERBOSITY) begin
      $display("(force auipc x1,0)      Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-2, 32'b00000000000000000000000010010111);
      $display("(force jalr x0, 0(x1))  Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-1, 32'b00000000000000001000000001100111);
    end    
   endfunction


  //insert address with sense in the pointer register before store and load instruction 
   //************************************************************************************
  function opt_addr(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen2;
    inst_gen2 = new;
    $display("\ngen_sequence: opt_addr() -> set instructions before load/storage for force valid address");

    inst_gen2.opt_addr_select = 1'b1;
    for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
		  if (MEM[i][6:0] == S_TYPE) begin         
			  reg_addr = MEM[i][19:15]; // reg where store_instruction going to search adrress

        // loop if effective_addr out of range
			  do begin                                                                                //ACOTADORES de base_address
			    inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm <= 1023 && imm >= 512;};
			    effective_addr = inst_gen2.imm + {MEM[i][31:25], MEM[i][11:7]} ; // Effective Address = addi.imm + store.offset
			  end while( (effective_addr < 512) && (effective_addr > 1023));  //ACOTADORES effective_address
			
			  //addres should be aligned. Puede no ser necesario
			  if (MEM[i][14:12]==SW_FC) 
          MEM[i-1] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};
			  else if(MEM[i][14:12]==SH_FC)
          MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};  
        else   //if (fc3 == SB) 
          MEM[i-1] = {inst_gen2.full_inst}; 
			
			  if (DBG_HIGH_VERBOSITY) begin
          $display("(force ADDI for set base addrress before store)\tInstruct fixed #%d\t\tnew instruct:%h\tbase address:%h", i[15:0]-1'b1, MEM[i-1], MEM[i-1][31:20]);
    	  end
		  end 

		  else if (MEM[i][6:0] == I_L_TYPE) begin        
			  reg_addr = MEM[i][19:15]; // reg where load_instruction going to search address

			  // loop if effective_addr out of range
			  do begin                                                                                     //ACOTADORES de base_address
				  inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm <= 1023 && imm >= 512;};
				  effective_addr = inst_gen2.imm + MEM[i][31:20]; // Effective Address = addi.imm + load.offset
			  end while( (effective_addr < 512) && (effective_addr > 1023));  //ACOTADORES de effective_address
			   
			  //addres should be aligned. Puede no ser necesario
			  if (MEM[i][14:12]==LH_FC) 
				  MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};
			  else if(MEM[i][14:12]==LHU_FC)
				  MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]}; 
			  else if(MEM[i][14:12]==LW_FC)
				  MEM[i-1] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]}; 
        else   //if (fc3 == LB) 
          MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]}; //prueba
          //MEM[i-1] = {inst_gen2.full_inst}; 
			  
        if (DBG_HIGH_VERBOSITY) begin
				  $display("(force ADDI for set base addrress before load)\tInstruct fixed #%d\t\tnew instruct:%h\tbase address:%h", i[15:0]-1'b1, MEM[i-1], MEM[i-1][31:20]);
    		end
		 end
    end
    inst_gen2.opt_addr_select = 1'b0;
   endfunction


  function void print_mem();  //el argumento no se usa en esta función, se pone para que todas las funciones lo tengan
      $display("\ngen_sequence: Invoked print_mem() -> print the actual state of MEM");
      `uvm_info("gen_sequence", $sformatf("Values in ROM: "), UVM_MEDIUM)
      for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
		  $display("Instruction #%d:\t%h\topcode: %b ", i[15:0], MEM[i], MEM[i][6:0] ); //verbosity
      end   
  endfunction

   //referencia: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
   // filminas 8 y 9

endclass