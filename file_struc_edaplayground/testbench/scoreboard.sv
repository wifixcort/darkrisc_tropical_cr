class scoreboard;

  // Queue for STORING decoded instructions from Monitor
  logic [75:0] decoded_inst_q [$]; // Data in queue: rx_funct, rs1, rs2, rdd, imm_val
	
  // Internal Signals for decoded_inst proccessing
  logic [75:0] decoded_inst_x;
  logic [7:0] rx_funct;
  logic signed [20:0]  imm_val;
  logic signed [31:0]  imm_val_sign_ext;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rdd;
  logic [31:0] DATAI;
  logic [31:0] DATAO;
  logic [31:0] DADDR;
  logic [31:0] pc_val;
  
  // For Debug
  logic [31:0] rs1_val_ini;
  logic [31:0] rs2_val_ini;

  // Reference Model Instance
  riscv_ref_model ref_model;
  
  // Constructor
  function new();
    rx_funct = '0;
    imm_val = '0;
    rs1 = '0;
    rs2 = '0;
    rdd = '0;
    DATAI = '0;
    DATAO = '0;
    DADDR = '0;
    pc_val = '0;
    ref_model = new();
  endfunction
  
   // Function to push instruction to the queue
  function push_instruction(logic [31:0] pc_val_in, logic [7:0] rx_funct_in, logic signed [20:0] imm_val_in, logic [4:0] rs1_in, logic [4:0] rs2_in, logic [4:0] rdd_in);
    
    decoded_inst_q.push_back({pc_val_in, rx_funct_in, imm_val_in, rs1_in, rs2_in, rdd_in});
  endfunction
  
  // Function to get values from the queue and procces instruction in our model
  function process_inst();
    if (decoded_inst_q.size()!=0) begin
      
      // Assign values to internal signals
      decoded_inst_x = decoded_inst_q.pop_front();   
      pc_val   = decoded_inst_x[75:44];
      rx_funct = decoded_inst_x[43:36];
      imm_val  = decoded_inst_x[35:15];
      rs1  = decoded_inst_x[14:10];
      rs2  = decoded_inst_x[9:5];
      rdd  = decoded_inst_x[4:0];
      
      // Predict with Reference Model
      ref_model.predict(pc_val,rx_funct, imm_val, rs1, rs2, rdd);
      imm_val_sign_ext = ref_model.imm_val_sign_ext;
      DATAI = ref_model.DATAI;
      DATAO = ref_model.DATAO;
      DADDR = ref_model.DADDR;
      pc_val = ref_model.pc_val_upd;
	  rs1_val_ini = ref_model.rs1_val_ini;
	  rs2_val_ini = ref_model.rs2_val_ini;

      // Dump Model Registers
      top.scbdreg_dmpd0 = ref_model.REGS[0];
      top.scbdreg_dmpd1 = ref_model.REGS[1];
      top.scbdreg_dmpd2 = ref_model.REGS[2];
      top.scbdreg_dmpd3 = ref_model.REGS[3];
      top.scbdreg_dmpd4 = ref_model.REGS[4];
      top.scbdreg_dmpd5 = ref_model.REGS[5];
      top.scbdreg_dmpd6 = ref_model.REGS[6];
      top.scbdreg_dmpd7 = ref_model.REGS[7];
      top.scbdreg_dmpd8 = ref_model.REGS[8];
      top.scbdreg_dmpd9 = ref_model.REGS[9];
      top.scbdreg_dmpd10 = ref_model.REGS[10];
      top.scbdreg_dmpd11 = ref_model.REGS[11];
      top.scbdreg_dmpd12 = ref_model.REGS[12];
      top.scbdreg_dmpd13 = ref_model.REGS[13];
      top.scbdreg_dmpd14 = ref_model.REGS[14];
      top.scbdreg_dmpd15 = ref_model.REGS[15];
      top.scbdreg_dmpd16 = ref_model.REGS[16];
      top.scbdreg_dmpd17 = ref_model.REGS[17];
      top.scbdreg_dmpd18 = ref_model.REGS[18];
      top.scbdreg_dmpd19 = ref_model.REGS[19];
      top.scbdreg_dmpd20 = ref_model.REGS[20];
      top.scbdreg_dmpd21 = ref_model.REGS[21];
      top.scbdreg_dmpd22 = ref_model.REGS[22];
      top.scbdreg_dmpd23 = ref_model.REGS[23];
      top.scbdreg_dmpd24 = ref_model.REGS[24];
      top.scbdreg_dmpd25 = ref_model.REGS[25];
      top.scbdreg_dmpd26 = ref_model.REGS[26];
      top.scbdreg_dmpd27 = ref_model.REGS[27];
      top.scbdreg_dmpd28 = ref_model.REGS[28];
      top.scbdreg_dmpd29 = ref_model.REGS[29];
      top.scbdreg_dmpd30 = ref_model.REGS[30];
      top.scbdreg_dmpd31 = ref_model.REGS[31]; 
    end else begin
      // Queue is empty, handle the case 
      // $display("Queue is empty!");
    end
  endfunction
endclass
