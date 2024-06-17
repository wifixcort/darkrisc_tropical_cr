class my_transaction_mon2 extends uvm_sequence_item;
    // Define fields as per your requirements
    logic signed [31:0] imm_val_sign_ext;
    logic [4:0] rs1_val;
    logic [4:0] rs2_val;
    logic [4:0] rdd_val;
    logic [31:0] DATAI;
    logic [31:0] DATAO;
    logic [31:0] DADDR;
    logic [31:0] pc_val;

    // Constructor
    function new(string name = "my_transaction");
        super.new(name);
    endfunction

    /*
    // Function to print transaction details
    function void display();
        $display("Transaction Details:");
        $display("  imm_val_sign_ext = %h", imm_val_sign_ext);
        $display("  rs1_val          = %h", rs1_val);
        $display("  rs2_val          = %h", rs2_val);
        $display("  rdd_val          = %h", rdd_val);
        $display("  DATAI            = %h", DATAI);
        $display("  DATAO            = %h", DATAO);
        $display("  DADDR            = %h", DADDR);
        $display("  pc_val           = %h", pc_val);
    endfunction
    */
    // Implement any additional functionality as needed
endclass
