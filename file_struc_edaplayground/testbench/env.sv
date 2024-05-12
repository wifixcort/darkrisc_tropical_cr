class environment;
  mem_driver mem_driver;
  stimulus sti;
  scoreboard sb;
  monitor2 mntr2;
  instr_monitor mntr1;
  
  function new();
    $display("Creating environment");
    sb = new();
    sti = new();
    mem_driver = new(sti);
    mntr2 = new();
    mntr1 = new(sb);
    fork
      sti.mem_generate(1);
      mem_driver.mem_load();
      
      mntr2.check();
      mntr1.check(0); //Debug-ability : No=0, Yes=1
    join_none
  endfunction
           
endclass
