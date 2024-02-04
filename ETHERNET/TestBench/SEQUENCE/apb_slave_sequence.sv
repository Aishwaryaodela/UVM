
//------------ sequence class -------------------



class apb_slave_sequence extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(apb_slave_sequence)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "apb_slave_sequence");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		//start_item(req);
		//assert(req.randomize());
		//finish_item(req);
    endtask
  
  
endclass
  
