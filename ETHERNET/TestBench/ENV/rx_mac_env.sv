

//----------- mac environment class

class mac_env extends uvm_component;

	`uvm_component_utils(mac_env)    ///factory  registration


	rx_mac_active_agent h_rx_mac_a_agent;  //----- handle for rx mac active agent

	//----- new constructor
	
	function new(string name = "mac_env",uvm_component parent);
		super.new(name,parent);
	endfunction

	//------build phase

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_rx_mac_a_agent = rx_mac_active_agent::type_id::create("h_rx_mac_a_agent",this);  //--- object creation for rx_mac_active_agent

	endfunction

endclass
