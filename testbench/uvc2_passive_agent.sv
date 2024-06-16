class darksocv_agent_passive extends uvm_agent;
   `uvm_component_utils(darksocv_agent_passive)

   uvc2_mon monitor2;
   extern function new(string name="darksocv_agent_passive", uvm_component parent=null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
   
endclass: darksocv_agent_passive

function darksocv_agent_passive::new(string name="darksocv_agent_passive", uvm_component parent=null);
   super.new(name, parent);
endfunction



function void darksocv_agent_passive::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(get_is_active() == UVM_PASSIVE) begin
      monitor2 = uvc2_mon::type_id::create("monitor2", this);
      `uvm_info(get_full_name(), "This is Passive agent", UVM_LOW);
   end

endfunction

function void darksocv_agent_passive::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_report_info(get_full_name(),"Passive agent connect phase", UVM_LOW);
   //   drv.seq_item_port.connect(seqr.seq_item_export);
endfunction

// virtual task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     uvm_report_info(get_full_name(),"Passive agent run phase", UVM_LOW);
// endtask
