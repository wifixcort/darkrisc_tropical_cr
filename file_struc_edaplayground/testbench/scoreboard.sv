class scoreboard;

  // Queue for STORING decoded instructions from Monitor
  logic [43:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1_val, rs2_val, rdd_val, imm_val
	
  // Internal Signals for decoded_inst proccessing
  logic [43:0] decoded_inst_x;
  logic [7:0] rx_funct;
  logic signed [20:0]  imm_val;
  logic signed [31:0]  imm_val_sign_ext;
  logic [4:0] rs1_val;
  logic [4:0] rs2_val;
  logic [4:0] rdd_val;
  logic [31:0] DATAI;
  logic [31:0] DATAO;
  logic [31:0] DADDR;
  //logic [31:0] pc_val;
  
  // Reference Model Instance
  riscv_ref_model ref_model;
  
  // Constructor
  function new();
    rx_funct = '0;
    //pc_val  = '0;
    imm_val = '0;
    rs1_val = '0;
    rs2_val = '0;
    rdd_val = '0;
    DATAI = '0;
    DATAO = '0;
    DADDR = '0;
    ref_model = new();
  endfunction
  
   // Function to push instruction to the queue
  function push_instruction(logic [7:0] rx_funct_in, logic signed [20:0] imm_val_in, logic [4:0] rs1_val_in, logic [4:0] rs2_val_in, logic [4:0] rdd_val_in);
    
    decoded_inst_q.push_back({rx_funct_in, imm_val_in, rs1_val_in, rs2_val_in, rdd_val_in});
  endfunction
  
  // Function to get values from the queue and procces instruction in our model
  function process_inst();
    if (!decoded_inst_q.empty()) begin
      
      // Assign values to internal signals
      decoded_inst_x = decoded_inst_q.pop_front();      
      rx_funct = decoded_inst_x[43:36];
      imm_val  = decoded_inst_x[35:15];
      rs1_val  = decoded_inst_x[14:10];
      rs2_val  = decoded_inst_x[9:5];
      rdd_val  = decoded_inst_x[4:0];
      
      // Predict with Reference Model
      ref_model.predict(rx_funct, imm_val, rs1_val, rs2_val, rdd_val);
      imm_val_sign_ext = ref_model.imm_val_sign_ext;
      rs1_val = ref_model.rs1_val_upd;
      rs2_val = ref_model.rs2_val_upd;
      rdd_val = ref_model.rdd_val_upd;
      //DATAI = ref_model.DATAI;
      //DATAO = ref_model.DATAO;
      //DADDR = ref_model.DADDR;
      //pc_val = ref_model.pc_val_upd;
      //rx_funct 
    end else begin
      // Queue is empty, handle the case 
      $display("Queue is empty!");
    end
  endfunction
endclass