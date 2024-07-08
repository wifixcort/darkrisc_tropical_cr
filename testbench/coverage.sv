class funct_coverage extends uvm_component;
    `uvm_component_utils(funct_coverage)

    logic [9:0]         fct7_fct3_conct;
    virtual intf_mon2   intf2;
  
    covergroup cov_R;
                        
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
            end
        end
        end
    endtask




endclass