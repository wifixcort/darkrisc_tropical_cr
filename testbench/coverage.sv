class funct_coverage extends uvm_component;
    `uvm_component_utils(funct_coverage)

    logic [9:0]         fct7_fct3_conct;
    virtual intf_mon2   intf2;
  
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
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rx_rs1[] = { [0:31] }; }
        // Coverpoint register source 2. Check which value does rs2 take.
        cvr_rs2 : coverpoint intf2.XIDATA[24:20] {bins rx_rs2[] = { [0:31] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins         rx_rd[] = { [0:31] };} // illegal_bins il_rx_rd = { 0 }; // 0 is not ilegal but save a value in that directions is
        //Make an asertion to avoid save values in rd[0]
        cvrx_ints_rs1: cross cvr_instr , cvr_rs1;
        cvrx_ints_rs2: cross cvr_instr , cvr_rs2;
        cvrx_ints_rd: cross cvr_instr , cvr_rd;

    endgroup

    covergroup cov_R_SLL;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_sll_values : coverpoint intf2.S1REG[31:0] {
            bins rs1_pos_shift[3] = {[0:2147483647]};
            bins rs1_neg_shift[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos(shift)
        covr_rs2_sll_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift[] = {[0:31]};}
    endgroup
    covergroup cov_R_SRA;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_sra_values : coverpoint intf2.S1REG[31:0] {
            bins rs1_pos_shift_arti[3] = {[0:2147483647]};
            bins rs1_neg_shift_arti[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos aritmético(shift)
        covr_rs2_sra_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift_arit[] = {[0:31]};}
    endgroup
    covergroup cov_R_SRL;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_srl_values : coverpoint intf2.S1REG[31:0] {
            bins rs1_pos_shift_logic[3] = {[0:2147483647]};
            bins rs1_neg_shift_logic[3] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se pruebas todos los posibles corrimientos lógico(shift)
        covr_rs2_srl_shift  : coverpoint intf2.S2REG[4:0] {bins rs2_shift_logic[] = {[0:31]};}
    endgroup
    covergroup cov_R_SLT;
        // Toma el valor de rs1 y determina si se cubre valor negativo y valor positivo
        cvr_rs1_slt_values : coverpoint intf2.S1REG[31:0] {
            bins rs1_pos_values[2] = {[0:2147483647]};
            bins rs1_neg_values[2] = {[-2147483648:-1]};
        }
        // Toma el valor de rs2 y determina si se cubre valor negativo y valor positivo
        cvr_rs2_slt_values : coverpoint intf2.S2REG[31:0] {
            bins rs2_pos_values[2] = {[0:2147483647]};
            bins rs2_neg_values[2] = {[-2147483648:-1]};
        }
        //Hacer un cruce entre valores positivos y negativos de rs1 y rs2
        cvrx_slt_rs1_rs2 : cross cvr_rs1_slt_values, cvr_rs2_slt_values;
    endgroup
    //''''''''''''''''''''''''''''''''''''''''''
    // I-Load Instructions covergroup
    //''''''''''''''''''''''''''''''''''''''''''
    covergroup cov_Load;
        //''''''''''''''''''''''''''''''''''''''''''
        // Essential coverpoints
        //''''''''''''''''''''''''''''''''''''''''''
        // Coverpoint instruction for variable fct7_fct3_conct. Create bins called "instructions"
        // that count if value is between the range or if it takes the special values for SUB
        // or SRA.
        cvr_instr : coverpoint intf2.XIDATA[14:12] {bins instructions[] = { [LB_FC:LHU_FC] }; } 
        // Coverpoint register source 1. Check which value does rs1 take.
        cvr_rs1 : coverpoint intf2.XIDATA[19:15] {bins rx_rs1[] = { [0:31] }; }
        // Coverpoint register source 2. Check which value does rs2 take.
        // cvr_rs2 : coverpoint intf2.XIDATA[24:20] {bins rx_rs2[] = { [0:31] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins         rx_rd[] = { [0:31] };} // illegal_bins il_rx_rd = { 0 }; // 0 is not ilegal but save a value in that directions is
        //Make an asertion to avoid save values in rd[0]
    endgroup

    function new (string name = "funct_coverage", uvm_component parent = null);
        super.new (name, parent);
        cov_R = new();
        cov_R_SLL = new();
        cov_R_SRA = new();
        cov_R_SRL = new();
        cov_R_SLT = new();
        //cov1 = new();
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
                // reg_cero assert property(top.soc0.core0.REGS[0] == '0) else $fatal("Error: REGS[0] value modified!");
                uvm_report_info(get_full_name(), $sformatf("\n Covergroup R sampled instruction %h the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h ", intf2.XIDATA, intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                
                if(intf2.XIDATA[14:12]==SLL_FC)begin
                    cov_R_SLL.sample();
                end else if({intf2.XIDATA[31:25], intf2.XIDATA[14:12]}==9'h105)begin
                    cov_R_SRA.sample();
                end else if({intf2.XIDATA[31:25], intf2.XIDATA[14:12]}==9'h005)begin
                    cov_R_SRL.sample();
                end else if(intf2.XIDATA[14:12]==SLT_FC)begin
                    cov_R_SLT.sample();
                end
            end
        end
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        //Report coverage
        `uvm_info("Coverage R type Report", 
        $sformatf("\n\n--------------Coverage R type instructions results-------------------\ncov_R Overall: %3.2f%% coverage achieved\ncov_R instruction type: %3.2f%% coverage achieved.\ncov_R rd registers: %3.2f%% coverage achieved.\ncov_R rs1 registers: %3.2f%% coverage achieved.\ncov_R rs2 registers: %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rs1: %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rs2: %3.2f%% coverage achieved.\ncov_R Cross Instrucction X rd: %3.2f%% coverage achieved.\n---------------------------------------------------------------------\n",
                  cov_R.get_coverage(),cov_R.cvr_instr.get_coverage(),cov_R.cvr_rd.get_coverage(),cov_R.cvr_rs1.get_coverage(),cov_R.cvr_rs2.get_coverage(), cov_R.cvrx_ints_rs1.get_coverage(), cov_R.cvrx_ints_rs2.get_coverage(), cov_R.cvrx_ints_rd.get_coverage()),UVM_MEDIUM);
        `uvm_info("SLL coverage", $sformatf("\n\nSLL : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SLL.get_coverage(), cov_R_SLL.cvr_rs1_sll_values.get_coverage(),cov_R_SLL.covr_rs2_sll_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SRA coverage", $sformatf("\n\nSRA : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SRA.get_coverage(), cov_R_SRA.cvr_rs1_sra_values.get_coverage(),cov_R_SRA.covr_rs2_sra_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SRL coverage", $sformatf("\n\nSRL : %3.2f%% coverage achieved\n rs1 shift : %3.2f%% coverage achieved\n rs2 5 LSB : %3.2f%% coverage achieved\n", 
                  cov_R_SRL.get_coverage(), cov_R_SRL.cvr_rs1_srl_values.get_coverage(),cov_R_SRL.covr_rs2_srl_shift.get_coverage()), UVM_MEDIUM);
        `uvm_info("SLT coverage", $sformatf("\n\nSLT : %3.2f%% coverage achieved\n rs1 : %3.2f%% coverage achieved\n rs2 : %3.2f%% coverage achieved\n Cross cov rs1 x rs2 : %3.2f%% coverage achieved\n", 
                  cov_R_SLT.get_coverage(), cov_R_SLT.cvr_rs1_slt_values.get_coverage(),cov_R_SLT.cvr_rs2_slt_values.get_coverage(), cov_R_SLT.cvrx_slt_rs1_rs2.get_coverage()), UVM_MEDIUM);
    endfunction

endclass