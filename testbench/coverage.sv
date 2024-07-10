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
        cvr_rs2 : coverpoint intf2.XIDATA[24:20] {bins rx_rs2[] = { [0:31] }; }
        // Coverpoint register destination. Check which value does rd take.
        cvr_rd  : coverpoint intf2.XIDATA[11:7] {bins         rx_rd[] = { [0:31] };} // illegal_bins il_rx_rd = { 0 }; // 0 is not ilegal but save a value in that directions is
        //Make an asertion to avoid save values in rd[0]
    endgroup

    function new (string name = "funct_coverage", uvm_component parent = null);
        super.new (name, parent);
        cov_R = new();
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
                uvm_report_info(get_full_name(), $sformatf("\n Covergroup R sampled the following: Function 7: %h || Function 3: %h || rs1: %h || rs2: %h || rsd: %h ", intf2.XIDATA[31:25], intf2.XIDATA[14:12], intf2.XIDATA[19:15], intf2.XIDATA[24:20], intf2.XIDATA[11:7]), UVM_LOW);                
            end
        end
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        //Report coverage
        $display("\n--------------Coverage R type instructions results-------------------");
        $display("cov_R Overall: %3.2f%% coverage achieved.",
        cov_R.get_coverage());
        $display("cov_R instruction type: %3.2f%% coverage achieved.",
        cov_R.cvr_instr.get_coverage());
        $display("cov_R rd registers: %3.2f%% coverage achieved.",
        cov_R.cvr_rd.get_coverage());
        $display("cov_R rs1 registers: %3.2f%% coverage achieved.",
        cov_R.cvr_rs1.get_coverage());
        $display("cov_R rs2 registers: %3.2f%% coverage achieved.",
        cov_R.cvr_rs2.get_coverage());
        $display("------------------------------------------------------------------------\n");
    endfunction

endclass