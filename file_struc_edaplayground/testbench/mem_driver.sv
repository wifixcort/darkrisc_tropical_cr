class driver;
  //stimulus sti;
  //scoreboard sb;
  virtual intf_soc intf;
     
  // Constructor
  function new(virtual intf_soc intf); //,scoreboard sb);
    this.intf = intf;
    //this.sb = sb;
  endfunction
    
  // Reset method 
  task reset();  
    $display("Executing Reset\n");
    intf.rst = 0;
    intf.uart_rx = 0;
    intf.uart_tx = 0;
    intf.rst = 1; ///////
    @ (negedge intf.clk);
    intf.rst = 0;
  endtask
   
  /*
  task write(input integer iteration);
    repeat(iteration)
    begin
      sti = new();
      @ (negedge intf.clk);
      if(sti.randomize()) // Generate stimulus
        $display("Driving 0x%h value in the DUT\n", sti.value);
        intf.data_in = sti.value; // Drive to DUT
        intf.wr_en = 1;
        //intf.wr_cs = 1;
        sb.store.push_front(sti.value);// Cal exp value and store in Scoreboard
    end
    @ (negedge intf.clk);
    intf.wr_en = 0;
    //intf.wr_cs = 0;
  endtask
  
  task read(input integer iteration);
    repeat(iteration)
    begin
       @ (negedge intf.clk);
       intf.rd_en = 1;
       //intf.rd_cs = 1;
    end
    @ (negedge intf.clk);
    intf.rd_en = 0;
    //intf.rd_cs = 0;
  endtask
  */
endclass
