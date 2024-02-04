
//------ apb environment......

class apb_env extends uvm_component;

	`uvm_component_utils(apb_env)   //-- factory registration

	master_active_agent  h_m_a_agent;  //----- handle for master_active_agent

	apb_slave_active_agent  h_s_a_agent;   //----- handle for slave_active_agent

	rx_passive_agent  h_rx_p_agent;     //------- handle for rx_passive_agent


	//----- new constructor

	function new(string name = "apb_env",uvm_component parent);
		super.new(name,parent);
	endfunction

	//------ build phase

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_m_a_agent = master_active_agent::type_id::create("h_m_a_agent",this);   //--- object creation for master_active_agent
		h_s_a_agent = apb_slave_active_agent::type_id::create("h_s_a_agent",this);   //---- object creation for slave_active_agent
		h_rx_p_agent = rx_passive_agent::type_id::create("h_rx_p_agent",this);    //--- object creation for rx_passive_agent
	endfunction

endclass
