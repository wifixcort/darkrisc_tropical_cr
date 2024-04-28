class mem_driver;
//             reg [31:0] int_memspace [0:2**`MLEN/4-1]; //We use this memspace to hot-swap etc information.
            virtual ifc_mem mem_int;                  //(Virtual=Pointer) Output to mem to directly drive the CPU array.

    //====================================================================
    //========================= Metodos ==================================
    //====================================================================
    // Construct driver
    function new(virtual ifc_mem mem_ext);
//       
        mem_int = mem_ext;  // Local variable receives "the pointer"
    endfunction //new()
    
  
    // Reset memspace
    function mem_reset();
        for (int i=0; i!=2**`MLEN/4; i++)begin
          mem_int.memory_bus[i] = 0;       // Local variable sets 0's
        end
    endfunction

    // Load values
    function mem_load();
//         for (int i=0; i!=2**`MLEN/4; i++)begin //Copy from memspace to interface that coms to MEM array 
          $readmemh("darksocv.mem", mem_int.memory_bus, 0); //Temporal memspace receives .a code
//           mem_int.memory_bus = int_memspace; //NO NECESSARY A FOR, but used it so the code looks the same
//         end      							   // :D <3
    endfunction
    
endclass //className

//Good reference: https://blogs.sw.siemens.com/verificationhorizons/2022/08/21/systemverilog-what-is-a-virtual-interface/