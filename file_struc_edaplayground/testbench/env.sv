class environment;
  mem_driver mem_driver;
  stimulus sti;
  monitor2 mntr2;
  
  function new();
    $display("Creating environment");
    //sb = new();
    sti = new();
    mem_driver = new(sti);
    mntr2 = new();
    fork
      sti.mem_generate(1);
      mem_driver.mem_load();
      
      mntr2.check();
    join_none
  endfunction
           
endclass
