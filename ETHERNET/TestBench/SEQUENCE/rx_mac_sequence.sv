
//////////////////////////////////////////////////////////////
// IN THIS CLASS WE HAVE 
//
//
//////////////////////////////////////////////////////////////


class rx_mac_sequence_final extends uvm_sequence#(sequence_item);
  `uvm_object_utils(rx_mac_sequence_final)
  
  //declaring handle for the sequence_item
  sequence_item req;
  integer length;
  config_class h_config;    //---------- declaring handle for the config class -----------
  bit queue[$];
	virtual intf h_intf;
  //bit data = 'd1;
  
 		bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		int nibble_size;
		bit [3:0]nibble_da_to_payload[$];
		bit [31:0]generated_crc;
		bit [31:0]gen_fcs[$];



  //------------------- destination address -------------------
  bit [11:0][3:0] array_da ;

  //------------------- source address declaration -----------------------
  bit [11:0][3:0] array_sa ;

  //------------------- payload data 3 bytes int length field ---------------------
  bit [3:0][3:0] array_length;    

  //---------------- fcs data dedlaration  ---------------
  bit [7:0][3:0] array_fcs = {{6{1'b0,1'b1}},{5{{1'b1,1'b1},{3{1'b1,1'b0}}}}} ;
  
  int i = 0;    //-------------------- declaring variabale i for internal usage ---------------------
  int j=0,k=0;
  int l;
  bit [3:0] queue3[$];    //----------------- declaring queue to store packet --------------------
  int pad_bits;
  //<<<<<<<<<<<<<<<<<<<<<<< creating new construct >>>>>>>>>>>>>>>>>>>>>>>>
  function new(string name = "");
    super.new(name);
     assert(uvm_config_db#(config_class)::get(null,this.get_full_name,"ethernet_config_class",h_config));
     assert(uvm_config_db#(virtual intf)::get(null,this.get_full_name,"ethernet_interface",h_intf));            	//---- GETTING INTERFACE FROM TOP

  endfunction 
  
  
  //creation task body 
 	task body();
		req = sequence_item::type_id::create("req");
   		array_da = h_config.destination_addr;
		array_sa = h_config.source_addr;
     	//array_length =h_config.RXB_0 ;// h_config.length_[i];  

   //     `uvm_info("LEN",$sformatf("***************!!!!!!! The length_ data is %0p !!!!!!!****************",h_config.length_),UVM_LOW);
        array_length[0] =h_config.length_[0];
	 	repeat(h_config.RX_BD_NUM) begin
          //if (h_config.variable == l) begin
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!count = %0d !!!!!!!!!!!!!!!!!!!!!!!!!!!!!11 ",h_config.count);
           //`uvm_info("countANDl_value",$sformatf("***************!!!@@@ The count = %0d and l_value and is %0d @@@!!!****************",h_config.count,l),UVM_LOW);

			if(h_config.NOPRE)begin
				IFG_GAP;
				sfd;
				destination;
				source_address;
				length_task;
				payload_data;
				fcs;
				go_to_initial;

			end
			else
			begin
				IFG_GAP;
				preamble;
				sfd;
				destination;
				source_address;
				length_task;
				payload_data;
				fcs;
				go_to_initial;


			end
         l++;
  
        array_length[l] =h_config.length_[l];
		$display();
           //h_config.variable = 0;
     	 //end
        //h_config.count++;
 		end
	

  endtask  

	 task IFG_GAP;
		 for(int i=0;i<24;i++)
		 begin
			 start_item(req);
			 assert(req.randomize() with {MCrS==0;MRxDV==0;MRxD==0; MRxErr == 1'b0;});
			 finish_item(req);
		end
	endtask

  	task preamble; 
   		repeat(7*2) begin
			start_item(req);
			assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == 4'b0101; MCrS == 1'b1;});           
	   		finish_item(req);
			//queue3.push_back(req.MRxD);
		end
	endtask
     
   
   //<<<<<<<<<<<<<<<<<<<<<<<<<< passing sfd to the design >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   	task sfd;
		start_item(req);
		assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == 4'b0101; MCrS == 1'b1;});     
     	finish_item(req);
		//queue3.push_back(req.MRxD);    //-------------- loading sfd to queue (original queue) ---------------------

     	start_item(req);
		assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; req.MRxD == 4'b1101; MCrS == 1'b1;});
	 	finish_item(req);
 	endtask
   
  
   	//=============== passing destination address to the design ===================
   	task destination;
   		for(int i = 11; i >= 0; i--) begin              
    	start_item(req);   
        assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == array_da[i]; MCrS == 1'b1;});            
    	finish_item(req);        
     	queue3.push_back(array_da[i]);     
		h_config.queue_dest_addr[h_config.count].push_back(array_da[i]);
      end
  	endtask
   
     //<<<<<<<<<<<<<<<<<<<<<<< passing source address to the design >>>>>>>>>>>>>>>>>>>>>>>>>>>
   
   	task source_address;
   		for(int i = 11; i >= 0; i--) begin           
		start_item(req);
        assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == array_sa[i];  MCrS == 1'b1;});                 
      	finish_item(req);
 		queue3.push_back(array_sa[i]);        
     	h_config.queue_source_addr[h_config.count].push_back(array_sa[i]);
	end
  	endtask
   
   

   //<<<<<<<<<<<<<<<<<<<<<<<< length data into queue >>>>>>>>>>>>>>>>>>>>>>>>
   
   
    task length_task;
		$display("rx mac seq ==========================================================%d",h_config.length_[j]);
		start_item(req);
		
        assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == h_config.length_[j][11:8]; MCrS == 1'b1;});        
		queue3.push_back(req.MRxD);      //--------------------------------- passing length data into queue ----------------------------------
     	h_config.queue_length[h_config.count].push_back(req.MRxD);     
     	finish_item(req);

	  	start_item(req);
        assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == h_config.length_[j][15:12]; MCrS == 1'b1;});   
		queue3.push_back(req.MRxD);      //--------------------------------- passing length data into queue ----------------------------------
      	h_config.queue_length[h_config.count].push_back(req.MRxD);     
		finish_item(req);


	  	start_item(req);
        assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == h_config.length_[j][3:0]; MCrS == 1'b1;});     
	  	queue3.push_back(req.MRxD);      //--------------------------------- passing length data into queue ----------------------------------
     	h_config.queue_length[h_config.count].push_back(req.MRxD);          
     	finish_item(req);

	  	start_item(req);
		assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;req.MRxD == h_config.length_[j][7:4]; MCrS == 1'b1;});                     
		queue3.push_back(req.MRxD);      //--------------------------------- passing length data into queue ----------------------------------
     	h_config.queue_length[h_config.count].push_back(req.MRxD); 
		finish_item(req);

	 		`uvm_info("IN RX MAC SEQUENCE",$sformatf("QUEUE FOR LENGTH:%d",h_config.length_[j]),UVM_NONE);
		j++;
          
	endtask
	
	//<<<<<<<<<<<<<<<<<<<<<< randomizing payload data >>>>>>>>>>>>>>>>>>>>>>>>
   	
	task payload_data;
		if(h_config.length_[k]<46)
		begin
			if(h_config.PAD)begin
			pad_bits = 46 - h_config.length_[k];
			for(int i=0;i<(h_config.length_[k]*2);i++) 
			begin
			$display("---------------------LENGTH IS LESS THAN 46 ----------------------");
			start_item(req);
			assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; MCrS == 1'b1;});                        
			//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   			finish_item(req);
    		queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
			h_config.queue_payload[h_config.count].push_back(req.MRxD); 
			end	
			for(int i=0;i<(pad_bits*2);i++) 
			begin
			start_item(req);
			assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0;MRxD == 4'b0; MCrS == 1'b1;});                        
			//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   			finish_item(req);
    		queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
			h_config.queue_payload[h_config.count].push_back(req.MRxD); 
	 		`uvm_info("IN RX MAC SEQUENCE payload ",$sformatf("QUEUE FOR payload:%p",h_config.queue_payload[h_config.count]),UVM_NONE);

			end
			end
			else	$display("******************************** Drop the frame due to invalid pad and length less than 46***************************");
		end
		else if(h_config.length_[k]<1518)
		begin
   			for(int i=0;i<(h_config.length_[k]*2);i++) 
			begin
				//$display("---------------------LENGTH IS GREATER THAN 46 ----------------------");
				start_item(req);
				assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; MCrS == 1'b1;});                        
				//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   				finish_item(req);
    			queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
				h_config.queue_payload[h_config.count].push_back(req.MRxD); 
	 		//`uvm_info("IN RX MAC SEQUENCE payload ",$sformatf("LENGTH = %D   ---- QUEUE FOR payload:%p",h_config.length_[k],h_config.queue_payload[h_config.count]),UVM_NONE);
	 		end
	 		//	`uvm_info("IN RX MAC SEQUENCE",$sformatf("DATA RANDOM:%p",queue3),UVM_NONE);
		end
		else if(1518<h_config.length_[k]<2048)
		begin
			if(h_config.HUGEN)
			begin
   			for(int i=0;i<(h_config.length_[k]*2);i++) 
			begin
				//$display("---------------------LENGTH IS GREATER THAN 1518 and <2000 ----------------------");
				start_item(req);
				assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; MCrS == 1'b1;});                        
				//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   				finish_item(req);
    			queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
				h_config.queue_payload[h_config.count].push_back(req.MRxD); 
	 		//`uvm_info("IN RX MAC SEQUENCE payload ",$sformatf("LENGTH = %D   ---- QUEUE FOR payload:%p",h_config.length_[k],h_config.queue_payload[h_config.count]),UVM_NONE);
	 		end
			end
			else
			begin
			$display("******************************** Drop the frame due to invalid HUGEN and length in between 1518 and 2048***************************");
  			for(int i=0;i<(h_config.length_[k]*2);i++) 
			begin
				//$display("---------------------LENGTH IS GREATER THAN 1518 and <2000 ----------------------");
				start_item(req);
				assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; MCrS == 1'b1;});                        
				//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   				finish_item(req);
    			queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
				h_config.queue_payload[h_config.count].push_back(req.MRxD); 
	 		//`uvm_info("IN RX MAC SEQUENCE payload ",$sformatf("LENGTH = %D   ---- QUEUE FOR payload:%p",h_config.length_[k],h_config.queue_payload[h_config.count]),UVM_NONE);
			end
			end

		end
		else 
		begin			
			$display("******************************** Drop the frame due to invalid length ***************************");
     			for(int i=0;i<(h_config.length_[k]*2);i++) 
			begin
				//$display("---------------------LENGTH IS GREATER THAN 1518 and <2000 ----------------------");
				start_item(req);
				assert(req.randomize() with {MRxDV == 1'b1; MRxErr == 1'b0; MCrS == 1'b1;});                        
				//`uvm_info("IN RX MAC SEQUENCE",$sformatf("length:%p %d %d",h_config.length_,i,req.MRxD),UVM_NONE); 
   				finish_item(req);
    			queue3.push_back(req.MRxD);             //------------------- passing randomized data into queue ---------------
				h_config.queue_payload[h_config.count].push_back(req.MRxD); 
	 		//`uvm_info("IN RX MAC SEQUENCE payload ",$sformatf("LENGTH = %D   ---- QUEUE FOR payload:%p",h_config.length_[k],h_config.queue_payload[h_config.count]),UVM_NONE);
			end
		end
   		k++;
		nibble_da_to_payload = queue3;
		//$display($time,"------------->generated crc is = %0h     nibble_da_to_payload =%0p    queue3 =%p",generated_crc,nibble_da_to_payload,queue3)

   		crc_generation();

 		gen_fcs = {generated_crc[31:28],generated_crc[27:24],generated_crc[23:20],generated_crc[19:16],generated_crc[15:12],generated_crc[11:8],generated_crc[7:4],generated_crc[3:0]};//Generated crc storing as nibbles 
	endtask

   	//<<<<<<<<<<<<<<<<<<<<<< generating FCS >>>>>>>>>>>>>>>>>>>>>>>>
	
   	task fcs;	
		for(int i=0;i<8;i++)
		begin
			start_item(req);
			assert(req.randomize() with {MCrS==1;MRxDV==1;MRxErr == 1'b0;MRxD == gen_fcs[i];});
    		h_config.queue_fcs[h_config.count].push_back(req.MRxD);      				
			finish_item(req);
	 //		`uvm_info("IN RX MAC SEQUENCE fcs ",$sformatf("LENGTH = %D   ---- QUEUE FOR fcs:%p",h_config.length_[k],h_config.queue_fcs[h_config.count]),UVM_NONE);

		end
	endtask

	task go_to_initial;
    	start_item(req);   
        assert(req.randomize() with {MRxDV == 1'b0; MRxErr == 1'b0; MCrS == 1'b0;});               
		finish_item(req);
	endtask

// ethernet crc generation logic // 

	task crc_generation();
	/*	bit [3:0] data;
		bit [31:0] crc_variable = 32'hffff_ffff; // initializing the variable
		bit [31:0] crc_next; 
		int nibble_size;
		*/
		nibble_size = nibble_da_to_payload.size;
	
			for(int i=0;i<nibble_size;i++) 
			begin
			data = nibble_da_to_payload.pop_front;
			data = {<<{data}}; 

				crc_next[0] =    (data[0] ^ crc_variable[28]); 
			crc_next[1] =    (data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29]); 
			crc_next[2] =    (data[2] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[30]); 
			crc_next[3] =    (data[3] ^ data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30] ^ crc_variable[31]); 
			crc_next[4] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[0]; 
			crc_next[5] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[1]; 
			crc_next[6] =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[2]; 
			crc_next[7] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[3]; 
			crc_next[8] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[4]; 
			crc_next[9] =    (data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[5]; 
			crc_next[10] =    (data[3] ^ data[2] ^ data[0] ^ crc_variable[28] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[6]; 
			crc_next[11] =    (data[3] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[31]) ^ crc_variable[7]; 
			crc_next[12] =    (data[2] ^ data[1] ^ data[0] ^ crc_variable[28] ^ crc_variable[29] ^ crc_variable[30]) ^ crc_variable[8]; 
			crc_next[13] =    (data[3] ^ data[2] ^ data[1] ^ crc_variable[29] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[9]; 
			crc_next[14] =    (data[3] ^ data[2] ^ crc_variable[30] ^ crc_variable[31]) ^ crc_variable[10]; 
			crc_next[15] =    (data[3] ^ crc_variable[31]) ^ crc_variable[11]; 
			crc_next[16] =    (data[0] ^ crc_variable[28]) ^ crc_variable[12]; 
			crc_next[17] =    (data[1] ^ crc_variable[29]) ^ crc_variable[13]; 
			crc_next[18] =    (data[2] ^ crc_variable[30]) ^ crc_variable[14]; 
			crc_next[19] =    (data[3] ^ crc_variable[31]) ^ crc_variable[15]; 
			crc_next[20] = 	  crc_variable[16]; 
			crc_next[21] =    crc_variable[17]; 
			crc_next[22] =    (data[0] ^ crc_variable[28]) ^ crc_variable[18]; 
			crc_next[23] =    (data[1] ^ data[0] ^ crc_variable[29] ^ crc_variable[28]) ^ crc_variable[19]; 
			crc_next[24] =    (data[2] ^ data[1] ^ crc_variable[30] ^ crc_variable[29]) ^ crc_variable[20]; 
			crc_next[25] =    (data[3] ^ data[2] ^ crc_variable[31] ^ crc_variable[30]) ^ crc_variable[21]; 
			crc_next[26] =    (data[3] ^ data[0] ^ crc_variable[31] ^ crc_variable[28]) ^ crc_variable[22]; 
			crc_next[27] =    (data[1] ^ crc_variable[29]) ^ crc_variable[23]; 
			crc_next[28] =    (data[2] ^ crc_variable[30]) ^ crc_variable[24]; 
			crc_next[29] =    (data[3] ^ crc_variable[31]) ^ crc_variable[25]; 
			crc_next[30] =    crc_variable[26]; 
			crc_next[31] =    crc_variable[27]; 

			crc_variable = crc_next;

			end

		generated_crc[31:28] = {~crc_variable[28],~crc_variable[29],~crc_variable[30],~crc_variable[31]};
		generated_crc[27:24] = {~crc_variable[24],~crc_variable[25],~crc_variable[26],~crc_variable[27]};
		generated_crc[23:20] = {~crc_variable[20],~crc_variable[21],~crc_variable[22],~crc_variable[23]};
		generated_crc[19:16] = {~crc_variable[16],~crc_variable[17],~crc_variable[18],~crc_variable[19]};
		generated_crc[15:12] = {~crc_variable[12],~crc_variable[13],~crc_variable[14],~crc_variable[15]};
		generated_crc[11:8] = {~crc_variable[8],~crc_variable[9],~crc_variable[10],~crc_variable[11]};
		generated_crc[7:4] = {~crc_variable[4],~crc_variable[5],~crc_variable[6],~crc_variable[7]};
		generated_crc[3:0] = {~crc_variable[0],~crc_variable[1],~crc_variable[2],~crc_variable[3]};
	
	endtask

/*	NOTE :
	generated_crc is 32 bit data, convert it to nibbles, append the nibbles to the frame (da to payload frame), drive the nibbles (da to crc) onto req.MRxD signal.

	To check if the above task is working correctly, put this task in ethernet rx agent monitor, use sampled nibble queue by popping crc (to generate crc we only need frame from da to payload) and storing it (to store crc generated by DUT), this task should generate crc which is same as crc from DUT.  
*/
 
endclass






