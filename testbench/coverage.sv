class funct_coverage extends uvm_component;
    `uvm_component_utils(funct_coverage)

    logic [9:0]         fct7_fct3_conct;
    virtual intf_mon2   intf2;
  
    int num_bins;
    int cov_bins;
   
    //''''''''''''''''''''''''''''''''''''''''''
    // R Instructions covergroup
    //''''''''''''''''''''''''''''''''''''''''''
    covergroup cov_R;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint instruction for variable fct7_fct3_conct. Create bins called "instructions"
        // that count if value is between the range or if it takes the special values for SUB
        // or SRA.
        cvr_instr : coverpoint fct7_fct3_conct {bins instructions[] = { [ADD_CVRG_ID:AND_CVRG_ID], SUB_CVRG_ID, SRA_CVRG_ID }; } 
        // Coverpoint register source 1. Check which value does rs1 take.
        cvr_rs1 : coverpoint intf2.S1PTR {bins rx_rs1[] = { [0:31] }; }
        // Coverpoint register source 2. Check which value does rs2 take.
        cvr_rs2 : coverpoint intf2.S2PTR {bins rx_rs2[] = { [0:31] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.DPTR {bins         rx_rd[] = { [0:31] };} // illegal_bins il_rx_rd = { 0 }; // 0 is not ilegal but save a value in that directions is
        //Make an asertion to avoid save values in rd[0]
        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rs2: cross cvr_instr , cvr_rs2; // Instrucción X reg fuente 2
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino

    endgroup

    covergroup cov_R_SLL;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_sll_values : coverpoint $signed(intf2.S1REG[31:0]) {
            bins rs1_pos_shift[3] = {[0:2147483647]};
            bins rs1_neg_shift[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos(shift)
        covr_rs2_sll_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift[] = {[0:31]};}
    endgroup
    covergroup cov_R_SRA;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_sra_values : coverpoint $signed(intf2.S1REG[31:0]) {
            bins rs1_pos_shift_arti[3] = {[0:2147483647]};
            bins rs1_neg_shift_arti[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos aritmético(shift)
        covr_rs2_sra_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift_arit[] = {[0:31]};}
    endgroup
    covergroup cov_R_SRL;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_srl_values : coverpoint $signed(intf2.S1REG[31:0]) {
            bins rs1_pos_shift_logic[3] = {[0:2147483647]};
            bins rs1_neg_shift_logic[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos lógico(shift)
        covr_rs2_srl_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift_logic[] = {[0:31]};}
    endgroup
    covergroup cov_R_SLT;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_slt_values : coverpoint $signed(intf2.S1REG[31:0]) {
            bins rs1_pos_values[2] = {[0:2147483647]};
            bins rs1_neg_values[2] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se cubre valor negativo y valor positivo
        cvr_rs2_slt_values : coverpoint $signed(intf2.S2REG[31:0]) {
            bins rs2_pos_values[2] = {[0:2147483647]};
            bins rs2_neg_values[2] = {[-2147483648:-1]};
        }
        //Hacer un cruce entre valores positivos y negativos de rs1 y rs2
        cvrx_slt_rs1_rs2 : cross cvr_rs1_slt_values, cvr_rs2_slt_values;
    endgroup

    covergroup cov_R_SLTU;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_sltu_values : coverpoint $unsigned(intf2.U1REG[31:0]) {
            bins rs1_pos_values[2] = {[0:2147483647]};
            // bins rs1_neg_values[2] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se cubre valor negativo y valor positivo
        cvr_rs2_sltu_values : coverpoint $unsigned(intf2.U2REG[31:0]) {
            bins rs2_pos_values[2] = {[0:2147483647]};
            // bins rs2_neg_values[2] = {[-2147483648:-1]};
        }
        //Hacer un cruce entre valores positivos y negativos de rs1 y rs2
        cvrx_sltu_rs1_rs2 : cross cvr_rs1_sltu_values, cvr_rs2_sltu_values;
    endgroup

    covergroup cov_R_SUB;
        // Toma el valor de rs2 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_ssub_values : coverpoint $signed(intf2.S2REG[31:0]) {
            bins rs1_pos_shift_logic[3] = {[0:2147483647]};
            bins rs1_neg_shift_logic[3] = {[-2147483648:-1]};
        }
    endgroup    
    
    covergroup cov_I;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint Funct3 and Funct7
        cvr_instr : coverpoint fct7_fct3_conct {bins instructions[] = { [ADDI_CVRG_ID:ANDI_CVRG_ID], SRAI_CVRG_ID }; } 
        cvr_addi : coverpoint fct7_fct3_conct {bins instructions[] = { ADDI_CVRG_ID}; } 
        // Coverpoint register source 1 pointer. 
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rs1_p[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 1 value signed. max_v = 2^{31}-1 = 2147483647
        cvr_rs1_value_sig : coverpoint $signed(intf2.S1REG) {bins rs1_val_sig[7] = { [-2147483648:2147483647] }; } 
        // imm -> xidata [11:0] 12 bit 
        // Coverpoint imm_val_unsigned. max_v = 2^{12}-1 = 4095
        cvr_imm_un : coverpoint intf2.XUIMM {bins imm_ext_un[7] = { [0:4095] }; } 
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
                
        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        
        cross_instr_imm_sig_rs1_sig : cross cvr_instr, cvr_rs1_value_sig, cvr_imm_sig {
            bins SLTI_imm_sig_rs1_sig =  binsof(cvr_instr) intersect {SLTI_CVRG_ID} &&
                                         binsof(cvr_rs1_value_sig) intersect {[-2147483648:2147483647]} &&
                                         binsof(cvr_imm_sig) intersect {[-2048:2047]};
            
            bins SRAI_imm_sig_rs1_sig =  binsof(cvr_instr) intersect {SRAI_CVRG_ID} &&
                                         binsof(cvr_rs1_value_sig) intersect {[-2147483648:2147483647]} &&
                                         binsof(cvr_imm_sig) intersect {[-2048:2047]};
        }
        cross_instr_imm_un_rs1_sig : cross cvr_instr, cvr_rs1_value_sig, cvr_imm_un{
            bins SLLI_imm_un_rs1_sig =  binsof(cvr_instr) intersect {SLL_CVRG_ID} &&
                                        binsof(cvr_rs1_value_sig) intersect {[-2147483648:2147483647]} &&
                                        binsof(cvr_imm_un) intersect {[0:4095]};

            bins SRLI_imm_un_rs1_sig =  binsof(cvr_instr) intersect {SRL_CVRG_ID} &&
                                        binsof(cvr_rs1_value_sig) intersect {[-2147483648:2147483647]} &&
                                        binsof(cvr_imm_un) intersect {[0:4095]};
        }
        cross_instr_imm_un_rs1_un : cross cvr_instr, cvr_rs1_value_un, cvr_imm_un{
            bins SLTIU_imm_un_rs1_un =  binsof(cvr_instr) intersect {SLTIU_CVRG_ID} &&
                                        binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                        binsof(cvr_imm_un) intersect {[0:4095]}; 
        }
        cross_instr_imm_sig_rs1_un : cross cvr_instr, cvr_rs1_value_un, cvr_imm_sig{
            bins ADDI_imm_un_rs1_un =   binsof(cvr_instr) intersect {ADDI_CVRG_ID} &&
                                        binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                        binsof(cvr_imm_sig) intersect {[-2048:2047]} ;

            bins ANDI_imm_un_rs1_un =   binsof(cvr_instr) intersect {ANDI_CVRG_ID} &&
                                        binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                        binsof(cvr_imm_sig) intersect {[-2048:2047]} ;

            bins ORI_imm_un_rs1_un =   binsof(cvr_instr) intersect {ORI_CVRG_ID} &&
                                        binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                        binsof(cvr_imm_sig) intersect {[-2048:2047]} ;

            bins XORI_imm_un_rs1_un =   binsof(cvr_instr) intersect {XORI_CVRG_ID} &&
                                        binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                        binsof(cvr_imm_sig) intersect {[-2048:2047]} ;                            
        }
    endgroup 

    //''''''''''''''''''''''''''''''''''''''''''
    // I-Load Instructions covergroup
    //''''''''''''''''''''''''''''''''''''''''''
    covergroup cov_Load;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        cvr_instr : coverpoint intf2.XIDATA[14:12] {bins instructions[] = { [LB_FC:LHU_FC] }; } 
        // Coverpoint register source 1. Check which value does rs1 take.
        cvr_rs1 : coverpoint intf2.S1PTR {bins rx_rs1[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [-2048:2047] }; }
        // Coverpoint DATAI
        cvr_datai : coverpoint intf2.DATAI {bins datai[7] = { [0:4294967295] }; } 
        // Coverpoint LDATA
        cvr_ldata : coverpoint intf2.LDATA {bins ldata[7] = { [0:4294967295] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.DPTR {bins rx_rd[] = { [0:31] }; }
        // Coverpoint DADDR, DMEMORY [512:1023]

        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        cross_instr_datai : cross cvr_instr, cvr_datai {
            bins LB_and_datai = binsof(cvr_instr) intersect {LB_FC} &&
                                  binsof(cvr_datai) intersect {[0:4294967295]};   

            bins LH_and_datai =  binsof(cvr_instr) intersect {LH_FC} &&
                                   binsof(cvr_datai) intersect {[0:4294967295]};

            bins LBU_and_datai = binsof(cvr_instr) intersect {LBU_FC} &&
                                  binsof(cvr_datai) intersect {[0:4294967295]};   

            bins LHU_and_datai =  binsof(cvr_instr) intersect {LHU_FC} &&
                                   binsof(cvr_datai) intersect {[0:4294967295]};

            bins LW_and_datai =  binsof(cvr_instr) intersect {LW_FC} &&
                                   binsof(cvr_datai) intersect {[0:4294967295]};
        } 
        // DADDR
        cross_imm_sig_rs1_un : cross cvr_imm_sig, cvr_rs1_value_un {
            bins imm_sig_and_rs1_sig = binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                       binsof(cvr_rs1_value_un) intersect {[0:4294967295]};   
        } 

    endgroup

    covergroup cov_S;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint Funct3
        cvr_instr : coverpoint intf2.XIDATA[14:12] {bins instructions[] = { [SB_FC:SW_FC] }; } 
        // Coverpoint register source 1 pointer. 
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rs1_p[] = { [0:31] }; }
        // Coverpoint register source 2 pointer. 
        cvr_rs2 : coverpoint intf2.XIDATA[24:20] {bins rs2_p[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 2 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs2_value_un : coverpoint intf2.U2REG {bins rs2_val_un[7] = { [0:4294967295] }; }
        // imm -> xidata [11:0] 12 bit 
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins rx_rd[] = { [0:31] };  }  
        // Coverpoint SDATA == DATAO value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_sdata : coverpoint intf2.SDATA {bins rx_rd[7] = { [0:4294967295] };  }
        // Coverpoint DADDR, DMEMORY [512:1023]      

        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rs2: cross cvr_instr , cvr_rs2; // Instrucción X reg fuente 1
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        cross_instr_imm_sig : cross cvr_instr, cvr_imm_sig {
            bins SB_and_imm_sig = binsof(cvr_instr) intersect {SB_FC} &&
                                  binsof(cvr_imm_sig) intersect {[-2048:2047]};   

            bins SH_and_imm_sig =  binsof(cvr_instr) intersect {SH_FC} &&
                                   binsof(cvr_imm_sig) intersect {[-2048:2047]};

            bins SW_and_imm_sig =  binsof(cvr_instr) intersect {SW_FC} &&
                                   binsof(cvr_imm_sig) intersect {[-2048:2047]};
        } 

        cross_instr_rs1_un : cross cvr_instr, cvr_rs1_value_un {
            bins SB_and_rs1_sig = binsof(cvr_instr) intersect {SB_FC} &&
                                  binsof(cvr_rs1_value_un) intersect {[0:4294967295]};   

            bins SH_and_rs1_sig =  binsof(cvr_instr) intersect {SH_FC} &&
                                   binsof(cvr_rs1_value_un) intersect {[0:4294967295]};

            bins SW_and_rs1_sig =  binsof(cvr_instr) intersect {SW_FC} &&
                                   binsof(cvr_rs1_value_un) intersect {[0:4294967295]};
        } 

        cross_instr_rs2_un : cross cvr_instr, cvr_rs2_value_un {
            bins SB_and_rs2_sig = binsof(cvr_instr) intersect {SB_FC} &&
                                  binsof(cvr_rs2_value_un) intersect {[0:4294967295]};   

            bins SH_and_rs2_sig =  binsof(cvr_instr) intersect {SH_FC} &&
                                   binsof(cvr_rs2_value_un) intersect {[0:4294967295]};

            bins SW_and_rs2_sig =  binsof(cvr_instr) intersect {SW_FC} &&
                                   binsof(cvr_rs2_value_un) intersect {[0:4294967295]};
        } 
        // DADDR
        cross_imm_sig_rs1_un : cross cvr_imm_sig, cvr_rs1_value_un {
            bins imm_sig_and_rs1_sig = binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                       binsof(cvr_rs1_value_un) intersect {[0:4294967295]};   
        } 

    endgroup

    covergroup cov_B;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint FTC3
        cvr_instr : coverpoint intf2.XIDATA[14:12] {bins instructions[] = { [BEQ_FC:BGEU_FC] }; } 
        // Coverpoint register source 1 pointer. 
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rs1_p[] = { [0:31] }; }
        // Coverpoint register source 2 pointer. 
        cvr_rs2 : coverpoint intf2.XIDATA[24:20] {bins rs2_p[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 1 value signed. max_v = 2^{31}-1 = 2147483647
        cvr_rs1_value_sig : coverpoint $signed(intf2.S1REG) {bins rs1_val_sig[7] = { [-2147483648:2147483647] }; }
        // Coverpoint register source 2 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs2_value_un : coverpoint intf2.U2REG {bins rs2_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 2 value signed. max_v = 2^{31}-1 = 2147483647
        cvr_rs2_value_sig : coverpoint $signed(intf2.S2REG) {bins rs2_val_sig[7] = { [-2147483648:2147483647] }; }
        // imm -> xidata [11:0] 12 bit 
        // Coverpoint imm_val_unsigned. max_v = 2^{12}-1 = 4095
        cvr_imm_un : coverpoint intf2.XUIMM {bins imm_ext_un[7] = { [0:4095] }; } 
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                      
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[10] = { [0:2044] };  }
        
        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rs2: cross cvr_instr , cvr_rs2; // Instrucción X reg fuente 1
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino        

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        cross_imm_sig_pc : cross cvr_imm_sig, cvr_pc, cvr_instr{
            bins imm_sig_and_pc = binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                  binsof(cvr_pc) intersect {[0:511]} &&
                                  binsof(cvr_instr) intersect {[BEQ_FC:BGEU_FC]};         
        }
        cross_instr_rs1_un_rs2_un : cross cvr_rs1_value_un, cvr_rs2_value_un, cvr_instr{
            bins imm_sig_and_pc = binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                  binsof(cvr_rs2_value_un) intersect {[0:4294967295]} &&
                                  binsof(cvr_instr) intersect {BEQ_FC, BLTU_FC, BNE_FC, BGEU_FC};       
        }
        cross_instr_rs1_sig_rs2_sig : cross cvr_rs1_value_sig, cvr_rs2_value_sig, cvr_instr{
            bins imm_sig_and_pc = binsof(cvr_rs1_value_sig) intersect {[-2147483648:2147483647]} &&
                                  binsof(cvr_rs2_value_sig) intersect {[-2147483648:2147483647]} &&
                                  binsof(cvr_instr) intersect {BGE_FC, BLT_FC};       
        }
    endgroup 

    covergroup cov_U;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint OPCODE
        cvr_instr : coverpoint intf2.XIDATA[6:0] {bins instructions[] = {LUI_TYPE, AUIPC_TYPE}; } 
        // Coverpoint imm_val_signed. // max_val = 2^{31}-1-2^{12}-1 = 2147479550
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [4096:2147479549], [-2147479550:-4096], 0}; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[10] = { [0:2044] };  }  

        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino 

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        cross_imm_sig_pc : cross cvr_imm_sig, cvr_pc, cvr_instr{
            bins imm_sig_and_pc = binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                  binsof(cvr_pc) intersect {[0:2044]} &&
                                  binsof(cvr_instr) intersect {AUIPC_TYPE};   
        } 

    endgroup

    covergroup cov_J;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint OPCODE
        cvr_instr : coverpoint intf2.XIDATA[6:0] {bins instructions[] = {J_TYPE, I_JALR_TYPE}; } 
        // Coverpoint register source 1 pointer. 
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rs1_p[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. 
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint imm_val_signed. // 2^{21}-1-1=2097150
        cvr_imm_sig : coverpoint $signed(intf2.XSIMM) {bins imm_ext_sig[7] = { [-2097150:2097149] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[10] = { [0:2044] };  }  

        cvrx_ints_rs1: cross cvr_instr , cvr_rs1; // Instrucción X reg fuente 1
        cvrx_ints_rd: cross cvr_instr , cvr_rd;   // Instrucción X reg destino 

        // todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        cross_imm_sig_pc : cross cvr_imm_sig, cvr_pc, cvr_instr{
            bins imm_sig_and_pc = binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                  binsof(cvr_pc) intersect {[0:2044]} &&
                                  binsof(cvr_instr) intersect {J_TYPE};   
        } 
        cross_imm_rs1_un : cross cvr_imm_sig, cvr_rs1_value_un, cvr_instr{
            bins imm_sig_and_rs1_un = binsof(cvr_rs1_value_un) intersect {[0:4294967295]} &&
                                      binsof(cvr_imm_sig) intersect {[-2048:2047]} &&
                                      binsof(cvr_instr) intersect {I_JALR_TYPE};   
        } 
    endgroup 

    covergroup cov_transition;
        // Coverpoint for current instruction type
        cvr_current_instr : coverpoint intf2.XIDATA[6:0] {
            bins current_instr_bins[] = {R_TYPE, I_TYPE, I_L_TYPE, S_TYPE, S_B_TYPE, J_TYPE, I_JALR_TYPE, LUI_TYPE, AUIPC_TYPE};

            // R-type to other type except L, S, B, J
            bins t_R_to_R          = (R_TYPE => R_TYPE);
            bins t_R_to_I          = (R_TYPE => I_TYPE);  
            bins t_R_to_I_LUI      = (R_TYPE => LUI_TYPE);
            bins t_R_to_AUIPC      = (R_TYPE => AUIPC_TYPE);

            // I-type to other type except L, S, B, J
            bins t_I_to_I          = (I_TYPE => I_TYPE);
            bins t_I_to_R          = (I_TYPE => R_TYPE);
            bins t_I_to_LUI        = (I_TYPE => LUI_TYPE);
            bins t_I_to_AUIPC      = (I_TYPE => AUIPC_TYPE);

            // LUI-type to other type except L, S, B, J
            bins t_LUI_to_LUI      = (LUI_TYPE => LUI_TYPE);
            bins t_LUI_to_R        = (LUI_TYPE => R_TYPE);
            bins t_LUI_to_I        = (LUI_TYPE => I_TYPE);
            bins t_LUI_to_AUIPC    = (LUI_TYPE => AUIPC_TYPE);

            // AUIPC-type to other type except L, S, B, J
            bins t_AUIPC_to_AUIPC  = (AUIPC_TYPE => AUIPC_TYPE);
            bins t_AUIPC_to_R      = (AUIPC_TYPE => R_TYPE);
            bins t_AUIPC_to_I      = (AUIPC_TYPE => I_TYPE);
            bins t_AUIPC_to_LUI    = (AUIPC_TYPE => LUI_TYPE);

            // Simulation takes into account, cases that dont break rtl, 
            // so only the following transitions are valid when L, S, B, J
            // are taken into account.

            // L transitions
            bins t_I_to_I_L        = (I_TYPE => I_L_TYPE);
            bins t_I_L_to_I        = (I_L_TYPE => I_TYPE);

            // B transitions 
            bins t_I_to_S_B        = (I_TYPE => S_B_TYPE);
            bins t_S_B_to_I        = (S_B_TYPE => I_TYPE);

            // J transitions
            bins t_J_to_S_B        = (J_TYPE => S_B_TYPE);
        }
    endgroup


    function new (string name = "funct_coverage", uvm_component parent = null);
        super.new (name, parent);
        cov_R = new();
        cov_R_SLL = new();
        cov_R_SRA = new();
        cov_R_SRL = new();
        cov_R_SLT = new();
        cov_R_SLTU = new();
        cov_Load = new();
        cov_I = new();
        cov_S = new();
        cov_B = new();
        cov_U = new();
        cov_J = new();
        cov_transition = new();
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if(uvm_config_db #(virtual intf_mon2)::get(this, "", "VIRTUAL_INTERFACE_MONITOR2", intf2) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface 2 for the TB")
        end
    endfunction

    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
        fct7_fct3_conct = {intf2.XIDATA[31:25], intf2.XIDATA[14:12]}; //Concatenates {fct7, fct3}
        @(posedge intf2.clk) begin
            cov_transition.sample();
            // cov_CLK.sample(); // Clock sample postive edge
            // cov_RST.sample(); // Reset sample postive edge
            if (intf2.XIDATA[6:0]==R_TYPE)begin
                cov_R.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup R sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                
                if(intf2.XIDATA[14:12]==SLL_FC)begin
                    cov_R_SLL.sample();
                end else if({intf2.XIDATA[31:25], intf2.XIDATA[14:12]}==9'h105)begin
                    cov_R_SRA.sample();
                end else if({intf2.XIDATA[31:25], intf2.XIDATA[14:12]}==9'h005)begin
                    cov_R_SRL.sample();
                end else if(intf2.XIDATA[14:12]==SLT_FC)begin
                    cov_R_SLT.sample();
                end else if(intf2.XIDATA[14:12]==SLTU_FC)begin
                    cov_R_SLTU.sample();
                end
            end else if (intf2.XIDATA[6:0]==I_TYPE) begin
                cov_I.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup I sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end else if (intf2.XIDATA[6:0]==I_L_TYPE) begin
                cov_Load.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup L sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end else if (intf2.XIDATA[6:0]==S_TYPE) begin
                cov_S.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup S sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end else if (intf2.XIDATA[6:0]==S_B_TYPE) begin
                cov_B.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup S_B sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end else if ((intf2.XIDATA[6:0]== LUI_TYPE) || (intf2.XIDATA[6:0]== AUIPC_TYPE)) begin
                cov_U.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup U sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end else if (intf2.XIDATA[6:0]==J_TYPE) begin
                cov_J.sample();
                uvm_report_info(get_full_name(), $sformatf("\n\n Covergroup J sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h \n\n", 
                intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                   
            end
        end
 
        end
    endtask
    

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        // `uvm_info("Clock coverage", $sformatf("\n\n--------------Coverage CLK results-------------------\nCLK : %3.2f%% coverage achieved\n-----------------------------------------------------", cov_CLK.get_coverage()), UVM_MEDIUM);
        // `uvm_info("Reset coverage", $sformatf("\n\n--------------Coverage RST results-------------------\nRST : %3.2f%% coverage achieved\n-----------------------------------------------------", cov_RST.get_coverage()), UVM_MEDIUM);
        //Report coverage
        `uvm_info("Coverage R type Report", 
        $sformatf("\n\n--------------Coverage R type instructions results-------------------\ncov_R Overall:                  %3.2f%% coverage achieved\ncov_R instruction type:         %3.2f%% coverage achieved.\ncov_R rd registers:             %3.2f%% coverage achieved.\ncov_R rs1 registers:            %3.2f%% coverage achieved.\ncov_R rs2 registers:            %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rs1: %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rs2: %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rd:  %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                  cov_R.get_coverage(),cov_R.cvr_instr.get_coverage(),cov_R.cvr_rd.get_coverage(),cov_R.cvr_rs1.get_coverage(),cov_R.cvr_rs2.get_coverage(), cov_R.cvrx_ints_rs1.get_coverage(), cov_R.cvrx_ints_rs2.get_coverage(), cov_R.cvrx_ints_rd.get_coverage()),UVM_MEDIUM);
        `uvm_info("SLL coverage", $sformatf("\n\nSLL : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SLL.get_coverage(), cov_R_SLL.cvr_rs1_sll_values.get_coverage(),cov_R_SLL.covr_rs2_sll_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SRA coverage", $sformatf("\n\nSRA : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SRA.get_coverage(), cov_R_SRA.cvr_rs1_sra_values.get_coverage(),cov_R_SRA.covr_rs2_sra_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SRL coverage", $sformatf("\n\nSRL : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SRL.get_coverage(), cov_R_SRL.cvr_rs1_srl_values.get_coverage(),cov_R_SRL.covr_rs2_srl_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SLT coverage", $sformatf("\n\nSLT : %3.2f%% coverage achieved\n rs1 : %3.2f%% coverage achieved\n rs2 : %3.2f%% coverage achieved\n Cross cov rs1 x rs2 : %3.2f%% coverage achieved\n", 
                  cov_R_SLT.get_coverage(), cov_R_SLT.cvr_rs1_slt_values.get_coverage(),cov_R_SLT.cvr_rs2_slt_values.get_coverage(), cov_R_SLT.cvrx_slt_rs1_rs2.get_coverage()), UVM_MEDIUM);
        `uvm_info("SLTU coverage", $sformatf("\n\nSLTU : %3.2f%% coverage achieved\n rs1 : %3.2f%% coverage achieved\n rs2 : %3.2f%% coverage achieved\n Cross cov rs1 x rs2 : %3.2f%% coverage achieved\n", 
                  cov_R_SLTU.get_coverage(), cov_R_SLTU.cvr_rs1_sltu_values.get_coverage(),cov_R_SLTU.cvr_rs2_sltu_values.get_coverage(), cov_R_SLTU.cvrx_sltu_rs1_rs2.get_coverage()), UVM_MEDIUM);
        // `uvm_info("Coverage I type Report",
        // $sformatf("\n\n--------------Coverage I type instructions results-------------------\ncov_I Overall: %3.2f%% coverage achieved\ncov_I instruction type: %3.2f%% coverage achieved.\ncov_I rd registers: %3.2f%% coverage achieved.\ncov_I rs1 registers: %3.2f%% coverage achieved.\ncov_I rs1 value un: %3.2f%% coverage achieved.\ncov_I rs1 value sig: %3.2f%% coverage achieved.\ncov_I imm value un: %3.2f%% coverage achieved.\ncov_I imm value sig: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",cov_I.get_coverage(),cov_I.cvr_instr.get_coverage(),cov_I.cvr_rd.get_coverage(),cov_I.cvr_rs1.get_coverage(),cov_I.cvr_rs1_value_un.get_coverage(),cov_I.cvr_rs1_value_sig.get_coverage(), cov_I.cvr_imm_un.get_coverage(),cov_I.cvr_imm_sig.get_coverage()),UVM_MEDIUM);
                  `uvm_info("Coverage I type Report", 
                  $sformatf("\n\n--------------Coverage I type instructions results-------------------\ncov_I Overall:                  %3.2f%% coverage achieved\ncov_I instruction type:         %3.2f%% coverage achieved.\ncov_I addi instruction:         %3.2f%% coverage achieved.\ncov_I rs1 pointers:             %3.2f%% coverage achieved.\ncov_I rs1 values unsigned:      %3.2f%% coverage achieved.\ncov_I rs1 values signed:        %3.2f%% coverage achieved.\ncov_I imm values unsigned:      %3.2f%% coverage achieved.\ncov_I imm values signed:        %3.2f%% coverage achieved.\ncov_I rd registers:             %3.2f%% coverage achieved.\ncov_I Cross Instrucction X imm signed X rs1 signed: %3.2f%% coverage achieved.\ncov_I Cross Instrucction X imm unsigned X rs1 signed: %3.2f%% coverage achieved.\ncov_I Cross Instrucction X imm unsigned X rs1 unsigned: %3.2f%% coverage achieved.\ncov_I Cross Instrucction X imm signed X rs1 unsigned: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                            cov_I.get_coverage(), cov_I.cvr_instr.get_coverage(), cov_I.cvr_addi.get_coverage(), cov_I.cvr_rs1.get_coverage(),
                            cov_I.cvr_rs1_value_un.get_coverage(), cov_I.cvr_rs1_value_sig.get_coverage(), cov_I.cvr_imm_un.get_coverage(),
                            cov_I.cvr_imm_sig.get_coverage(), cov_I.cvr_rd.get_coverage(), cov_I.cross_instr_imm_sig_rs1_sig.get_coverage(),
                            cov_I.cross_instr_imm_un_rs1_sig.get_coverage(), cov_I.cross_instr_imm_un_rs1_un.get_coverage(), cov_I.cross_instr_imm_sig_rs1_un.get_coverage()), UVM_MEDIUM);
              `uvm_info("Coverage Load type Report", 
              $sformatf("\n\n--------------Coverage Load type instructions results-------------------\ncov_Load Overall:                  %3.2f%% coverage achieved\ncov_Load instruction type:         %3.2f%% coverage achieved.\ncov_Load rs1 registers:            %3.2f%% coverage achieved.\ncov_Load rs1 values unsigned:      %3.2f%% coverage achieved.\ncov_Load imm values signed:        %3.2f%% coverage achieved.\ncov_Load datai:                    %3.2f%% coverage achieved.\ncov_Load ldata:                    %3.2f%% coverage achieved.\ncov_Load rd registers:             %3.2f%% coverage achieved.\ncov_Load daddr:                    %3.2f%% coverage achieved.\ncov_Load Cross Instrucction X datai: %3.2f%% coverage achieved.\ncov_Load Cross imm signed X rs1 unsigned: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                        cov_Load.get_coverage(), cov_Load.cvr_instr.get_coverage(), cov_Load.cvr_rs1.get_coverage(), cov_Load.cvr_rs1_value_un.get_coverage(),
                        cov_Load.cvr_imm_sig.get_coverage(), cov_Load.cvr_datai.get_coverage(), cov_Load.cvr_ldata.get_coverage(), cov_Load.cvr_rd.get_coverage(),
                        cov_Load.cross_instr_datai.get_coverage(), cov_Load.cross_instr_datai.get_coverage(), cov_Load.cross_imm_sig_rs1_un.get_coverage(),
                        cov_Load.cross_imm_sig_rs1_un.get_coverage()), UVM_MEDIUM );      
          `uvm_info("Coverage Store type Report", 
          $sformatf("\n\n--------------Coverage Store type instructions results-------------------\ncov_S Overall:                  %3.2f%% coverage achieved\ncov_S instruction type:         %3.2f%% coverage achieved.\ncov_S rs1 registers:            %3.2f%% coverage achieved.\ncov_S rs2 registers:            %3.2f%% coverage achieved.\ncov_S rs1 values unsigned:      %3.2f%% coverage achieved.\ncov_S rs2 values unsigned:      %3.2f%% coverage achieved.\ncov_S imm values signed:        %3.2f%% coverage achieved.\ncov_S rd registers:             %3.2f%% coverage achieved.\ncov_S sdata:                    %3.2f%% coverage achieved.\ncov_S daddr:                    %3.2f%% coverage achieved.\ncov_S Cross Instrucction X imm signed: %3.2f%% coverage achieved.\ncov_S Cross Instrucction X rs1 unsigned: %3.2f%% coverage achieved.\ncov_S Cross Instrucction X rs2 unsigned: %3.2f%% coverage achieved.\ncov_S Cross imm signed X rs1 unsigned: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                    cov_S.get_coverage(), cov_S.cvr_instr.get_coverage(), cov_S.cvr_rs1.get_coverage(), cov_S.cvr_rs2.get_coverage(),
                    cov_S.cvr_rs1_value_un.get_coverage(), cov_S.cvr_rs2_value_un.get_coverage(), cov_S.cvr_imm_sig.get_coverage(),
                    cov_S.cvr_rd.get_coverage(), cov_S.cvr_sdata.get_coverage(), cov_S.cross_instr_imm_sig.get_coverage(), cov_S.cross_instr_imm_sig.get_coverage(),
                    cov_S.cross_instr_rs1_un.get_coverage(), cov_S.cross_instr_rs2_un.get_coverage(), cov_S.cross_imm_sig_rs1_un.get_coverage()), UVM_MEDIUM );                  
      `uvm_info("Coverage Branch type Report", 
      $sformatf("\n\n--------------Coverage Branch type instructions results-------------------\ncov_B Overall:                  %3.2f%% coverage achieved\ncov_B instruction type:         %3.2f%% coverage achieved.\ncov_B rs1 registers:            %3.2f%% coverage achieved.\ncov_B rs2 registers:            %3.2f%% coverage achieved.\ncov_B rs1 values unsigned:      %3.2f%% coverage achieved.\ncov_B rs1 values signed:        %3.2f%% coverage achieved.\ncov_B rs2 values unsigned:      %3.2f%% coverage achieved.\ncov_B rs2 values signed:        %3.2f%% coverage achieved.\ncov_B imm values unsigned:      %3.2f%% coverage achieved.\ncov_B imm values signed:        %3.2f%% coverage achieved.\ncov_B rd registers:             %3.2f%% coverage achieved.\ncov_B PC values:                %3.2f%% coverage achieved.\ncov_B Cross imm signed X PC:    %3.2f%% coverage achieved.\ncov_B Cross rs1 unsigned X rs2 unsigned: %3.2f%% coverage achieved.\ncov_B Cross rs1 signed X rs2 signed: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                cov_B.get_coverage(), cov_B.cvr_instr.get_coverage(), cov_B.cvr_rs1.get_coverage(), cov_B.cvr_rs2.get_coverage(),
                cov_B.cvr_rs1_value_un.get_coverage(), cov_B.cvr_rs1_value_sig.get_coverage(), cov_B.cvr_rs2_value_un.get_coverage(),
                cov_B.cvr_rs2_value_sig.get_coverage(), cov_B.cvr_imm_un.get_coverage(), cov_B.cvr_imm_sig.get_coverage(),
                cov_B.cvr_rd.get_coverage(), cov_B.cvr_pc.get_coverage(), cov_B.cross_imm_sig_pc.get_coverage(), cov_B.cross_instr_rs1_un_rs2_un.get_coverage(),
                cov_B.cross_instr_rs1_sig_rs2_sig.get_coverage()),  UVM_MEDIUM );      
  `uvm_info("Coverage U type Report", 
  $sformatf("\n\n--------------Coverage U type instructions results-------------------\ncov_U Overall:                  %3.2f%% coverage achieved\ncov_U instruction type:         %3.2f%% coverage achieved.\ncov_U imm values signed:        %3.2f%% coverage achieved.\ncov_U rd registers:             %3.2f%% coverage achieved.\ncov_U PC values:                %3.2f%% coverage achieved.\ncov_U Cross imm signed X PC:    %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
            cov_U.get_coverage(), cov_U.cvr_instr.get_coverage(), cov_U.cvr_imm_sig.get_coverage(), cov_U.cvr_rd.get_coverage(),
            cov_U.cvr_pc.get_coverage(), cov_U.cross_imm_sig_pc.get_coverage()), UVM_MEDIUM );
`uvm_info("Coverage J type Report", 
    $sformatf("\n\n--------------Coverage J type instructions results-------------------\ncov_J Overall:                  %3.2f%% coverage achieved\ncov_J instruction type:         %3.2f%% coverage achieved.\ncov_J imm values signed:        %3.2f%% coverage achieved.\ncov_J rs1 pointer:              %3.2f%% coverage achieved.\ncov_J rs1 value unsigned:       %3.2f%% coverage achieved.\ncov_J rd registers:             %3.2f%% coverage achieved.\ncov_J PC values:                %3.2f%% coverage achieved.\ncov_J Cross imm signed X PC:    %3.2f%% coverage achieved.\ncov_J Cross imm signed X rs1:   %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
              cov_J.get_coverage(), cov_J.cvr_instr.get_coverage(), cov_J.cvr_imm_sig.get_coverage(), cov_J.cvr_rs1.get_coverage(),
              cov_J.cvr_rs1_value_un.get_coverage(), cov_J.cvr_rd.get_coverage(), cov_J.cvr_pc.get_coverage(), cov_J.cross_imm_sig_pc.get_coverage(),
              cov_J.cross_imm_rs1_un.get_coverage()), UVM_MEDIUM);
`uvm_info("Coverage Transition Report",
    $sformatf("\n\n--------------Coverage Transition results-------------------\ncov_transition Overall:                  %3.2f%% coverage achieved\n---------------------------------------------------------------------\n",
              cov_transition.get_coverage()),
    UVM_MEDIUM
);

                  /*
        $display("Cross Coverage for inst_x_imm_sig: %0d%%", cov_I.cross_instr_imm_sig.get_coverage(cov_bins,num_bins));
        $display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);

        $display("Cross Coverage for cross_instr_imm_un: %0d%%", cov_I.cross_instr_imm_un.get_coverage(cov_bins,num_bins));
        $display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);
        
        $display("Cross Coverage for cross_instr_rs1_sig: %0d%%", cov_I.cross_instr_rs1_sig.get_coverage(cov_bins,num_bins));
        $display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);

        $display("Cross Coverage for cross_instr_rs1_un: %0d%%", cov_I.cross_instr_rs1_un.get_coverage(cov_bins,num_bins));
        $display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);
        */
    endfunction

endclass
