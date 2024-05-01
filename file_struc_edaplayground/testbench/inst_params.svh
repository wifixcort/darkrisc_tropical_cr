localparam R_TYPE   = 7'b01100_11;
localparam I_TYPE   = 7'b00100_11;
localparam I_L_TYPE = 7'b00000_11;

localparam OPCODE_SIZE = 7;

/////////////////////////////////////////////////////////
//Instruction codification
// These codes represent the instruction that the monitor
// decodifies, so the client receives a number and can 
// use a simple case to assign or take decisions.
/////////////////////////////////////////////////////////

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

localparam ADDI         =11;       //Start of I
localparam XORI         =12;
localparam ORI          =13;
localparam ANDI         =14;
localparam SLLI         =15;
localparam SRLI         =16;
localparam SRAI         =17;
localparam SLTI         =18;
localparam SLTIU        =19;
localparam LB           =20;         //Start of I-Load
localparam LH           =21;
localparam LW           =22;
localparam LBU          =23;
localparam LHU          =24;

localparam ADDI         =25;       //Start of I
localparam XORI         =26;
localparam ORI          =27;
localparam ANDI         =28;
localparam SLLI         =29;
localparam SRLI         =30;
localparam SRAI         =31;
localparam SLTI         =32;
localparam SLTIU        =33;
localparam LB           =34;         //Start of I-Load
localparam LH           =35;
localparam LW           =36;
localparam LBU          =37;
localparam LHU          =38;

/////////////////////////////////////////////////////////
//Instruction R-type available funct3
/////////////////////////////////////////////////////////

localparam ADD_o_SUB_FC  = 0;
// localparam SUB_FC     = 0;
localparam XOR_FC        = 4;
localparam OR_FC         = 6;
localparam AND_FC        = 7;
localparam SLL_FC        = 1;
localparam SRL_o_SRA_FC  = 5;
// localparam SRA_FC     = 5; 
localparam SLT_FC        = 2;  
localparam SLTU_FC       = 3;