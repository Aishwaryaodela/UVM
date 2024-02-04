
	/////////////////////////////////////////////////////
	//      IN THIS APB MASTER ACTIVE AGENT CLASS      // 
	//     WE HAVE TO DECLARE SEQUENCER AND DRIVER     //
	/////////////////////////////////////////////////////

class master_active_agent extends uvm_component;

	`uvm_component_utils(master_active_agent)     	//----- FACTORY REGISTRATION

	master_sequencer h_m_seqr;    					//----- HANDLE FOR SEQUENCER

	master_driver h_m_driv;    						//----- HANDLE FOR DRIVER

	apb_master_input_monitor h_m_io_monitor;

	//uvm_analysis_export #(sequence_item) apb_master_port;

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "master_active_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	////////////////////////////////////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_m_seqr = master_sequencer::type_id::create("h_m_seqr",this);		//--- OBJECT CREATION FOR MASTER SEQUENCER
		h_m_driv = master_driver::type_id::create("h_m_driv",this);			//--- OBJECT CREATION FOR MASTER DRIVER
		h_m_io_monitor = apb_master_input_monitor::type_id::create("h_m_io_monitor",this);
		//apb_master_port = new("apb_master_port",this);
	endfunction
  
	///////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS   //
	///////////////////////////////////////////////////

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	h_m_driv.seq_item_port.connect(h_m_seqr.seq_item_export);     		//--- CONNECTION BETWEEN MASTER DRIVER AND MASTER SEQUENCER
		//h_m_io_monitor.rx_mac_input_monitor_predictor_port.connect(this.apb_master_port);
	endfunction
endclass
