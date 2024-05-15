program testcase(intf_soc intf);
  environment env = new(intf);

  initial begin
    env.drvr.reset();
    env.drvr.mem_load();
    #1000000;  
  end
endprogram