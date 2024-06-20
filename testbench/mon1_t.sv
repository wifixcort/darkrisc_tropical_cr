class mon1_t extends uvm_sequence_item;
    
    logic [7:0]             pc_val = 0;
    logic [7:0]             rx_funct = 0;
    logic signed [20:0]     imm_val = 0;
    logic [4:0]             rs1_val = 0;
    logic [4:0]             rs2_val = 0;
    logic [4:0]             rdd_val = 0;
  
    `uvm_object_utils(mon1_t)
  
    function new(string name = "mon1_t");
      super.new(name);
    endfunction

endclass