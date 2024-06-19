class mon2_transaction extends uvm_sequence_item;
  // typedef struct {
    string	   inst;
    logic [7:0] instruction;
    logic [31:0]	risc_rd_p; // riscv rd register pointer
    logic [31:0]	risc_rd_v; // riscv rd register value
    logic [31:0]	risc_rs1_p; // riscv rs1 register pointer
    logic [31:0]	risc_rs1_v; // riscv rs1 register value
    logic [31:0]	risc_rs2_p; // riscv rs1 register pointer
    logic [31:0]	risc_rs2_v; // riscv rs1 register value
    logic [31:0]	risc_imm; // riscv immidiate value
 
    logic [31:0]	inst_PC;
    logic [31:0]	inst_XIDATA;
//  }data;
  
    `uvm_object_utils(mon2_transaction)
  
    function new(string name = "mon2_transaction");
      super.new(name);
    endfunction
  
    // function void do_print(uvm_printer printer);
    //   super.do_print(printer);
    //   printer.print_field_int("data", data, 8);
    // endfunction
  endclass
  