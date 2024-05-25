`include "../darkriscv/rtl/config.vh"
class driver;
  stimulus sti;
  virtual intf_soc intf;
  
  function new(virtual intf_soc in_intf, stimulus in_sti);
        this.sti  = in_sti;
        this.intf = in_intf;
  endfunction
  
  //====================================================================
  //========================= Methods ==================================
  //====================================================================

  // Load values from .mem file
  function mem_load();
    $display("\n******************************************************************************************");
    $display("driver: Invoked mem_loadt() -> load MEM to SoC");
    $display("******************************************************************************************");
    sti.mem_generate();
    sti.set_program_format();
    sti.opt_addr();
    sti.print_mem();
    $writememh("darksocv.mem", sti.MEM);
    $readmemh("darksocv.mem", top.soc0.MEM,0);      
  endfunction

  task reset(); 
    $display("\n******************************************************************************************");
    $display("driver: Invoked reset() -> send RESET signal to SoC");
    $display("******************************************************************************************");
    //$display("Executing Reset\n");
    intf.rst = 0;
    intf.uart_rx = 0;
    intf.uart_tx = 0;
    intf.rst = 1;
    @ (negedge intf.clk);
    intf.rst = 0;
  endtask
  
endclass 

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/
