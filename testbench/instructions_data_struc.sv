package instructions_data_struc;

  localparam R_TYPE      = 7'b01100_11;
  localparam I_TYPE      = 7'b00100_11;
  localparam I_L_TYPE    = 7'b00000_11; //Immediate-load
  localparam S_TYPE      = 7'b01000_11;
  localparam S_B_TYPE    = 7'b11000_11; //S-Branch
  localparam J_TYPE      = 7'b11011_11; 
  localparam I_JALR_TYPE = 7'b11001_11; 
  localparam LUI_TYPE    = 7'b01101_11; //U-Type, but it has its own OPCODE
  localparam AUIPC_TYPE  = 7'b00101_11; //U-Type, but it has its own OPCODE


  localparam OPCODE_SIZE = 7;

  /////////////////////////////////////////////////////////
  //Instruction codification
  // These codes represent the instruction that the monitor
  // decodifies, so the client receives a number and can 
  // use a simple case to assign or take decisions.
  /////////////////////////////////////////////////////////

  // R-Type instructions codes (Home-made. Not standard)
  localparam ADD          =1;
  localparam SUB          =2;
  localparam XOR          =3;
  localparam OR           =4;
  localparam AND          =5;
  localparam SLL          =6;
  localparam SRL          =7;
  localparam SRA          =8;
  localparam SLT          =9;
  localparam SLTU         =10;

  // I-Type instructions codes (Home-made. Not standard)
  localparam ADDI         =11;       //Start of I
  localparam XORI         =12;
  localparam ORI          =13;
  localparam ANDI         =14;
  localparam SLLI         =15;
  localparam SRLI         =16;
  localparam SRAI         =17;
  localparam SLTI         =18;
  localparam SLTIU        =19;

  // I-L(load)Type instructions codes (Home-made. Not standard)
  localparam LB           =20;         //Start of I-Load
  localparam LH           =21;
  localparam LW           =22;
  localparam LBU          =23;
  localparam LHU          =24;

  // S-Type instructions codes (Home-made. Not standard)
  localparam SB           =25;         //Start of I-Load
  localparam SH           =26;
  localparam SW           =27;

  // S-B-Type instructions codes (Home-made. Not standard)
  localparam BEQ          =28;
  localparam BNE          =29;
  localparam BLT          =30;
  localparam BGE          =31;
  localparam BLTU         =32;
  localparam BGEU         =33;

  // J-Type instructions codes (Home-made. Not standard)
  localparam JAL          =34;
  localparam JALR         =35;

  // U-Type instructions codes (Home-made. Not standard)
  localparam LUI          =36;
  localparam AUIPC        =37;


  /////////////////////////////////////////////////////////
  //Instruction R-type available funct3. 
  // Every param uses the suffix _FC to refer to "function"
  /////////////////////////////////////////////////////////

  //=============================
  //R type FC3 codes
  //=============================
  localparam ADD_o_SUB_FC  = 0;
  localparam SUB_FC        = 0; //Special case. Uses funct7=0x20
  localparam XOR_FC        = 4;
  localparam OR_FC         = 6;
  localparam AND_FC        = 7;
  localparam SLL_FC        = 1;
  localparam SRL_o_SRA_FC  = 5;
  localparam SRA_FC        = 5; //Special case. Uses funct7=0x20
  localparam SLT_FC        = 2;
  localparam SLTU_FC       = 3;

  //=============================
  //I type FC3 codes
  //=============================
  localparam ADDI_FC       =0; //Start of I
  localparam XORI_FC       =4;
  localparam ORI_FC        =6;
  localparam ANDI_FC       =7;
  localparam SLLI_FC       =1; //Uses IMM=0x00
  localparam SRLI_FC       =5; //Uses IMM=0x00
  localparam SRAI_FC       =5; //Special case only if IMM= 0x20
  localparam SLTI_FC       =2;
  localparam SLTIU_FC      =3;

  //=============================
  //I-L(load) type FC3 codes
  //=============================
  localparam LB_FC         =0;         //Start of I-Load
  localparam LH_FC         =1;
  localparam LW_FC         =2;
  localparam LBU_FC        =4;
  localparam LHU_FC        =5;

  //=============================
  //S type FC3 codes
  //=============================
  localparam SB_FC         =0;         //Start of I-Load
  localparam SH_FC         =1;
  localparam SW_FC         =2;

  //=============================
  //S-B type FC3 codes
  //=============================
  localparam BEQ_FC        =0;
  localparam BNE_FC        =1;
  localparam BLT_FC        =4;
  localparam BGE_FC        =5;
  localparam BLTU_FC       =6;
  localparam BGEU_FC       =7;

  //=============================
  //J type FC3 codes
  //=============================
  localparam JAL_FC        =0; //In the spec is not defined
  localparam JALR_C        =0;

  //=============================
  //U type FC3 codes
  //=============================
  localparam LUI_FC        =0; //In the spec is not defined
  localparam AUIPC_FC      =0; //In the spec is not defined

  /////////////////////////////////////////////////////////
  //Instruction available funct7. 
  // This field is mostly used to distinguish if functions
  // use the same fct3 for example: ADD-SUB, SRL-SRA.
  /////////////////////////////////////////////////////////  

  //=============================
  // FC7 codes
  //=============================
  localparam h00_FC7		=7'h00;
  localparam h20_FC7		=7'h20;

endpackage
