program testcase(intf_soc intf);
  environment env = new(intf);
         
  initial
    begin
    env.drvr.reset(); 
    #10000;
    env.drvr.reset(); 
    #10000;
    end
endprogram
