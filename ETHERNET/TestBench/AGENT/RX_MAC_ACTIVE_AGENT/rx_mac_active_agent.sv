
	/////////////////////////////////////////////////////
	//       IN THIS RX MAC ACTIVE AGENT CLASS         // 
	// WE HAVE TO DECLARE RX MAC SEQUENCER AND DRIVER  //
	/////////////////////////////////////////////////////

class rx_mac_active_agent extends uvm_component;											

	`uvm_component_utils(rx_mac_active_agent)     											//----- FACTORY REGISTRATION

	rx_mac_sequencer h_rx_mac_seqr;   					 									//----- HANDLE FOR MAC SEQUENCER

	rx_mac_driver h_rx_mac_driv;    														//----- HANDLE FOR RX MAC DRIVER

	rx_mac_input_monitor h_rx_mac_ip_mon;													//----- HANDLE FOR RX MAC INPUT MONITOR

  	uvm_analysis_export#(score_board_payload) rx_mac_active_agent_export; 	 					//----- ANALYSIS PORT FOR RX MAC ACTIVE AGENT
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "rx_mac_active_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	////////////////////////////////////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      	rx_mac_active_agent_export = new("rx_mac_active_agent_export",this);				//--- OBJECT CREATION FOR RX MAC ACTIVE AGENT EXPORT
		h_rx_mac_seqr = rx_mac_sequencer::type_id::create("h_rx_mac_seqr",this);			//--- OBJECT CREATION FOR RX MAC SEQUENCER
		h_rx_mac_driv = rx_mac_driver::type_id::create("h_rx_mac_driv",this);				//--- OBJECT CREATION FOR RX MAC DRIVER
		h_rx_mac_ip_mon = rx_mac_input_monitor::type_id::create("h_rx_mac_ip_mon",this);	//--- OBJECT CREATION FOR RX MAC INPUT MONITOR
	endfunction
  
	///////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS   //
	///////////////////////////////////////////////////

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      h_rx_mac_driv.seq_item_port.connect(h_rx_mac_seqr.seq_item_export);					//--- CONNECTION BETWEEN RX MAC DRIVER AND RX MAC SEQUENCER
	  h_rx_mac_ip_mon.rx_mac_input_monitor_port.connect(this.rx_mac_active_agent_export);	//--- CONNECTION BETWEEN RX MAC INPUT MONITOR AND RX MAC ACTIVE AGENT EXPORT PORT
	endfunction
endclass
