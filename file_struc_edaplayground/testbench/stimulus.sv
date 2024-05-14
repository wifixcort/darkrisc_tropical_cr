//Version Funcional

import instructions_data_struc::*;
`include "config.vh"
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
  logic opt_addr_select = 1'b0; //optimize for generate address
  logic [6:0]  aux_opcode;
  logic [2:0]  aux_funct3;
  logic [4:0]  aux_rs1;
  logic [4:0]  aux_rd;
  logic [4:0]  aux_rs2;
  logic [11:0] offset; // or aux_imm. Is the offset of load/storage instruction
  //logic [4:0]  reg0 = 5'h01;

  //=============================
  //Constraints
  //=============================
 
  
  // Generate the full instruction in last contraint solver
  //********************************************************
  constraint construct_full_inst{
    solve opcode,rd,rs1,rs2,funct7,funct3,imm before full_inst;
    //if (opt_addr_select){
      // force to ADDI
    //  full_inst == {imm,5'h00,ADDI_FC,rd,I_TYPE};
    //} else{
    (opcode == R_TYPE)   -> full_inst == {funct7,rs2,rs1,funct3,rd,opcode};
    (opcode == I_TYPE)   -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == I_L_TYPE) -> full_inst == {imm,rs1,funct3,rd,opcode};
    (opcode == S_TYPE)   -> full_inst == {imm[11:5],rs2, rs1,funct3,imm[4:0],opcode};
    //} 
    
  }
  
  //********************************************************
  constraint opcode_cases{
        opcode inside 	{R_TYPE,
                        I_TYPE,
                        I_L_TYPE,
                        S_TYPE
                        /*S_B_TYPE,
                        J_TYPE,
                        I_JALR_TYPE,
                        LUI_TYPE,
                        AUIPC_TYPE */
                        };
       
    }
      
    // 
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
	

    // Valid base address value in register used for load/store instruction. For ADDI instruction
    //**********************************************************************************************
          /*
    constraint base_addr{            
      //solve imm before full_inst;
      if (opt_addr_select) {   
          rd	 == aux_rs1;	//base address is saved here
      	  
          // esta condicion aun no se usa 
          if (aux_opcode == I_L_TYPE){
            (aux_funct3 == LH_FC) 	->	imm[0]   == 1'b0;
            (aux_funct3 == LHU_FC) 	->	imm[0]   == 1'b0;
            (aux_funct3 == LW_FC) 	->	imm[1:0] == 2'b00;
          }   
          // no falla porque está forzando 0's, si se ponen unos
          else if (aux_opcode == S_TYPE){
            (aux_funct3 == SH_FC) 	->	imm[0]   == 1'b0;
            (aux_funct3 == SW_FC) 	->	imm[1:0] == 2'b00;
          } 
         
          // Acotador
          //imm[11:9] == 3'b001;
		  //                ^ acota 511 < imm < 1023
          } 
  	}
*/

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
          // acotadores a +127 -127
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
  
          

          
class stimulus;
  reg [31:0] MEM [0:2**`MLEN/4-1];
  logic [7:0] debug_counter;
  logic [4:0] reg_addr;
  logic [31:0] effective_addr = 32'h00000000;
  
  // fulling the MEM array
  //**********************************************************
  function void mem_generate(logic DBG_HIGH_VERBOSITY=0);
    instruction_generator inst_gen0;
    inst_gen0 = new;
    debug_counter = 0;
    for(int i=0;i!=2**`MLEN/4;i=i+1)
    begin
        MEM[i] = 32'd0; //This is completely necessary, otherwise there are x's in the RAM 
    end
    foreach(MEM[i]) begin
      inst_gen0.randomize();
      //////////////////// For Debug
	    if (DBG_HIGH_VERBOSITY && debug_counter<50) begin //Print only n-instructions
        // Due to RISCV management of signed numbers, these displays ALWAYS (I think) print positive numbers
          if (inst_gen0.opcode==R_TYPE)begin
          $display("Instruction #=%d R_TYPE | op=%b  |  rs1=%d  |  rs2=%d  |  rd=%d |  imm=%d", debug_counter, inst_gen0.opcode, inst_gen0.rs1, inst_gen0.rs2, inst_gen0.rd, 0);
        end
          else if (inst_gen0.opcode==I_TYPE || inst_gen0.opcode==I_L_TYPE || inst_gen0.opcode==S_TYPE)begin
          $display("Instruction #%d I_TYPE  | op=%b  |  rs1=%d  |  rs2=%d  |  rd=%d |  imm=%d", debug_counter, inst_gen0.opcode, inst_gen0.rs1, inst_gen0.rs2, inst_gen0.rd, inst_gen0.imm[11:0]);
        end  
        debug_counter=debug_counter+1;
      end
      ///////////////////
      MEM[i] = inst_gen0.full_inst;
    end
  endfunction
  

  //Setea los registros en las primeras 31 instrucciones
  //Ultima instruccion debe ser bra *
  //*****************************************************
  function void set_program_format();
  	instruction_generator inst_gen1;
    inst_gen1 = new;
   
    // recorrer los 32 registros, el 0 no surtirá efecto
    for(int i=1; i<=31; i=i+1) begin 
      inst_gen1.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==i;}; //&& funct3==ADDI_FC && rs1==5'h00 && rd==i;};
      MEM[i-1] = inst_gen1.full_inst;
    end
    
    //se llena el 32 tambien para no afectar posterior ejecucion de opt_addr()
    inst_gen1.randomize() with {opcode==I_TYPE;};
    MEM[32] = inst_gen1.full_inst;
    
    //force loop in the final instruction
    MEM[$size(MEM)-2] = 32'b00000000000000000000000010010111; //auipc x1, 0
    MEM[$size(MEM)-1] = 32'b00000000000000001000000001100111; //jalr x0, 0(x1) puede ser necesario meter -4 de offset
    
  endfunction
  

  //insert address with sense in the pointer register before store and load instruction 
  //************************************************************************************
  function void opt_addr();
    instruction_generator inst_gen2;
    inst_gen2 = new;
    inst_gen2.opt_addr_select = 1'b1;
    foreach(MEM[i]) begin
      if (MEM[i][6:0] == S_TYPE) begin 
         //decode_ld(inst_gen2, MEM[i]); // obsoleto
        
          reg_addr = MEM[i][19:15]; // reg where store going to search
          // loop if effective_addr out of range
          do begin
          inst_gen2.randomize() with {opcode==I_TYPE && funct3==ADDI_FC && rd==reg_addr && rs1==5'h00 && imm <= 1023 && imm >= 512;};
          effective_addr = inst_gen2.imm + MEM[i][31:20] ;
          end while( (effective_addr < 512) && (effective_addr > 1023));  //ACOTADORES
          
          //addres should be aligned
          if (MEM[i][14:12]==SW_FC) 
            MEM[i-1] = {inst_gen2.full_inst[31:22], 2'b00, inst_gen2.full_inst[19:0]};
          else if(MEM[i][14:12]==SH_FC)
            MEM[i-1] = {inst_gen2.full_inst[31:21], 1'b0, inst_gen2.full_inst[19:0]};        
      end 
      // TODO: other if for I_L_TYPE insructions
    end
    inst_gen2.opt_addr_select = 1'b0;
  endfunction
  //referencia: https://riscv.org/wp-content/uploads/2018/12/14.25-Tao-Liu-Richard-Ho-UVM-based-RISC-V-Processor-Verification-Platform.pdf
  // filminas 8 y 9
  

  // decode load/stores instruction in force address process
  //********************************************************
  function void decode_ld(instruction_generator inst_gen, logic [31:0] instruction);
      inst_gen.aux_opcode  = instruction[6:0];
      inst_gen.aux_funct3  = instruction[14:12];
      inst_gen.aux_rs1     = instruction[19:15];   
      if (instruction[6:0] == S_TYPE) begin
            inst_gen.aux_rd  = instruction[11:7];  // only for load
            inst_gen.aux_rs2 = instruction[24:20];
            inst_gen.offset  = {instruction[31:25], instruction[11:7]};
      end
      else if (instruction[6:0] == I_L_TYPE) begin
            inst_gen.offset = instruction[31:20];
      end
  endfunction


  
endclass

 
// testbench
//*************************************88
//Unselect next line for test
//`define stimulus_tb
`ifdef stimulus_tb
  module tb;
    initial begin
      stimulus sti = new();
      sti.mem_generate(0);
      sti.set_program_format();
      sti.opt_addr();
      $display("**************************/n");
      $display("MEM size = %d\n",$size(sti.MEM));
      for (int i = 0 ; i < $size(sti.MEM); i++) begin
        $display("%d instruction  %h     op: %b", i, sti.MEM[i], sti.MEM[i][6:0]);
      end
      $display(".\n.\n.\n");
    end
  endmodule
`endif
