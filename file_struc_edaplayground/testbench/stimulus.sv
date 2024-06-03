import instructions_data_struc::*;
`include "../src/config.vh"
// for test
//`define MLEN 10

class instruction_generator;
   // random values 
   rand bit [31:0] full_inst;
   rand bit [6:0]  opcode;
   rand bit [4:0]  rs1;
   rand bit [4:0]  rs2;
   rand bit [4:0]  rd;
   rand bit [6:0]  funct7;
   rand bit [2:0]  funct3;
   rand bit [11:0] imm;
   // operation values
   logic		   opt_addr_select = 1'b0; //optimize for generate address

   //=============================
   //Constraints
   //=============================
   
   // Generate the full instruction in last contraint solver
   //********************************************************
   constraint construct_full_inst{
      solve opcode,rd,rs1,rs2,funct7,funct3,imm before full_inst;
      (opcode == R_TYPE)   -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
      (opcode == I_TYPE)   -> full_inst == {imm,rs1,funct3,rd,opcode};
      (opcode == I_L_TYPE) -> full_inst == {imm,rs1,funct3,rd,opcode};
      (opcode == S_TYPE)   -> full_inst == {imm[11:5],rs2, rs1,funct3,imm[4:0],opcode};
      //} 
      
   }
   

   //********************************************************
   constraint opcode_cases{
      opcode dist 	{R_TYPE :/ 44,
                     I_TYPE  :/ 44,
                     //I_L_TYPE
                     S_TYPE  :/ 12
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
         }       
         else if (opcode == S_TYPE){
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
   
endclass


//===============================================================
//===============================================================
//
//  Clase generadora de memoria y programa aleatorio a utilizar
//
//  min_data_addr  2**`MLEN/(4*2)  |  max_data_addr 2**`MLEN/4-1
//
//***************************************************************     
class stimulus;
   logic [31:0]	   MEM [0:2**`MLEN/4-1];
   logic [4:0]	   reg_addr;
   logic [31:0]	   effective_addr = 32'h00000000;
   int			   min_data_addr = 2**`MLEN/(4*2);
   int			   max_data_addr = 2**`MLEN/4-1;
   
   // fulling the MEM array
   //**********************************************************
   function  mem_generate(logic DBG_HIGH_VERBOSITY=0); // si no se pone el parametro de entrada no compila, en algun lugar se le está pasando algo
      instruction_generator inst_gen0; 
      inst_gen0 = new; 
      $display("\n********************************************************************************");
      $display("Stimulus: Invoked mem_generate() -> proced to generate random instructions array");
      $display("********************************************************************************");
      // inicializate MEM to 0
      for(int i=0;i!=2**`MLEN/4;i=i+1) begin
         MEM[i] = 32'd0; //This is completely necessary, otherwise there are x's in the RAM 
         // En el siguiente for ya se llenan ¿?
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
   

   //Setea los registros en las primeras 31 instrucciones
   //Ultima instruccion debe ser bra *
   //*****************************************************
   function  set_program_format(logic DBG_HIGH_VERBOSITY=0);
  	  instruction_generator inst_gen1;
      inst_gen1 = new;
      $display("\n********************************************************************************");
      $display("Stimulus: Invoked set_program_format()) -> set first and last instructions");
      $display("********************************************************************************");
      // recorrer los 32 registros, el 0 no surtirá efecto
      for(int i=1; i<=31; i=i+1) begin 
		 inst_gen1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==i;}; //&& funct3==ADDI_FC && rs1==5'h00 && rd==i;};
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
         $display("(force auipc x1,0)      Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-2, 32'h0000_0097);
         $display("(force jalr x0, 0(x1))  Instruction fixed #%d\t\tnew instruction: 0x%h", 2**`MLEN/(4*2)-1, 32'h0000_0097);
      end
      
   endfunction
   

   //insert address with sense in the pointer register before store and load instruction 
   //************************************************************************************
   function opt_addr(logic DBG_HIGH_VERBOSITY=0);
      instruction_generator inst_gen2;
      inst_gen2 = new;
      $display("\n******************************************************************************************");
      $display("Stimulus: Invoked opt_addr() -> set instructions before load/storage for force valid address");
      $display("******************************************************************************************");
      inst_gen2.opt_addr_select = 1'b1;
      for (int i=0;i!=2**`MLEN/(4*2);i=i+1) begin
		 if (MEM[i][6:0] == S_TYPE) begin         
			reg_addr = MEM[i][19:15]; // reg where store going to search adrress

			// loop if effective_addr out of range
			do begin                                                                                //ACOTADORES de base_address
			   inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm <= 1023 && imm >= 512;};
			   effective_addr = inst_gen2.imm + {MEM[i][31:25], MEM[i][11:7]} ;
			end while( (effective_addr < 512) && (effective_addr > 1023));  //ACOTADORES effective_address
			
			//addres should be aligned
			if (MEM[i][14:12]==SW_FC) 
              MEM[i-1] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};
			else if(MEM[i][14:12]==SH_FC)
              MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};  
			
			if (DBG_HIGH_VERBOSITY) begin
               $display("(force ADDI for set base addrress before store)\tInstruction fixed #%d\t\tnew instruction:%h\tbase address:%h", i[15:0]-1'b1, MEM[i-1], MEM[i-1][31:20]);
    		end
		 end 
		 else if (MEM[i][6:0] == I_L_TYPE) begin 
			if (MEM[i][6:0] == S_TYPE) begin         
			   reg_addr = MEM[i][19:15]; // reg where load going to search address

			   // loop if effective_addr out of range
			   do begin                                                                                     //ACOTADORES de base_address
				  inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm <= 1023 && imm >= 512;};
				  effective_addr = inst_gen2.imm + MEM[i][31:20];
			   end while( (effective_addr < 512) && (effective_addr > 1023));  //ACOTADORES de effective_address
			   
			   //addres should be aligned. Puede no ser necesario
			   if (MEM[i][14:12]==LH_FC) 
				 MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};
			   else if(MEM[i][14:12]==LHU_FC)
				 MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]}; 
			   else if(MEM[i][14:12]==LW_FC)
				 MEM[i-1] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};  
			   
			   if (DBG_HIGH_VERBOSITY) begin
				  $display("(force ADDI for set base addrress before store)\tInstruction fixed #%d\t\tnew instruction:%h\tbase address:%h", i[15:0]-1'b1, MEM[i-1], MEM[i-1][31:20]);
    		   end
			end 
		 end
		 // TODO: other if for I_L_TYPE insructions
      end
      inst_gen2.opt_addr_select = 1'b0;
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


// testbench
//*************************************88
//Unselect next line for test
//`define stimulus_tb
`ifdef stimulus_tb
module tb;
   initial begin
      stimulus sti = new();
      
      // Uso de la clase stimulus
      // El parametro que se le pasa a las funciones es para imprimir detalles de ejcucion (On = 1)
      //*************************
      sti.mem_generate(1);
      sti.set_program_format(1);
      sti.opt_addr(1);
      sti.print_mem();
      //

      $display("**************************");
      $display("MEM size = %d\n",$size(sti.MEM));
      //for (int i = 0 ; i < $size(sti.MEM); i++) begin
      //  $display("%d instruction  %h     op: %b", i[7:0], sti.MEM[i], sti.MEM[i][6:0]);
      //end
      $display(".\n.\n.\n");
   end
endmodule
`endif
