class environment;
  mem_driver mem_driver;
  //scoreboard sb;
  monitor2 mntr2;
  
  function new();
    $display("Creating environment");
    //sb = new();
    mem_driver = new();
    mntr2 = new();
    fork 
      mntr2.check();
    join_none
  endfunction
           
endclass