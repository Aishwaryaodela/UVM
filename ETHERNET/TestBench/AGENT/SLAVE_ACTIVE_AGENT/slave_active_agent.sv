
	///////////////////////////////////////////////////
	//     IN THIS APB SLAVE ACTIVE AGENT CLASS      // 
	// WE HAVE TO DECLARE SLAVE SEQUENCER AND DRIVER //
	///////////////////////////////////////////////////


class apb_slave_active_agent extends uvm_component;

	`uvm_component_utils(apb_slave_active_agent)     					//----- FACTORY REGISTRATION

	apb_slave_sequencer h_s_seqr;    									//----- HANDLE FOR SEQUENCER

	apb_slave_driver h_s_driv;    										//----- HANDLE FOR DRIVER

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "apb_slave_active_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	////////////////////////////////////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_s_seqr = apb_slave_sequencer::type_id::create("h_s_seqr",this);		//--- OBJECT CREATION FOR SLAVE SEQUENCER
		h_s_driv = apb_slave_driver::type_id::create("h_s_driv",this);			//--- OBJECT CREATION FOR SALVE DRIVER 
	endfunction
  
	///////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS   //
	///////////////////////////////////////////////////

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	h_s_driv.seq_item_port.connect(h_s_seqr.seq_item_export);			//--- GIVING CONNECTION BETWEEN SLAVE DRIVER AND SLAVE SEQUENCER
	endfunction
endclass
