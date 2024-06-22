import instructions_data_struc::*;

class gen_sequence extends uvm_sequence;

  //==============================================================
  //         Configuration and steps of UVM
  //==============================================================
  `uvm_object_utils(gen_sequence)
  function new(string name="gen_sequence");
    super.new(name);
  endfunction

  
  //==============================================================
  //         Generate memory and instruction sequences 
  //==============================================================

  logic [31:0]	   MEM [0:2**`MLEN/4-1];
  logic [4:0]	   reg_addr;
  logic [31:0]	   effective_addr = 32'h00000000;
  int			   min_data_addr = 2**`MLEN/(4*2);
  int			   max_data_addr = 2**`MLEN/4-1;


  // Write .mem file
  //**********************************************************
  function write_mem();
    $writememh("darksocv.mem", MEM);
  endfunction

  // Full the MEM array with R and I instructions
  //**********************************************************
  function gen_instructs_R_I(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen0; 
    inst_gen0 = new; 
    `uvm_info("gen_instructs_R_I()", $sformatf("Generating R & I instructions"), UVM_MEDIUM)
    for(int i=0;i!=2**`MLEN/4;i=i+1) begin 
      if (i < 2**`MLEN/(4*2)) begin
        inst_gen0.randomize() with {opcode inside {I_TYPE, R_TYPE};};
		    MEM[i] = inst_gen0.full_inst;  // Instructions memory
      end else begin
        MEM[i] = 32'd0;                // Data memory
      end 
      //`uvm_info("gen_instructs_R_I()", $sformatf("Instruction generated #%d:\t%h\topcode: %b ", i[15:0], inst_gen0.full_inst, inst_gen0.opcode), UVM_LOW)
    end
  endfunction


  // Full the MEM array with R, I, L and S instructions
  //**********************************************************
  function gen_instructs_R_I_L_S(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen0; 
    inst_gen0 = new; 
    `uvm_info("gen_instructs_R_I_L_S()", $sformatf("Generating R, I, L & S instructions"), UVM_MEDIUM)
    for(int i=0;i!=2**`MLEN/4;i=i+1) begin 
      //se insertan primero dos instrucciones I/R para poder insertar instrucciones correctivas en caso de un Load/Store
      if (i < 2) begin 
        inst_gen0.randomize() with {opcode inside {I_TYPE, R_TYPE};};
        MEM[i] = inst_gen0.full_inst;  // Force first instruction
      end else if (i < 2**`MLEN/(4*2)) begin
        inst_gen0.randomize();
		    MEM[i] = inst_gen0.full_inst;  // Instructions memory
      end else begin
        MEM[i] = 32'd0;                // Data memory
      end 
      //`uvm_info("gen_instructs_R_I_L_S()", $sformatf("Instruction generated #%d:\t%h\topcode: %b ", i[15:0], inst_gen0.full_inst, inst_gen0.opcode), UVM_LOW)   
    end
  endfunction


  // Force loop in the final instructions so that the PC does not get out of rank
  //**********************************************************
  function loop_end_of_program(logic DBG_HIGH_VERBOSITY=0);
    `uvm_info("loop_end_of_program()", $sformatf("Generating AUIPC & JALR for loop end of program"), UVM_MEDIUM)
    MEM[2**`MLEN/(4*2)-2] = 32'b00000000000000000000000010010111; //auipc x1, 0
    MEM[2**`MLEN/(4*2)-1] = 32'b00000000000000001000000001100111; //jalr x0, 0(x1) puede ser necesario meter -4 de offset
    //if (DBG_HIGH_VERBOSITY) begin
    `uvm_info("loop_end_of_program", $sformatf("(force auipc x1,0)      Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-2, 32'b00000000000000000000000010010111), UVM_LOW)
    `uvm_info("loop_end_of_program", $sformatf("(force jalr x0, 0(x1))  Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-1, 32'b00000000000000001000000001100111), UVM_LOW)
  endfunction


  // Hacer que las primeras instrucciones seteen los registros
  //**********************************************************
  function set_regs(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen1;
    inst_gen1 = new;
    `uvm_info("set_regs()", $sformatf("Seting registers in firsts instructions"), UVM_MEDIUM)
    // recorrer los 31 registros modificables 
    for(int i=1; i<=31; i=i+1) begin 
		  inst_gen1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rs1==0 && rd==i;};
		  MEM[i-1] = inst_gen1.full_inst;
		  //if (DBG_HIGH_VERBOSITY)
      `uvm_info("set_regs()", $sformatf("(inicializate reg x%d) Instruction fixed #%d:\t\tnew instruction:%h\tnew opcode: %b ",inst_gen1.rd, i[15:0]-1'b1, inst_gen1.full_inst, inst_gen1.opcode), UVM_LOW)
      //$display("(inicializate reg x%d) Instruction fixed #%d:\t\tnew instruction:%h\tnew opcode: %b ",inst_gen1.rd, i[15:0]-1'b1, inst_gen1.full_inst, inst_gen1.opcode);
    end   
    //forzar I/R en instruccion 31 y 32 para no afectar posterior ejecucion de opt_addr()
    inst_gen1.randomize() with {opcode inside {I_TYPE, R_TYPE};};
    MEM[32] = inst_gen1.full_inst;
    inst_gen1.randomize() with {opcode inside {I_TYPE, R_TYPE};};
    MEM[33] = inst_gen1.full_inst;
    //if (DBG_HIGH_VERBOSITY) begin
    `uvm_info("set_regs()", $sformatf("(force) Instruction fixed          #%d:\t\tnew instruction:%h\tnew opcode: %b ", 16'd31, MEM[31], MEM[31][6:0]), UVM_LOW)
    `uvm_info("set_regs()", $sformatf("(force) Instruction fixed          #%d:\t\tnew instruction:%h\tnew opcode: %b ", 16'd32, MEM[32], MEM[32][6:0]), UVM_LOW)
  endfunction


  //Generating a valid effective address for store and load instructions
  //  Para esto se necesitan agregar dos instrucciones antes de cada load/store
  //************************************************************************************
  function opt_addr(logic DBG_HIGH_VERBOSITY=0);
    sequence_item_rv32i_instruction inst_gen2;
    inst_gen2 = new;
    `uvm_info("opt_addr()", $sformatf("Generating a valid effective address for store and load instructions"), UVM_MEDIUM)
    inst_gen2.opt_addr_select = 1'b1;
    for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
		  if (MEM[i][6:0] == S_TYPE) begin         
			  reg_addr = MEM[i][19:15]; // reg where store_instruction going to search adrress

        // loop if effective_addr out of range
			  do begin                                                                                //limitador para que base_address sea positivo y > 2048 si se le hace un shift l
			    inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm[11:10]==2'b01;}; 
			    effective_addr = {1'b1,inst_gen2.imm[10:0]} + {MEM[i][31:25], MEM[i][11:7]} ; // Effective Address = addi.imm + store.offset
			  end while( (effective_addr < 2**`MLEN/2) && (effective_addr >= 2**`MLEN));  //ACOTADORES effective_address
			
			  //addres should be aligned.
			  if (MEM[i][14:12]==SW_FC) 
          MEM[i-2] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};
			  else if(MEM[i][14:12]==SH_FC)
          MEM[i-2] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};  
        else if (MEM[i][14:12] == SB_FC) 
          MEM[i-2] = inst_gen2.full_inst; 
                                                                                                        
        //se hace un shift left para forzar valor entre 0x800 y 0xFFF de direccion base
        inst_gen2.randomize() with {opcode==I_TYPE && funct3==SLLI_FC && rd==reg_addr && rs1==reg_addr && imm[4:0] == 5'h001;};
        MEM[i-1] = inst_gen2.full_inst;

        if (DBG_HIGH_VERBOSITY) begin
				  $display("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]);
          $display("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]);
          $display("(for STORE)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]);
          //$display("Effective address = %h ", (MEM[i-2][31:20] << 1) + {MEM[i][31:25], MEM[i][11:7]});
    		end

        // `uvm_info("opt_addr()", $sformatf("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]), UVM_LOW)
        // `uvm_info("opt_addr()", $sformatf("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]), UVM_LOW)
        // `uvm_info("opt_addr()", $sformatf("(for STORE)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]), UVM_LOW)
		  end 

      //En este if se repite casi lo mismo que con las S_TYPE,
		  else if (MEM[i][6:0] == I_L_TYPE) begin        
			  reg_addr = MEM[i][19:15]; // reg where load_instruction going to search address
        // loop if effective_addr out of range
			  do begin                                                                                //limitador para que base_address sea positivo y > 2048 si se le hace un shift l
			    inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm[11:10]==2'b01;};
			    effective_addr = (inst_gen2.imm << 1) + {MEM[i][31:25], MEM[i][11:7]} ; // Effective Address = addi.imm<<1 + store.offset
			  end while( (effective_addr < 2**`MLEN/2) && (effective_addr >= 2**`MLEN));  //ACOTADORES effective_address   
			  //addres should be aligned.
        if(MEM[i][14:12]==LW_FC)
				  MEM[i-2] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};
			  else if (MEM[i][14:12]==LH_FC) 
				  MEM[i-2] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};
			  else if(MEM[i][14:12]==LHU_FC)
				  MEM[i-2] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};    
        else if (MEM[i][14:12] == LB_FC) 
          MEM[i-2] = {inst_gen2.full_inst}; 
        else if (MEM[i][14:12] == LBU_FC) 
          MEM[i-2] = {inst_gen2.full_inst};
        //se hace un shift left para forzar valor entre 0x800 y 0xFFF de direccion base
        inst_gen2.randomize() with {opcode==I_TYPE && funct3==SLLI_FC && rd==reg_addr && rs1==reg_addr && imm[4:0] == 5'h001;};
        MEM[i-1] = inst_gen2.full_inst;
			  // verbosity
        if (DBG_HIGH_VERBOSITY) begin
				  $display("\n(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]);
          $display("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]);
          $display("(for LOAD)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]);
          //$display("Effective address = %h ", (MEM[i-2][31:20] << 1) + {MEM[i][31:25], MEM[i][11:7]});
    		end
        ////`uvm_info("opt_addr()", $sformatf("(force ADDI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h2, MEM[i-2]), UVM_LOW)
        `uvm_info("opt_addr()", $sformatf("(force XORI)\tInstruct fixed #%d\t\tnew instruct:%h", i[15:0]-2'h1, MEM[i-1]), UVM_LOW)
        //`uvm_info("opt_addr()", $sformatf("(for LOAD)\t\tInstruct #%d\t\tinstruct: %h", i[15:0], MEM[i]), UVM_LOW)
        //`uvm_info("opt_addr()", $sformatf("Effective address = %h ", (MEM[i-2][31:20] << 1) + {MEM[i][31:25], MEM[i][11:7]}), UVM_LOW)
		  end
    end
    inst_gen2.opt_addr_select = 1'b0;
   endfunction


  // Imprimir la memoria de instrucciones local (de esta clase, no del .mem)
  //************************************************************************
  function print_mem();  //el argumento no se usa en esta función, se pone para que todas las funciones lo tengan
      `uvm_info("print_mem()", $sformatf("Print Instruction Memory: "), UVM_MEDIUM)
      for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
        `uvm_info("print_mem()", $sformatf("Instruction #%d:\t%h\topcode: %b ", i[15:0], MEM[i], MEM[i][6:0] ), UVM_MEDIUM) 
		  $display(); //verbosity
      end   
  endfunction

   //referencia: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
   // filminas 8 y 9

endclass