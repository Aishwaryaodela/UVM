
///////////////////////////////////////////////////////////////////////
//    IN THE TEST CLASS WE HAVE TO TAKE THE INSTANCE FOR MAIN ENV    //
//       AND WE HAVE TO START THE SEQUENCE WITH ITS HANDLE           //
///////////////////////////////////////////////////////////////////////

class test extends uvm_component;
	`uvm_component_utils(test)  											//------ FACTORY REGISTRATION
	
	sequence_item req;														//------ SEQUENCE ITEM HANDLE
	
	main_env h_main_env;  													//------ HANDLE FOR MAIN ENV
		
	config_class h_config;													//------ HANDLE FOR CONFIG CLASS
		
	virtual_sequence h_virtual_seq;											//------ HANDLE FOR VIRTUAL SEQUENCE
	
	virtual intf h_intf;													//------ HANDLE FOR INTERFACE
	
	RAL_sequence req_seq;													//------ HANDLE FOR RAL SEQUENCE
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "test",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	////////////////////////////////////////////////////////////////////////
	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                          AND ANALYSIS PORTS                        //
	////////////////////////////////////////////////////////////////////////
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		req = sequence_item::type_id::create("req");												//------ OBJECT CREATION FOR SEQUENCE ITEM
		req_seq = RAL_sequence::type_id::create("req_seq");											//------ OBJECT CREATION FOR RAL SEQUENCE
		h_main_env = main_env::type_id::create("h_main_env",this);   								//------ OBJECT CREATION FOR MAIN ENVIRONMENT
		h_virtual_seq = virtual_sequence::type_id::create("h_virtual_seq");							//------ OBJECT CREATION FOR VIRTUAL SEQUENCE
	    assert(uvm_config_db#(config_class)::get(null,"*","ethernet_config_class",h_config));    	//------ GETTING CONFIG FROM TOP 
		assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));			//------ GETTING INTERFACE FROM TOP
	endfunction
	
	/////////////////////////////////////////////////////////////////////
	//         END OF ELABORATION PHASE USED TO PRINT TOPOLOGY         //
	///////////////////////////////////////////////////////////////////// 
	
	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		print();      																				//------ USED TO PRINT TOPOLOGY
	endfunction

	/////////////////////////////////////////////////////////////////
	//       IN RUN PHASE WE HAVE TO START THE SEQUENCES IN        //
	//           BETWEEN PHASE RAISE AND DROP OBJECTION            //
	/////////////////////////////////////////////////////////////////

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this,"raised the objection");          								//------ IT DECIDES THE STARTING OF THE SIMULATION
			
		h_config.do_ = 1;
		h_virtual_seq.start(h_main_env.h_virtual_seqr);
		//-------------------------------------------------
		req_seq.REG_BLOCK = h_main_env.REG_BLOCK;
		req_seq.starting_phase = phase;
		//req_seq.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		
		//-------------------------------------------------------
		
		//h_apb_master_seq.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		//h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr);
		//h_apb_master_seq.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		//wait(req.int_o);
		//-----------------------------INT SOURCE configuration 
		//start_item(req);
		//assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
		//finish_item(req);
		/*
		h_config.do_ = 1;
		test_case1.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		wait(h_intf.int_o)begin
		h_config.do_ = 0;
		test_case1.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		end
		
		h_config.do_ = 1;
		
		test_case2.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr); 
		wait(h_config.output_write)
		h_config.count++;
		wait(h_intf.int_o)begin
		h_config.do_ = 0;
		test_case2.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		end
		
		h_config.do_ = 1;
		
		test_case3.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr); 
		wait(h_config.output_write)
		h_config.count++;
		wait(h_intf.int_o)begin
		h_config.do_ = 0;
		test_case3.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		end
		
		h_config.do_ = 1;
		
		test_case4.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr); 
		wait(h_config.output_write)
		h_config.count++;
		wait(h_intf.int_o)begin
		h_config.do_ = 0;
		test_case4.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		end
		
		h_config.do_ = 1;
		
		test_case5.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		h_rx_mac_seq_final.start(h_main_env.h_rx_mac_env.h_rx_mac_a_agent.h_rx_mac_seqr); 
		wait(h_config.output_write)
		h_config.count++;
		wait(h_intf.int_o)begin
		h_config.do_ = 0;
		test_case5.start(h_main_env.h_apb_env.h_m_a_agent.h_m_seqr);
		
		end
		*/
		//#100;
		//phase.phase_done.set_drain_time(this,5000);
		//#3000;
		phase.drop_objection(this,"dropped the objection");         								//------ ENDING OF SIMULATION
	endtask
endclass
