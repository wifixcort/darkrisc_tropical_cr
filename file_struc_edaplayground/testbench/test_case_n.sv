program testcase(ifc_mem ifc_mem);
  environment env = new(ifc_mem);

  initial
    begin
    //env.drvr.reset();
    //env.drvr.write(10);
    //env.drvr.read(10);
	env.mem_driver.mem_reset();
    env.mem_driver.mem_load();

      
    end
endprogram