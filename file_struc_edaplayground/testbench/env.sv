class environment;
  mem_driver mem_driver;
  //scoreboard sb;
  //monitor mntr;
  virtual ifc_mem ifc_mem;
           
  function new(virtual ifc_mem ifc_mem);
    $display("Creating environment");
    this.ifc_mem = ifc_mem;
    //sb = new();
    mem_driver = new(this.ifc_mem);
    //mntr = new(this.ifc_mem,sb);
    //fork 
      //Checker
    //join_none
  endfunction
           
endclass