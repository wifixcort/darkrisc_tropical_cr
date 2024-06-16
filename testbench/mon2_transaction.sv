class mon2_transaction extends uvm_sequence_item;
    rand bit [7:0] data;
  
    `uvm_object_utils(mon2_transaction)
  
    function new(string name = "mon2_transaction");
      super.new(name);
    endfunction
  
    function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_field_int("data", data, 8);
    endfunction
  endclass
  