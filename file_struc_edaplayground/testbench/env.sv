class environment;
  driver drvr;
  //scoreboard sb;
  //monitor mntr;
  virtual intf_soc intf;           
  
  // constructor
  function new(virtual intf_soc intf);
    $display("Creating environment");
    this.intf = intf;
    //sb = new();
    drvr = new(intf); //,sb);
    //mntr = new(intf,sb);
    //fork 
    //  mntr.check();
    //join_none
  endfunction
           
endclass