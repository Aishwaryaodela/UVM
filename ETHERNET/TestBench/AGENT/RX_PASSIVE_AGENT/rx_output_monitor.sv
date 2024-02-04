	///////////////////////////////////////////////////////////////////////
	//  IN THIS APB OUTPUT MONITOR CLASS WE HAVE TO COLLECT THE FRAME    //
	//      FROM THE DESIGN AND COMPARE  WITH THE GENERATED PACKET       //
	///////////////////////////////////////////////////////////////////////



class rx_output_monitor extends uvm_monitor;

	`uvm_component_utils(rx_output_monitor)     									//------ FACTORY REGISTRATION

  	uvm_analysis_port#(score_board_payload) rx_op_monitor_port;  					//------ ANALYSIS PORT DECLARATION

	sequence_item req;																//------ HANDLE FOR SEQUENCE ITEM

	virtual intf h_intf;															//------ INSTANCE FOR INTERFACE
	bit a=1;
	config_class h_config;															//------ HANDLE FOR CONFIG CLASS
	int i;
	int d;
	bit [15:0]len;
	//==================================================
		bit [31:0]output_queue_for_32_bit[$];
		bit [3:0]output_queue_for_4_bit[$];
		score_board_payload op_monitor_payload_score_board;
	//==================================================
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "rx_output_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                          AND ANALYSIS PORTS                        //
	////////////////////////////////////////////////////////////////////////

 	 function void build_phase(uvm_phase phase);
   	 	super.build_phase(phase);
		req = sequence_item::type_id::create("req");									//------ OBJECT CREATION FOR SEQUENCE ITEM
	    //h_config = config_class::type_id::create("h_config");							//------ OBJECT CREATION FOR CONFIG CLASS
    	rx_op_monitor_port = new("rx_op_monitor_port",this);							//------ OBJECT CREATION FOR RX_OUTPUT MONITOR ANALYSIS PORT
  	 endfunction
	
	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	//                           AND CONFIG CLASS                              //
	/////////////////////////////////////////////////////////////////////////////
 
  	function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));			//---- GETTING INTERFACE FROM TOP
    	//assert(uvm_config_db#(config_class)::get(null,"*","ethernet_config_class",h_config));		//---- GETTING CONFIG CLASS FROM TOP
    	assert(uvm_config_db#(config_class)::get(this,"*","ethernet_config_class",h_config));		//---- GETTING CONFIG CLASS FROM TOP
  	endfunction

	/////////////////////////////////////////////////////////////////
	//       IN RUN PHASE WE HAVE TO GET THE INTERFACE SIGNALS     //
	//                 AND WRITE CHECKS TO THEM                    //
	/////////////////////////////////////////////////////////////////

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever @(h_intf.cb_slave_monitor)
		begin 
			req.prstn_i 	= h_intf.cb_slave_monitor.prstn_i;
			req.m_psel_o 	= h_intf.cb_slave_monitor.m_psel_o;
			req.m_penable_o = h_intf.cb_slave_monitor.m_penable_o;
			req.m_pwrite_o	= h_intf.cb_slave_monitor.m_pwrite_o;
			req.m_pwdata_o 	= h_intf.cb_slave_monitor.m_pwdata_o;
			req.m_paddr_o 	= h_intf.cb_slave_monitor.m_paddr_o;
			req.m_prdata_i 	= h_intf.cb_slave_monitor.m_prdata_i;
			req.m_pready_i 	= h_intf.cb_slave_monitor.m_pready_i;
			req.int_o       = h_intf.cb_slave_monitor.int_o;
			output_check;
			//if(h_config.input_write && h_config.output_write)begin
			//end	
		end
	endtask
	
	task output_check;
		//$display("-=-=-=-=-=-==-=-=-=-=-=-====-------------------------------===============",req.m_pready_i);
		if(req.m_pready_i)
		begin//{
			

		len = h_config.length_[d];
			if(len<46)begin
						len = 46;
					end

		//	$display("**********************************************OUTPUT MONITOR LEN =%D  size =%d",len,output_queue_for_32_bit.size());
			if(output_queue_for_32_bit.size()!=(18+(len))/4)
			begin//{
			//	$display("-=-=-=-=-=-==-=-=-=-=-=-====-------------------%d %d %d %d",req.m_pwdata_o,req.m_psel_o ,req.m_penable_o,req.m_pready_i);
				if(req.m_psel_o && req.m_penable_o && req.m_pready_i)
					begin//{
						output_queue_for_32_bit.push_back(req.m_pwdata_o);
						//$display($time,"=-=-=-=-=-=-=-=-=-=-output data = %p  size =%d frame size =%d rxb = %d",output_queue_for_32_bit,output_queue_for_32_bit.size(),(18+(len))/4,len);
					end//}
			end//}
			else 
			begin//{
				//$display("======================================================================");
				for(int i=0;i<output_queue_for_32_bit.size();i++)
				begin//{
					output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][27:24]);
        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][31:28]);

        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][19:16]);
        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][23:20]);

        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][11:8]);
        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][15:12]);

        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][3:0]);
        			output_queue_for_4_bit.push_back(output_queue_for_32_bit[i][7:4]);
        			//$display($time,"===----****4_bit=%p",output_queue_for_4_bit);
				end//}
			end//}
		end//}
	//	$display("output monitor ====================4 bit queue = %d",output_queue_for_4_bit.size());
		if(output_queue_for_4_bit.size()==(18+(len))*2)
		begin
			//$display($time,"===----****4_bit=%p  size =%d",output_queue_for_4_bit,output_queue_for_4_bit.size());
		//	$display("========================== DESTINATION ADDRESS COMPARISION ==================");
			/*if(h_config.queue_dest_addr[h_config.count] == h_config.BRO_ADDR)
			begin//{
				if(!(h_config.PRO) && h_config.BRO)
				begin//{
					//--------REJECTION
				end//}
				else if(!(h_config.PRO) && !(h_config.BRO))
				begin//{
					if(output_queue_for_4_bit[0:11] == h_config.queue_dest_addr[h_config.count])
					begin//{
						$display($time,"****OUTPUT MONITOR**** DESTINATION ADDRESS MATCHED ********MRXD_destination address = %p   AND destination address = %p",output_queue_for_4_bit[0:11],h_config.queue_dest_addr[h_config.count]);
					end//}
					else
					begin//{
						$display($time,"***!!!!!!**OUTPUT MONITOR*** DESTINATION ADDRESS NOT MATCHED *****!!!!!!***MRXD_destination address = %p   AND destination address = %p",output_queue_for_4_bit[0:11],h_config.queue_dest_addr[h_config.count]);
					end//}
				end//}
				else
				begin//{*/
					if(output_queue_for_4_bit[0:11] == h_config.queue_dest_addr[h_config.count])
						begin
							$display($time,"****OUTPUT MONITOR**** DESTINATION ADDRESS MATCHED ********MRXD_destination address = %p   AND destination address = %p",output_queue_for_4_bit[0:11],h_config.queue_dest_addr[h_config.count]);
						end
						else
						begin
							$display($time,"***!!!!!!**OUTPUT MONITOR*** DESTINATION ADDRESS NOT MATCHED *****!!!!!!***MRXD_destination address = %p   AND destination address = %p",output_queue_for_4_bit[0:11],h_config.queue_dest_addr[h_config.count]);
						end
						h_config.queue_dest_addr[h_config.count].delete();
				//end//}
			//end//}
			//========================== SOURCE ADDRESS  COMPARISION ==================
			if(output_queue_for_4_bit[12:23] == h_config.queue_source_addr[h_config.count])
			begin
				$display($time,"****OUTPUT MONITOR**** SOURCE ADDRESS MATCHED ********MRXD_source address = %p   AND source address = %p",output_queue_for_4_bit[28:39],h_config.queue_source_addr[h_config.count]);
			end
			else
			begin
				$display($time,"***!!!!!!**OUTPUT MONITOR*** SOURCE ADDRESS NOT MATCHED *****!!!!!!***MRXD_source address = %p   AND source address = %p",output_queue_for_4_bit[12:23],h_config.queue_source_addr[h_config.count]);
			end
			h_config.queue_source_addr[h_config.count].delete();
			//========================== LENGTH COMPARISION ===========================
			if(output_queue_for_4_bit[24:27] == h_config.queue_length[h_config.count])
			begin
				$display($time,"****OUTPUT MONITOR**** LENGTH MATCHED ********MRXD_LENGTH = %p   AND LENGTH = %p",output_queue_for_4_bit[24:27],h_config.queue_length[h_config.count]);
			end
			else
			begin
				$display($time,"***!!!!!!**OUTPUT MONITOR*** LENGTH NOT MATCHED *****!!!!!!***MRXD_LENGTH = %p   AND LENGTH = %p",output_queue_for_4_bit[24:27],h_config.queue_length[h_config.count]);
			end
			h_config.queue_length[h_config.count].delete();
			//========================== PAYLOAD COMPARISION ===========================
			if(output_queue_for_4_bit[28:(28+(len)*2)-1] == h_config.queue_payload[h_config.count])
			begin
				$display($time,"****OUTPUT MONITOR**** PAYLOAD MATCHED ********MRXD_PAYLOAD = %p   AND PAYLOAD = %p",output_queue_for_4_bit[28:(28+(len)*2)-1],h_config.queue_payload[h_config.count]);
				//if(a==1)
				//begin
					//repeat((len)*2)
					//begin
					op_monitor_payload_score_board = h_config.queue_payload[h_config.count];
					//i++;
					//end
					//a=0;
				//end
			end
			else
			begin
				$display($time,"***!!!!!!**OUTPUT MONITOR*** PAYLOAD NOT MATCHED *****!!!!!!***MRXD_PAYLOAD = %p   AND PAYLOAD = %p",output_queue_for_4_bit[28:(28+(len)*2)-1],h_config.queue_payload[h_config.count]);
			end
			h_config.queue_payload[h_config.count].delete();
			//========================== FCS COMPARISION ===========================
			if(output_queue_for_4_bit[(28+(len)*2):35+(len)*2] == h_config.queue_fcs[h_config.count])
			begin
				$display($time,"****OUTPUT MONITOR**** FCS MATCHED ********MRXD_FCS = %p   AND FCS = %p",output_queue_for_4_bit[(28+(len)*2):(35+(len)*2)],h_config.queue_fcs[h_config.count]);
				output_queue_for_4_bit.delete();
				req.MRxDV =0;req.MCrS = 0;
			end
			else
			begin
				$display($time,"***!!!!!!**OUTPUT MONITOR*** FCS NOT MATCHED *****!!!!!!***MRXD_FCS = %p   AND FCS = %p",output_queue_for_4_bit[(28+(len)*2):(35+(len)*2)],h_config.queue_fcs[h_config.count]);
				req.MRxDV =0;req.MCrS = 0;
			end
				h_config.queue_fcs[h_config.count].delete();

			//output_queue_for_4_bit.delete();
			//output_queue_for_32_bit.delete();
			rx_op_monitor_port.write(op_monitor_payload_score_board);
			
			h_config.output_write = 1;
			//	$display("=============================IN OPMON OPFLAG:%D",h_config.output_write);
			h_config.queue_fcs[h_config.count].delete();
			output_queue_for_4_bit.delete();
			output_queue_for_32_bit.delete();
			d++;
		end
	endtask
endclass
