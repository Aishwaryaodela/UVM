
	////////////////////////////////////////////
	//     IN THIS RX PASSIVE AGENT CLASS     // 
	//    WE HAVE TO DECLARE OUTPUT MONITOR   //
	////////////////////////////////////////////

class rx_passive_agent extends uvm_component;

	`uvm_component_utils(rx_passive_agent)    						 //----- FACTORY REGISTRATION

	rx_output_monitor h_rx_op_mon;  								 //----- HANDLE FOR OUTPUT MONITOR

  uvm_analysis_export#(score_board_payload) rx_passive_agent_export;   	 //----- ANALYSIS EXPORT FOR RX PASSIVE AGNET
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "rx_passive_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                             AND PORTS                              //
	////////////////////////////////////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      	rx_passive_agent_export = new("rx_passive_agent_export",this);			//------ OBJECT CREATION FOR RX PASSIVE AGENT EXPORT
		h_rx_op_mon = rx_output_monitor::type_id::create("h_rx_op_mon",this);	//------ OBJECT CREATION FOR RX OUTPUT MONITOR 
	endfunction
    
	///////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS   //
	///////////////////////////////////////////////////

	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
     	h_rx_op_mon.rx_op_monitor_port.connect(this.rx_passive_agent_export);	//------ GIVING CONNECTION BETWEEN RX OUTPUT MONITOR PORT AND RX PASSIVE AGENT EXPORT
	endfunction
endclass
