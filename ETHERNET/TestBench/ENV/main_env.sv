
//////////////////////////////////////////////////////
//     IN THIS MAIN ENVIRONMENT WE HAVE TO GIVE     //
//      CONNECTIONS TO THE AGENTS THROUGH ENVS      //
//////////////////////////////////////////////////////

class main_env extends uvm_component;

	`uvm_component_utils(main_env)  													 	//------ FACTORY REGISTRATION

	apb_env h_apb_env;   																	//------ HANDLE FOR APB ENV

	mac_env h_rx_mac_env;   																//------ HANDLE FOR MAC ENV

	rx_scoreboard  h_rx_sb;  															 	//------ HANDLE FOR SCORE BOARD

	virtual_sequencer h_virtual_seqr;														//------ HANDLE FOR VIRTUAL SEQUENCER

	reg2ethernet_adapter  adapter;															//------ HANDLE FOR ADAPTER

	ETHERNET_REG_BLOCK   REG_BLOCK;															//------ HANDLE FOR REG BLOCK

  	uvm_reg_predictor #(sequence_item) ethernet2reg_predictor;								//------ PREDICTOR PORT DECLARATION

	coverage h_cov;
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
		
	function new(string name = "main_env",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	////////////////////////////////////////////////////////////////////////
	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                          AND ANALYSIS PORTS                        //
	////////////////////////////////////////////////////////////////////////
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_apb_env = apb_env::type_id::create("h_apb_env",this);      						//------ OBJECT CREATION FOR APB ENV
		h_rx_mac_env = mac_env::type_id::create("h_rx_mac_env",this);  						//------ OBJECT CREATION FOR RX MAC ENV
        h_rx_sb = rx_scoreboard::type_id::create("h_rx_sb",this);     						//------ OBJECT CREATION FOR RX SCORE BOARD
		h_virtual_seqr = virtual_sequencer::type_id::create("h_virtual_seqr",this);			//------ OBJECT CREATION FOR VIRTUAL SEQUENCER
		h_cov = coverage::type_id::create("h_cov",this);

		REG_BLOCK = ETHERNET_REG_BLOCK::type_id::create("REG_BLOCK",this);					//------ OBJECT CREATION FOR REG BLOCK
		REG_BLOCK.build();
		adapter = reg2ethernet_adapter::type_id::create("adapter",this);					//------ OBJECT CREATION FOR ADAPTER
		ethernet2reg_predictor = uvm_reg_predictor #(sequence_item) ::type_id::create("ethernet2reg_predictor",this);
	endfunction

 	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	//                           AND CONFIG CLASS                              //
	/////////////////////////////////////////////////////////////////////////////
	
	function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			REG_BLOCK.map.set_sequencer(.sequencer(h_apb_env.h_m_a_agent.h_m_seqr),.adapter(adapter));
    		//REG_BLOCK.default_map.set_base_addr('h400);
			ethernet2reg_predictor.map = REG_BLOCK.map;										//------ SET THE PREDICTOR MAP    
   			ethernet2reg_predictor.adapter = adapter;										//------ SET THE PREDICTOR ADAPTER
			//REG_BLOCK.map.set_auto_predict(0);
    		//h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_ip_mon.rx_mac_input_monitor_predictor_port.connect(ethernet2reg_predictor.bus_in);
    		//h_apb_env.h_rx_p_agent.h_rx_op_mon.rx_op_monitor_predictor_port.connect(ethernet2reg_predictor.bus_in);
    		h_apb_env.h_m_a_agent.h_m_io_monitor.rx_mac_input_monitor_predictor_port.connect(ethernet2reg_predictor.bus_in);
    		//h_apb_env.h_m_a_agent.h_m_driv.rx_mac_input_monitor_predictor_port.connect(ethernet2reg_predictor.bus_in);
			
			h_apb_env.h_rx_p_agent.rx_passive_agent_export.connect(h_rx_sb.rx_score_op_imp_port);   		//--- giving connection between rx_passive_agent_export and the rx_scoreboard_output_implementation port
			h_rx_mac_env.h_rx_mac_a_agent.rx_mac_active_agent_export.connect(h_rx_sb.rx_score_ip_imp_port); //----giving connection between rx_mac_active_agent_export and the rx_scoreboard_input_implementation port
			h_apb_env.h_m_a_agent.h_m_io_monitor.rx_mac_input_monitor_predictor_port.connect(h_cov.cov_imp_port);
			h_virtual_seqr.h_m_seqr = h_apb_env.h_m_a_agent.h_m_seqr;						//------ SAYING MEMORIES ARE SAME
			h_virtual_seqr.h_rx_mac_seqr = h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr;		//------ SAYING MEMORIES ARE SAME

	endfunction

endclass
