class funct_coverage extends uvm_component;
    `uvm_component_utils(funct_coverage)

    logic [9:0]         fct7_fct3_conct;
    virtual intf_mon2   intf2;
  
    int num_bins;
    int cov_bins;

    // So my plan is make a coverpoint for both signed and unsigned reg1 and imm values, cross them and assign wieght = 0 
    // to unwanted coverpoints

    covergroup cov_R;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint instruction for variable fct7_fct3_conct. Create bins called "instructions"
        // that count if value is between the range or if it takes the special values for SUB
        // or SRA.
        cvr_instr : coverpoint fct7_fct3_conct {bins instructions[] = { [ADD_CVRG_ID:AND_CVRG_ID], SUB_CVRG_ID, SRA_CVRG_ID }; } 
        // Coverpoint register source 1. Check which value does rs1 take.
        cvr_rs1 : coverpoint intf2.XIDATA[18:15] {bins rx_rs1[] = { [0:31] }; }
        // Coverpoint register source 2. Check which value does rs2 take.
        cvr_rs2 : coverpoint {intf2.XIDATA[19:15],intf2.XIDATA[19:15]} {bins rx_rs2[] = { [0:31] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins         rx_rd[] = { [1:31] }; 
                                                illegal_bins il_rx_rd = { 0 };       }                             
    endgroup 


    
    covergroup cov_I;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint Funct3 and Funct7
        cvr_instr : coverpoint fct7_fct3_conct {bins instructions[] = { [ADDI_CVRG_ID:ANDI_CVRG_ID], SRAI_CVRG_ID }; } 
        // Coverpoint register source 1 pointer. 
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rs1_p[] = { [0:31] }; }
        // Coverpoint register source 1 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs1_value_un : coverpoint intf2.U1REG {bins rs1_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 1 value signed. max_v = 2^{31}-1 = 2147483647
        cvr_rs1_value_sig : coverpoint intf2.S1REG {bins rs1_val_sig[7] = { [-2147483648:2147483647] }; } 
        // imm -> xidata [11:0] 12 bit 
        // Coverpoint imm_val_unsigned. max_v = 2^{12}-1 = 4095
        cvr_imm_un : coverpoint intf2.XUIMM {bins imm_ext_un[7] = { [0:4095] }; } 
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint intf2.XSIMM {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
                
        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
               
        cross_instr_imm_sig : cross cvr_instr, cvr_imm_sig {
            ignore_bins SLTIU_and_imm_sig = binsof(cvr_instr) intersect {SLTIU_CVRG_ID} &&
                                            binsof(cvr_imm_sig) intersect {[-2048:2047]};}        
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
        cvr_imm_sig : coverpoint intf2.XSIMM {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
                
        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
                  
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
        cvr_rs1_value_sig : coverpoint intf2.S1REG {bins rs1_val_sig[7] = { [-2147483648:2147483647] }; }
        // Coverpoint register source 2 value unsigned. max_v = 2^{32}-1 = 4294967295
        cvr_rs2_value_un : coverpoint intf2.U2REG {bins rs2_val_un[7] = { [0:4294967295] }; }
        // Coverpoint register source 2 value signed. max_v = 2^{31}-1 = 2147483647
        cvr_rs2_value_sig : coverpoint intf2.S2REG {bins rs2_val_sig[7] = { [-2147483648:2147483647] }; }
        // imm -> xidata [11:0] 12 bit 
        // Coverpoint imm_val_unsigned. max_v = 2^{12}-1 = 4095
        cvr_imm_un : coverpoint intf2.XUIMM {bins imm_ext_un[7] = { [0:4095] }; } 
        // Coverpoint imm_val_signed. // Sign: [-2048:2047], max_v = 2^{11}-1 = 2047
        cvr_imm_sig : coverpoint intf2.XSIMM {bins imm_ext_sig[7] = { [-2048:2047] }; }                                                                      
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        //cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[] = { [0:511] };  }  

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)
        
    endgroup 

    covergroup cov_U;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint OPCODE
        cvr_instr : coverpoint intf2.XIDATA[6:0] {bins instructions[] = {LUI_TYPE, AUIPC_TYPE}; } 
        // Coverpoint imm_val_signed. // max_val = 2^{31}-1-2^{12}-1 = 2147479550
        cvr_imm_sig : coverpoint intf2.XSIMM {bins imm_ext_sig[7] = { [4096:2147479549], [-2147479550:-4096], 0}; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        //cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[] = { [0:511] };  }  

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)

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
        // Coverpoint register source 1 value signed. // Sign: [-2048:2047]
        cvr_rs1_value_sig : coverpoint intf2.S1REG {bins rs1_val_sig[7] = { [-2147483648:2147483647] }; }
        // Coverpoint imm_val_signed. // 2^{21}-1-1=2097150
        cvr_imm_sig : coverpoint intf2.XSIMM {bins imm_ext_sig[7] = { [-2097150:2097149] }; }                                                                       
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins  rx_rd[] = { [0:31] };  }  
        // Coverpoint PC Value
        //cvr_pc  : coverpoint intf2.NXPC {bins  pc_val[] = { [0:511] };  }  

        //todo: make cross more especific (make especial corsses or weight = 0 for especific ones)

    endgroup 

    function new (string name = "funct_coverage", uvm_component parent = null);
        super.new (name, parent);
        cov_R = new();
        cov_I = new();
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
            if (intf2.XIDATA[6:0]==R_TYPE)begin
                cov_R.sample(); //TODO: Recomended to add here a print to check what data is processed to compare it against the coverage results.
            end else if (intf2.XIDATA[6:0]==I_TYPE) begin
                cov_I.sample();
            end
        end
        end
    endtask

    
    virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
        //Report Coverage
        `uvm_info("Coverage I type Report",
        $sformatf("\n\n--------------Coverage I type instructions results-------------------\ncov_I Overall: %3.2f%% coverage achieved\ncov_I instruction type: %3.2f%% coverage achieved.\ncov_I rd registers: %3.2f%% coverage achieved.\ncov_I rs1 registers: %3.2f%% coverage achieved.\ncov_I rs1 value un: %3.2f%% coverage achieved.\ncov_I rs1 value sig: %3.2f%% coverage achieved.\ncov_I imm value un: %3.2f%% coverage achieved.\ncov_I imm value sig: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",cov_I.get_coverage(),cov_I.cvr_instr.get_coverage(),cov_I.cvr_rd.get_coverage(),cov_I.cvr_rs1.get_coverage(),cov_I.cvr_rs1_value_un.get_coverage(),cov_I.cvr_rs1_value_sig.get_coverage(), cov_I.cvr_imm_un.get_coverage(),cov_I.cvr_imm_sig.get_coverage()),UVM_MEDIUM);
        $display("Cross Coverage for inst_x_imm_sig: %0d%%", cov_I.cross_instr_imm_sig.get_coverage(cov_bins,num_bins));
        $display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);
        
        //$display("Coverage for ADDI_CVRG_ID: %0d%%", cov_I.cvr_instr.get_coverage(cov_bins,num_bins));
        //$display("Covered bins: %d, Total bins: %d", cov_bins, num_bins);
    endfunction
    
endclass