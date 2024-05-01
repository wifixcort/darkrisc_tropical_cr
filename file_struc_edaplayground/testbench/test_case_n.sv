program testcase();
  environment env = new();

  initial
    begin
    //env.drvr.reset();
    //env.drvr.write(10);
    //env.drvr.read(10);
		//env.mem_driver.mem_reset();
    env.mem_driver.mem_load();
    #1000000;
      
    end
endprogram