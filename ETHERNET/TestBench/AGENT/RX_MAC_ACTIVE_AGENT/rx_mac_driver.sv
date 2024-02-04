
	//////////////////////////////////////////////////// 
	//     IN THIS RX MAC DRIVER CLASS WE HAVE TO     //
	//      DRIVE THE SIGNALS ON TO THE INTERFACE     //
	////////////////////////////////////////////////////


class rx_mac_driver extends uvm_driver#(sequence_item);

	`uvm_component_utils(rx_mac_driver)     			//------ FACTORY REGISTRATION

  	virtual intf h_intf;								//------ INSTANCE FOR INTERFACE

	config_class h_config;								//------ HANDLE FOR CONFIG CLASS

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "rx_mac_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
  
	///////////////////////////////////////////////////////////////////
	// IN RUN PHASE WE HAVE TO DRIVE THE SIGNALS ON TO THE INTERFACE //
	///////////////////////////////////////////////////////////////////

  	task run_phase(uvm_phase phase);
		super.run_phase(phase);
      	req = sequence_item::type_id::create("req");		//--- OBJECT CREATION FOR SEQUENCE ITEM
		h_intf.cb_rx_mac_driver.MRxDV 	<= 0;
        h_intf.cb_rx_mac_driver.MRxD 	<= 0;
        h_intf.cb_rx_mac_driver.MRxErr 	<= 0;
        h_intf.cb_rx_mac_driver.MCrS 	<= 0;
      	forever 
			begin 
				@(h_intf.cb_rx_mac_driver)
				seq_item_port.get_next_item(req);        
				h_intf.cb_rx_mac_driver.MRxDV <= req.MRxDV;
        		h_intf.cb_rx_mac_driver.MRxD <= req.MRxD;
        		h_intf.cb_rx_mac_driver.MRxErr <= req.MRxErr;
        		h_intf.cb_rx_mac_driver.MCrS <= req.MCrS;
           
				seq_item_port.item_done();
      		end
  	endtask

   
  	function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));	//--- GETTING INTERFACE FROM TOP
    	assert(uvm_config_db#(config_class)::get(null,this.get_full_name,"ethernet_config_class",h_config));		//--- GETTING CONFIG CLASS FROM TOP
  	endfunction
endclass
