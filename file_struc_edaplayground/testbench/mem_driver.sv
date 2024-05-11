`include "../src/config.vh"
class mem_driver;

    //====================================================================
    //========================= Metodos ==================================
    //====================================================================
    stimulus sti;
  
  function new(stimulus sti);
        this.sti = sti;
    endfunction
  
    // Load values from .mem file
    task mem_load();
      #2
      $writememh("darksocv.mem", this.sti.MEM);
      $readmemh("darksocv.mem", top.soc0.MEM,0);      
    endtask
  
endclass 

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/
