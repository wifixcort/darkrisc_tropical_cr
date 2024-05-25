class environment;
   driver drvr;
   stimulus sti;
   virtual intf_soc intf;
   scoreboard sb;
   monitor2 mntr2;
   instr_monitor mntr1;
   function new(virtual intf_soc in_intf);
      $display("Creating environment");
      intf = in_intf;
      sti  = new();
      drvr = new(intf, sti);
      sb = new();
      mntr2 = new(sb);
      mntr1 = new(sb);
      fork
		 mntr2.check();
		 mntr1.check(0); //Debug-ability : No=0, Yes=1
      join_none
   endfunction
   
endclass
