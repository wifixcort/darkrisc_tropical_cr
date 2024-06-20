class monitor_tr extends uvm_sequence_item;

    // Mon2
    string	   inst;
    logic [7:0] instruction;
    logic [4:0]	risc_rd_p; // riscv rd register pointer
    logic [31:0]	risc_rd_v; // riscv rd register value
    logic [4:0]	risc_rs1_p; // riscv rs1 register pointer
    logic [31:0]	risc_rs1_v; // riscv rs1 register value
    logic [4:0]	risc_rs2_p; // riscv rs1 register pointer
    logic [31:0]	risc_rs2_v; // riscv rs1 register value
    logic [31:0]	risc_imm; // riscv immidiate value

    // SCB
    /*
    logic [31:0]	sb_rd_p; // sb rd register pointer
    logic [31:0]	sb_rd_v; // sb rd register value
    logic [31:0]	sb_rs1_p; // sb rs1 register pointer
    logic [31:0]	sb_rs1_v; // sb rs1 register value
    logic [31:0]	sb_rs2_p; // sb rs1 register pointer
    logic [31:0]	sb_rs2_v; // sb rs1 register value
    logic [31:0]	sb_imm; // sb immidiate value
    logic [31:0]	sb_DADDR;
    logic [31:0]	sb_DATAI;
    */
    logic [31:0]	inst_PC;
    logic [31:0]	inst_XIDATA;
    logic [15:0]	inst_counter;
    // Mon1
    logic [31:0]             pc_val_mon1 = 0;
    logic [7:0]             rx_funct_mon1 = 0;
    logic signed [20:0]     imm_val_mon1 = 0;
    logic [4:0]             rs1_val_mon1 = 0;
    logic [4:0]             rs2_val_mon1 = 0;
    logic [4:0]             rdd_val_mon1 = 0;

    `uvm_object_utils(monitor_tr)
  
    function new(string name = "monitor_tr");
      super.new(name);
    endfunction

    // virtual function void build_phase(uvm_phase phase);
    //   super.build_phase(phase);
          
      
    // endfunction    
  
  endclass
  