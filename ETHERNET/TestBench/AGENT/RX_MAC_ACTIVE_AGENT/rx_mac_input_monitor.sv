	class rx_mac_input_monitor extends uvm_monitor;											
	`uvm_component_utils(rx_mac_input_monitor)     											//---------- FACTORY REGISTRATION

  	uvm_analysis_port#(score_board_payload) rx_mac_input_monitor_port;  							//---------- ANALYSIS PORT FOR INPUT MONITOR
	uvm_analysis_port#(sequence_item) rx_mac_input_monitor_pre_port; 
	sequence_item req;   																	//---------- HANDLE DECLARATION FOR SEQUENCE ITEM 
 	score_board_payload payload_score_board;
	virtual intf h_intf;   																	//---------- HANDLE DECLARATION FOR INTERFACE

	config_class h_config;																	//---------- HANDLE DECLARATION FOR CONFIG CLASS

    



	//===================================================================
				bit [3:0]queue_with_preamble[$];

				int len;
    				int k;
	//===================================================================

	
	function new(string name = "rx_mac_input_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		rx_mac_input_monitor_port = new("rx_mac_input_monitor_port",this);   				//----- OBJECT CREATION FOR ANALYSIS PORT
        rx_mac_input_monitor_pre_port = new("rx_mac_input_monitor_pre_port",this);
	endfunction
  
 
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	assert(uvm_config_db#(virtual intf)::get(null,this.get_full_name,"ethernet_interface",h_intf));            	//---- GETTING INTERFACE FROM TOP
		assert(uvm_config_db#(config_class)::get(null,this.get_full_name,"ethernet_config_class",h_config));		//---- GETTING CONFIG CLASS FROM TOP
		//assert(uvm_config_db#(config_class)::get(this,"*","ethernet_config_class",h_config));		             	//---- GETTING CONFIG CLASS FROM TOP
    	//assert(uvm_config_db#(config_class)::get(null,"*","ethernet_config_class",h_config));						//---- GETTING CONFIG CLASS FROM TOP
    	//assert(uvm_config_db#(config_class)::get(this,this.get_full_name,"ethernet_config_class",h_config));		//---- GETTING CONFIG CLASS FROM TOP
	endfunction

	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		req = sequence_item::type_id::create("req");    									//--------- OBJECT CREATION FOR SEQUENCE ITEM

      	forever @(h_intf.cb_rx_mac_monitor) begin

			
			req.MRxDV = h_intf.cb_rx_mac_monitor.MRxDV  ;    								//--------- MRxDV VALUE IS TAKING FROM INTERFACE

        	req.MRxD = h_intf.cb_rx_mac_monitor.MRxD ;        								//--------- MRxD VALUE IS TAKING FROM INTERFACE

        	req.MRxErr = h_intf.cb_rx_mac_monitor.MRxErr ;  								//--------- MRxErr VALUE IS TAKING FROM INTERFACE
			
			req.MCrS = h_intf.cb_rx_mac_monitor.MCrS ;  									//--------- MCrS VALUE IS TAKING FROM INTERFACE

			//	$display($time,"after sampling================================%p",req.MRxD,h_intf.cb_rx_mac_monitor.MRxD);
			
			//$display("==================%d    %d===========",req.MRxDV,req.MCrS);
			//$display($time,"after sampling================================%p",req.MRxD);

				check2;
                
			
			if(h_config.input_write)begin
				rx_mac_input_monitor_port.write(payload_score_board);
			end	

         
		end
	endtask

	
	
	task check2;
		
		
		if(req.MCrS && req.MRxDV)
		
		  begin //{
		//$display("===============INPUT MONITOR=====mcrs=%d mrxdv= %d=========",req.MCrS,req.MRxDV);
		  
		    if(h_config.NOPRE == 0)
		      begin //{

		
						//$display($time,"============input monitor=MRxD===================%p",req.MRxD);
		                queue_with_preamble.push_back(req.MRxD);
						//$display($time,"===========input monitor===================queue_with_preamble size ==%d queue_with_preamble = %p",queue_with_preamble.size(),queue_with_preamble);
		
					//end	
					len = h_config.length_[k];
                     //$display("len = %0d      h_config.length_[0] %0d,%0d,%0d  The array length is $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %0d",len,h_config.length_[0],h_config.length_[1],h_config.length_[2],h_config.length_[k]);
					if(len<46)begin
						len = 46;
					end
					if(queue_with_preamble.size()==52+(len)*2)
		
					
					begin
                        k++;
		        	//=============================== PREAMBLE COMPARISION ===============

		            if(queue_with_preamble[0:13] == h_config.queue_preamble)
		              	begin
		               	  	$display($time,"len = %0d PACKET = %0d ****INPUT MONITOR**** PREAMBLE MATCHED ******** MRXD_PRE = %p      config pramble = %p",len,h_config.count,queue_with_preamble[0:13],h_config.queue_preamble);
								
		              	end
					else 
						begin
							$display($time,"len = %0d PACKET = %0d ***!!!!!!*INPUT MONITOR**** PREAMBLE NOT MATCHED *****!!!!!!*** MRXD_PRE = %p   AND PREAMBLE = %p",len,h_config.count,queue_with_preamble[0:17],h_config.queue_preamble);					
						end	
		        
						//========================= SFD COMPARISION =======================

		          	if(queue_with_preamble[14:15] == h_config.queue_sfd)
						begin
		                  	$display($time," PACKET = %0d ****INPUT MONITOR**** SFD MATCHED ********MRXD_SFD = %p   AND SFD = %p",h_config.count,queue_with_preamble[14:15],h_config.queue_sfd);
						end
					else 
						begin
							$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** SFD NOT MATCHED *****!!!!!!***MRXD_SFD = %p   AND SFD = %p",h_config.count,queue_with_preamble[14:15],h_config.queue_sfd);
									
						end
						
					//========================== DESTINATION ADDRESS COMPARISION ==================
		  
		            if(queue_with_preamble[16:27] == h_config.queue_dest_addr[h_config.count])
						begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** DESTINATION ADDRESS MATCHED ********MRXD_destination address = %p   AND destination address = %p",h_config.count,queue_with_preamble[16:27],h_config.queue_dest_addr[h_config.count]);
						
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** DESTINATION ADDRESS NOT MATCHED *****!!!!!!***MRXD_destination address = %p   AND destination address = %p",h_config.count,queue_with_preamble[16:27],h_config.queue_dest_addr[h_config.count]);	
						
						end
		        
		            //========================== SOURCE ADDRESS COMPARISION ==================

		         	if(queue_with_preamble[28:39] == h_config.queue_source_addr[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ***INPUT MONITOR***** source ADDRESS MATCHED ********MRXD_source address = %p   AND source address = %p",h_config.count,queue_with_preamble[28:39],h_config.queue_source_addr[h_config.count]);
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** source ADDRESS NOT MATCHED *****!!!!!!***MRXD_source address = %p   AND source address = %p",h_config.count,queue_with_preamble[28:39],h_config.queue_source_addr[h_config.count]);			
					//req.MRxDV =0;req.MCrS = 0;
		
				//	queue_with_preamble.delete();
				
						end
		          
		        	//========================== LENGTH COMPARISION ===========================

		            if(queue_with_preamble[40:43] == h_config.queue_length[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ***INPUT MONITOR***** LENGTH MATCHED ********MRXD_LENGTH = %p   AND LENGTH = %p",h_config.count,queue_with_preamble[40:43],h_config.queue_length[h_config.count]);
						//$display($time,"==========len=%p======bit len=%p===========number=%d==",h_config.length,h_config.queue_for_length,h_config.number_for_payload);

						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** LENGTH NOT MATCHED *****!!!!!!***MRXD_LENGTH = %p   AND LENGTH = %p",h_config.count,queue_with_preamble[40:43],h_config.queue_length[h_config.count]);			
					//req.MRxDV =0;req.MCrS = 0;
		
						end

		        	//========================== PAYLOAD COMPARISION ===========================

		           	if(queue_with_preamble[44:(44+(len)*2)-1] == h_config.queue_payload[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** PAYLOAD MATCHED ********MRXD_PAYLOAD = %p   AND PAYLOAD = %p",h_config.count,queue_with_preamble[44:(44+(len)*2)-1],h_config.queue_payload[h_config.count]);
                          	//repeat(len*2)begin
								//foreach
								payload_score_board =h_config.queue_payload[h_config.count];
								//$display("=============================================================scoreboard===payload=%p=========",payload_score_board);
								//i++;
							//end

						end
					else 
						begin
		                  $display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** PAYLOAD NOT MATCHED *****!!!!!!***MRXD_PAYLOAD = %p   AND PAYLOAD = %p",h_config.count,queue_with_preamble[44:(44+(len)*2)-1],h_config.queue_payload[h_config.count]);			
		
						end

		        	//========================== FCS COMPARISION ===========================

		           	if(queue_with_preamble[(44+(len)*2):52+(len)*2-1] == h_config.queue_fcs[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** FCS MATCHED ********MRXD_FCS = %p   AND FCS = %p",h_config.count,queue_with_preamble[(44+(len)*2):52+(len)*2-1],h_config.queue_fcs[h_config.count]);

					req.MRxDV =0;req.MCrS = 0;
						
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!***INPUT MONITOR** FCS NOT MATCHED *****!!!!!!***MRXD_FCS = %p   AND FCS = %p",h_config.count,queue_with_preamble[(44+(len)*2):52+(len)*2-1],h_config.queue_fcs[h_config.count]);			
					req.MRxDV =0;req.MCrS = 0;
		
						end
						queue_with_preamble.delete();
						h_config.input_write = 1;

		      end //}



		      //end //}
			req.MRxDV =0;req.MCrS = 0;
		      //k++;
		  end //}
		  else
		  begin
			  						//$display($time,"============input monitor=MRxD===================%p",req.MRxD);
		                queue_with_preamble.push_back(req.MRxD);
						//$display($time,"===========input monitor===================queue_with_preamble size ==%d queue_with_preamble = %p",queue_with_preamble.size(),queue_with_preamble);
		
					//end	
					len = h_config.length_[k];
                     //$display("len = %0d      h_config.length_[0] %0d,%0d,%0d  The array length is $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %0d",len,h_config.length_[0],h_config.length_[1],h_config.length_[2],h_config.length_[k]);
					if(len<46)begin
						len = 46;
					end
					if(queue_with_preamble.size()==38+(len)*2)
		
					
					begin
                        k++;
		        	//=============================== PREAMBLE COMPARISION ===============
/*
		            if(queue_with_preamble[0:13] == h_config.queue_preamble)
		              	begin
		               	  	$display($time,"len = %0d PACKET = %0d ****INPUT MONITOR**** PREAMBLE MATCHED ******** MRXD_PRE = %p      config pramble = %p",len,h_config.count,queue_with_preamble[0:13],h_config.queue_preamble);
								
		              	end
					else 
						begin
							$display($time,"len = %0d PACKET = %0d ***!!!!!!*INPUT MONITOR**** PREAMBLE NOT MATCHED *****!!!!!!*** MRXD_PRE = %p   AND PREAMBLE = %p",len,h_config.count,queue_with_preamble[0:17],h_config.queue_preamble);					
						end	
		        */
						//========================= SFD COMPARISION =======================

		          	if(queue_with_preamble[0:1] == h_config.queue_sfd)
						begin
		                  	$display($time," PACKET = %0d ****INPUT MONITOR**** SFD MATCHED ********MRXD_SFD = %p   AND SFD = %p",h_config.count,queue_with_preamble[0:1],h_config.queue_sfd);
						end
					else 
						begin
							$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** SFD NOT MATCHED *****!!!!!!***MRXD_SFD = %p   AND SFD = %p",h_config.count,queue_with_preamble[0:1],h_config.queue_sfd);
									
						end
						
					//========================== DESTINATION ADDRESS COMPARISION ==================
		  
		            if(queue_with_preamble[2:13] == h_config.queue_dest_addr[h_config.count])
						begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** DESTINATION ADDRESS MATCHED ********MRXD_destination address = %p   AND destination address = %p",h_config.count,queue_with_preamble[2:13],h_config.queue_dest_addr[h_config.count]);
						
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** DESTINATION ADDRESS NOT MATCHED *****!!!!!!***MRXD_destination address = %p   AND destination address = %p",h_config.count,queue_with_preamble[2:13],h_config.queue_dest_addr[h_config.count]);	
						
						end
		        
		            //========================== SOURCE ADDRESS COMPARISION ==================

		         	if(queue_with_preamble[14:25] == h_config.queue_source_addr[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ***INPUT MONITOR***** source ADDRESS MATCHED ********MRXD_source address = %p   AND source address = %p",h_config.count,queue_with_preamble[14:25],h_config.queue_source_addr[h_config.count]);
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** source ADDRESS NOT MATCHED *****!!!!!!***MRXD_source address = %p   AND source address = %p",h_config.count,queue_with_preamble[14:25],h_config.queue_source_addr[h_config.count]);			
					//req.MRxDV =0;req.MCrS = 0;
		
				//	queue_with_preamble.delete();
				
						end
		          
		        	//========================== LENGTH COMPARISION ===========================

		            if(queue_with_preamble[26:29] == h_config.queue_length[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ***INPUT MONITOR***** LENGTH MATCHED ********MRXD_LENGTH = %p   AND LENGTH = %p",h_config.count,queue_with_preamble[26:29],h_config.queue_length[h_config.count]);
						//$display($time,"==========len=%p======bit len=%p===========number=%d==",h_config.length,h_config.queue_for_length,h_config.number_for_payload);

						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** LENGTH NOT MATCHED *****!!!!!!***MRXD_LENGTH = %p   AND LENGTH = %p",h_config.count,queue_with_preamble[26:29],h_config.queue_length[h_config.count]);			
					//req.MRxDV =0;req.MCrS = 0;
		
						end

		        	//========================== PAYLOAD COMPARISION ===========================

		           	if(queue_with_preamble[30:(30+(len)*2)-1] == h_config.queue_payload[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** PAYLOAD MATCHED ********MRXD_PAYLOAD = %p   AND PAYLOAD = %p",h_config.count,queue_with_preamble[30:(30+(len)*2)-1],h_config.queue_payload[h_config.count]);
                          	//repeat(len*2)begin
								//foreach
								payload_score_board =h_config.queue_payload[h_config.count];
								//$display("=============================================================scoreboard===payload=%p=========",payload_score_board);
								//i++;
							//end

						end
					else 
						begin
		                  $display($time," PACKET = %0d ***!!!!!!**INPUT MONITOR*** PAYLOAD NOT MATCHED *****!!!!!!***MRXD_PAYLOAD = %p   AND PAYLOAD = %p",h_config.count,queue_with_preamble[30:(30+(len)*2)-1],h_config.queue_payload[h_config.count]);			
		
						end

		        	//========================== FCS COMPARISION ===========================

		           	if(queue_with_preamble[(30+(len)*2):38+(len)*2-1] == h_config.queue_fcs[h_config.count])
		              	begin
		                	$display($time," PACKET = %0d ****INPUT MONITOR**** FCS MATCHED ********MRXD_FCS = %p   AND FCS = %p",h_config.count,queue_with_preamble[(30+(len)*2):38+(len)*2-1],h_config.queue_fcs[h_config.count]);

					req.MRxDV =0;req.MCrS = 0;
						
						end
					else 
						begin
		                  	$display($time," PACKET = %0d ***!!!!!!***INPUT MONITOR** FCS NOT MATCHED *****!!!!!!***MRXD_FCS = %p   AND FCS = %p",h_config.count,queue_with_preamble[(30+(len)*2):38+(len)*2-1],h_config.queue_fcs[h_config.count]);			
					req.MRxDV =0;req.MCrS = 0;
		
						end
						queue_with_preamble.delete();
						h_config.input_write = 1;

		      end //}



			req.MRxDV =0;req.MCrS = 0;
		      //k++;
		  end //}



		  //end


		end
	endtask
endclass
