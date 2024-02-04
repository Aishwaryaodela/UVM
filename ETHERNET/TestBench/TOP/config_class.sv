
	/////////////////////////////////////////////////////////////////
	//     IN THIS CONFIG CLASS WE HAVE TO DECLARE THE VARIBLES    //
	//  WHICH ARE USED TO FUTURE USE OR USED BY THE OTHER CLASSES  //
	/////////////////////////////////////////////////////////////////

class config_class extends uvm_object;
  	
	`uvm_object_utils(config_class)										//------ FACTORY REGISTRATION 
  	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////

  	function new(string name = "");
  	  super.new(name);
  	endfunction 
  	
  	int value = 20;
  	bit flag = 1;
  	reg done = 0 ;
  	
  	int packet_count = 'd2;

  	int count = 1'd1;
  	
  	//---------- DECLARING QUEUES FOR COMPARISION ------------
	
  	bit [3:0] queue_preamble[$] = {4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101,4'b0101};  //-------- declaring queue to store preamble ---------
  	
  	bit [3:0] queue_sfd[$] = {4'b0101,4'b1101};  //-------- declaring queue to store sfd ---------
  	
  	bit [3:0] queue_dest_addr[int][$];  //--------- declaring unbounded queue with int index type(like unpacked queue) to store destination address for the each packet ----------
  	
  	bit [3:0] queue_source_addr[int][$];  //--------- declaring unbounded queue with int index type(like unpacked queue) to store source address for the each packet ----------
  	
  	bit [3:0] queue_length[int][$];  //--------- declaring unbounded queue with int index type(like unpacked queue) to store length of the payload for the each packet -----------
  	
  	bit [3:0] queue_payload[int][$];  //----------- declaring unbounded queue with int index type(like unpacked queue) to store payload data for the each packet -----------
  	
  	bit [3:0] queue_fcs[int][$];  //----------- declaring unbounded queue with int index type(like unpacked queue) to store fcs data for the each packet ---------
  	
  	bit [3:0] queue_packet[int][$];   //------------- declaring unbounded queue with int index type(like unpacked queue) to store data for the each packet --------------  
  	
  	
  	bit complete;
  	
  	bit data1 = 'd1;   //----------------- declaring one bit data for packet generation ----------------------
  	

  	
  	
  	bit [15:0]length_[$];
  	logic config_data;

  	bit [3:0]data=4;



  	bit int_o;

	//////////////////////////////////
	//      INTERNAL REGISTERS      //
	//////////////////////////////////

  	bit [31:0]	MODER,
  				INT_SOURCE,
				INT_MASK,
				TX_BD_NUM,
				RX_BD_NUM,
				MIIADDRESS,
				MAC_ADDR0,
				MAC_ADDR1,
				TXD;

	////////////////////////////////////			
	//      BYTES FOR MAC_ADDR_0      //
	////////////////////////////////////

	bit [7:0]byte_2 = 8'b0;
   	bit	[7:0]byte_3 = 8'b0;
	bit [7:0]byte_4 = 8'b0;
   	bit	[7:0]byte_5 = 8'b0 ;

	/////////////////////////////////////			
	//       BYTES FOR MAC_ADDR_1      //
	/////////////////////////////////////

	bit [7:0]byte_0 = 8'b1010_1011 ;
   	bit	[7:0]byte_1 = 8'b1100_1101;
	
	/////////////////////////////////////			
	//      FIAD BIT FOR MII_ADDR      //
	/////////////////////////////////////

	bit[4:0]FIAD = 'h0C;

	
  	bit [31:16] RXB_0 = 'd46;
  	bit [15:0] RXB_1;
  	bit [31:0] RXBD = {RXB_0,RXB_1};


	bit [11:0] [3:0] source_addr = { {{3{1'b0}},FIAD[4]},FIAD[3:0],4'b0000,4'b0000,4'b0000,4'b0000,4'b0000,4'b0000,4'b0000,4'b0000,4'b0000,4'b0000};
 	bit [11:0] [3:0] destination_addr = {byte_0[7:4],byte_0[3:0],byte_1[7:4],byte_1[3:0],byte_2[7:4],byte_2[3:0],byte_3[7:4],byte_3[3:0],byte_4[7:4],byte_4[3:0],byte_5[7:4],byte_5[3:0]};
   
	////////////////////////////////////////////
  	//      MODER REGISTER INTERNAL PINS      //
	////////////////////////////////////////////
	
 	rand bit 	PAD ,		//----------------PIN 15
  				HUGEN,		//----------------PIN 14
  				FULLD,		//----------------PIN 10
  				LOOPBCK,	//----------------PIN 7
  				IFG,		//----------------PIN 6
  				PRO,		//----------------PIN 5
  				BRO,		//----------------PIN 3
  				NOPRE, 		//----------------PIN 2
  				TXEN,		//----------------PIN 1
  				RXEN;		//----------------PIN 0
  

	//////////////////////////////////////////////////
  	//       INT SOURCE REGISTER INTERNAL PINS      //
	//////////////////////////////////////////////////
 
 	rand bit	RXE,			//---------------------PIN 3
  				RXB,			//---------------------PIN 2
   				TXE,			//---------------------PIN 1
  				TXB;			//---------------------PIN 0
  
	/////////////////////////////////////////////////
  	//       INT MASK REGISTER INTERNAL PINS       //
	/////////////////////////////////////////////////

 	rand bit 	RXE_M,			//---------------------PIN 3
  				RXB_M,			//---------------------PIN 2
   				TXE_M,			//---------------------PIN 1
  				TXB_M;			//---------------------PIN 0
  
	///////////////////////////////////////////////////////////
  	//      RX BUFFER DESCRIPTER REGISTER INTERNAL PINS      //
	///////////////////////////////////////////////////////////
  
 	rand bit  	[15:0]LEN;		//--------------------	PIN 31 TO 16
 	rand bit  		  EMPTY,	//--------------------	PIN 15
 	 			  	  IRQ,		//--------------------	PIN 14
 	   		  	      MISS,     //-------------------- 	PIN 7
 	 			   	  TL,		//--------------------	PIN 3 TOO LONG
 	 			  	  CRC;		//--------------------	PIN 1 RX CRC ERR
 	rand bit   [31:0] RXPNT;	//--------------------	RX POINTER 32 BITS
  		

	bit [3:0]BRO_ADDR[$] = {'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111,'b1111};
	bit input_write;
	bit output_write;
	bit done_int_o;
	bit do_ = 0;
endclass





