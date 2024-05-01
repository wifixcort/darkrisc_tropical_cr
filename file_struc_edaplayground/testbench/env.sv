class environment;
  mem_driver mem_driver;
  //scoreboard sb;
  //monitor mntr;
  
  function new();
    $display("Creating environment");
    //sb = new();
    mem_driver = new();
    //mntr = new(this.ifc_mem,sb);
    //fork 
      //Checker
    //join_none
  endfunction
           
endclass