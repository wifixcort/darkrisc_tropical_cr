`include "../src/config.vh"
class mem_driver;

    //====================================================================
    //========================= Metodos ==================================
    //====================================================================
    reg [31:0] MEM2 [0:2**`MLEN/4-1]; // ro memory 
  
    // Load values from .mem file
    task mem_load();
      $readmemh("../src/darksocv2.mem", MEM2,0); //Esto simula que el estímulo nos creó el arreglo.
      $writememh("../src/darksocv.mem", MEM2);
      $readmemh("../src/darksocv.mem", top.soc0.MEM,0);      
    endtask
  
endclass 

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/