class sequencer extends uvm_sequencer #(sequence_item_rv32i_instruction);
    `uvm_component_utils(sequencer)
  
    function new(string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);        
    endfunction   

endclass