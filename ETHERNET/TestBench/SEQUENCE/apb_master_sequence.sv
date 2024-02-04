////////////////////////////////////////////////////////////////////////////
//      APB MASTER SEQUENCE CLASS TO CONFIGURE THE ETHERNET REGISTERS     //
////////////////////////////////////////////////////////////////////////////
/*
`include "apb_master_sequence.sv"
	`include "test_case_1.sv"
	`include "test_case_2.sv"
	`include "test_case_3.sv"
	`include "test_case_4.sv"
	`include "test_case_5.sv"
	`include "test_case_6.sv"
	`include "test_case_7.sv"
	`include "test_case_8.sv"
	`include "test_case_9.sv"
	`include "test_case_10.sv"
	`include "test_case_11.sv"
	`include "test_case_12.sv"
	`include "test_case_21.sv"
	`include "test_case_22.sv"
	`include "test_case_23.sv"
	`include "test_case_24.sv"
	`include "test_case_25.sv"
	`include "test_case_26.sv"
	`include "test_case_34.sv"
	`include "test_case_108.sv"
	`include "test_case_97.sv"
	`include "test_case_82.sv"
	`include "test_case_88.sv"
	`include "test_case_76.sv"
	`include "test_case_69.sv"
	`include "test_case_62.sv"
	`include "test_case_55.sv"
	`include "test_case_50.sv"
These sequences are merged here......
*/
class sequence_1 extends uvm_sequence #(sequence_item);
	`uvm_object_utils(sequence_1)                   						//------ FACTORY REGISTRATION
	
	config_class h_config;													//------ CONFIG CLASS HANDLE
	virtual intf h_intf;													//------ INTERFACE INSTANCE

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "sequence_1");
		super.new(name);
		assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));		//------ GETTING CONFIG CLASS FROM TOP
    	assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));			//------ GETTING INTERFACE FROM TOP
	endfunction

	int index;  //---------length queue index
  	int RXBD_ADDR;
	
	/////////////////////////////////////////////////////////////
	//     WRITE TASK IS TO WRITE THE REGISTER OF ETHERNET     //
	/////////////////////////////////////////////////////////////

	task write_register;

		//---------------CONFIG CLASS RANDOMIZATION -------------------//
		repeat(3)begin
			assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==1;TXB_M==1;
										PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
										LEN inside {54,54,54};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
			h_config.length_.push_back(h_config.LEN);
		end


 		//---------------TX_BD_NUM CONFIGURATION --------------//
		start_item(req);
      	assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      	h_config.TX_BD_NUM=req.pwdata_i;
      	h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      	finish_item(req);

		//----------------MII ADDR CONFIGURATION-----------------------//
		start_item(req);
      	assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      	h_config.MIIADDRESS=req.pwdata_i;
      	finish_item(req);

		//---------------MAC_ADDR-0 CONFIGURATION--------------// 
      	start_item(req);
      	assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      	h_config.MAC_ADDR0=req.pwdata_i;
      	finish_item(req);

		//---------------MAC_ADDR-1 CONFIGURATION------------//
       	start_item(req);
       	assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
      	h_config.MAC_ADDR1=req.pwdata_i;
       	finish_item(req);

		//---------------INT MASK CONFIGURATION--------------//
     	start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     	h_config.INT_MASK=req.pwdata_i;
     	finish_item(req);

		//----------------RX BD CONFIGURATION----------------//
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	  	begin
			h_config.LEN = h_config.length_[index];
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

			`uvm_info("IN REG CONFIGURATION" ,$sformatf("LEN IN REG:%b",h_config.LEN),UVM_NONE);
			finish_item(req);
		
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
	  	end
		
		//---------------INT SOURCE CONFIGURATION--------------//
		start_item(req);
		assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    	h_config.INT_SOURCE=req.pwdata_i;
   		finish_item(req);


		//----------------MODER CONFIGURATION---------------//
      	start_item(req);
      	assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      	h_config.MODER=req.pwdata_i;
      	finish_item(req);

  	endtask

	/////////////////////////////////////////////////////////////
	//      READ TASK IS TO READ THE REGISTER OF ETHERNET      //
	/////////////////////////////////////////////////////////////

  	task read_register;

		//---------------INT SOURCE CONFIGURATION--------------//
    	start_item(req);
    	assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
		$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    	finish_item(req);

		//---------------TX_BD_NUM CONFIGURATION --------------//
      	start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      	finish_item(req);

		//----------------MII ADDR CONFIGURATION-----------------------//
      	start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      	finish_item(req);

		//---------------MAC_ADDR-0 CONFIGURATION--------------// 
		start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      	finish_item(req);
     
		//---------------MAC_ADDR-1 CONFIGURATION------------//
       	start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       	finish_item(req);

		//---------------INT MASK CONFIGURATION--------------//
     	start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     	finish_item(req);

		//----------------RX BD CONFIGURATION----------------//
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;
	  	end

		//----------------MODER CONFIGURATION---------------//
		start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      	finish_item(req);
  	endtask

	///////////////////////////////////////////////////////////////////////
	//    IN THE TASK BODY WE HAVE TO INVOKE THE WRITE AND READ TASKS    //
	///////////////////////////////////////////////////////////////////////
	
  	task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
			write_register;
    	//	#12;
   		//	read_register;
		end
		else
		//if(h_intf.int_o)
		begin
			//---------------INT SOURCE CONFIGURATION--------------//
			start_item(req);
    		assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
			//$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    		finish_item(req);
		end
    endtask
endclass
  
//=====================================test case-1=====================================
class RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==1;RXB==1;TXE==1;TXB==1;
											 RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==70;EMPTY==1;RXPNT==10;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);

//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);

 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
    task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;
    //#12;
   	//	read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass


//==================================================================testcase2================

class RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(2)begin
		    assert(h_config.randomize() with{RXE==1;RXB==1;TXE==1;TXB==1;
											 RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside{62,70};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);

 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d126; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
     task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;
  //  #12;
   	//	read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass


//==================================================================testcase3================

class RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==1;RXB==1;TXE==1;TXB==1;
											 RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==46;EMPTY==1;RXPNT==65;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
    task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;
   // #12;
   	//	read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass

//==================================================================testcase4================

class RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(5)begin
		    assert(h_config.randomize() with{RXE==1;RXB==1;TXE==1;TXB==1;
											 RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside{78,86,94,102,110};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d123; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
    task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;
    //#12;
   	//	read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass

 
//=====================================test case-5=====================================
class RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==1;RXB==1;TXE==1;TXB==1;
											 RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1518;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	      h_config.length_.push_back(h_config.LEN);

//--------------------CONFIG CLASS RANDOMIZATION-----------------------------

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);

 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
    task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
		if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;
 //   #12;
  // 		read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass
//=====================================test case-6=====================================

class RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1526;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	       h_config.length_.push_back(h_config.LEN);
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		  $display("========================master seq======h_config.LEN=%d  index=%d",h_config.LEN,h_config.length_[index]);
	  
		req = sequence_item::type_id::create("sequence_item");
    	if(h_config.do_ == 1) 
		//if (!(h_intf.int_o))
		begin
    	write_register;

 //   #12;
  // 		read_register;
	end
	else
		//if(h_intf.int_o)
		begin
			//-----------------------------INT SOURCE configuration 
   				 start_item(req);
    			assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
				$display($time,"-----------reading of int sourceeeeeee =%d",req.prdata_o);
    			finish_item(req);
		end
    endtask
endclass

//=====================================test case-7=====================================
class RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1518;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	       h_config.length_.push_back(h_config.LEN);
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
   // #12;
   	//	read_register;
    endtask
endclass


//=====================================test case-8=====================================
class RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1518;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	        h_config.length_.push_back(h_config.LEN);
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
  //  #12;
   //		read_register;
    endtask
endclass

//-------------------------------------------------------------------------------------
//------------------------------------------maxfl ,pad hugen combinations--------------
//=====================================test case-9=====================================
class RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;				 
											 LEN == 46;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass


//=====================================test case-10=====================================
class RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside {50,58,62};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass


//=====================================test case-11=====================================
class RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==45;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
   // #12;
   	//	read_register;
    endtask
endclass


//=====================================test case-12=====================================
class RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside {30,35,40};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------TX_EN,RX_EN BASED CONDITIONS------------------------
//=====================================test case-21====================================
class RECEIVER_CHECK_WITH_TxEN_0_RxEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_TxEN_0_RxEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_TxEN_0_RxEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==0;
											 LEN==68;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass


//=====================================test case-22=====================================
class RECEIVER_CHECK_WITH_TxEN_0_RxEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_TxEN_0_RxEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_TxEN_0_RxEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(8)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside {70,74,78,82,86,90,94,98};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d120; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass

//=====================================test case-23=====================================
class RECEIVER_CHECK_WITH_TxEN_1_RxEN_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_TxEN_1_RxEN_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_TxEN_1_RxEN_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==1;RXEN==0;
											 LEN==69;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass


//=====================================test case-24=====================================
class RECEIVER_CHECK_WITH_TxEN_1_RxEN_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_TxEN_1_RxEN_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_TxEN_1_RxEN_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==1;RXEN==1;
											 LEN==69;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
    // end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass

//=====================================test case-25=====================================
//==================================RxEN,NOPRE,IFG======================================
class RECEIVER_MODER_CHECK_WITH_NOPRE_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_NOPRE_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_NOPRE_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==94;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass


//=====================================test case-26=====================================
//==================================RxEN,NOPRE,IFG======================================
class RECEIVER_MODER_CHECK_WITH_NOPRE_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_NOPRE_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_NOPRE_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==1;TXEN==0;RXEN==1;
											 LEN==102;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass

//=====================================test case-27=====================================
//==================================RxEN,NOPRE,IFG======================================
class RECEIVER_MODER_CHECK_WITH_IFG_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_IFG_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_IFG_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(10)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside{106};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
    // end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass

//=====================================test case-28=====================================
//==================================RxEN,NOPRE,IFG======================================
class RECEIVER_MODER_CHECK_WITH_IFG_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_IFG_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_IFG_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(10)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==1;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside{98,102,106,110,114,118,122,126,130,138};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==1;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d118; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass
//=====================================test case-29=====================================
//================================LEN,RxEN,NOPRE,IFG,HUGEN===================================
class RECEIVER_CHECK_WITH_PAD_0_NOPRE_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PAD_0_NOPRE_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PAD_0_NOPRE_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN inside {70,74,82};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   	//	read_register;
    endtask
endclass

//=====================================test case-30=====================================
//================================LEN,RxEN,NOPRE,IFG,HUGEN===================================
class RECEIVER_CHECK_WITH_PAD_0_NOPRE_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PAD_0_NOPRE_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PAD_0_NOPRE_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==1;TXEN==0;RXEN==1;
											 LEN>46;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-31=====================================
//================================LEN,RxEN,NOPRE,IFG,HUGEN===================================
class RECEIVER_CHECK_WITH_PAD_1_NOPRE_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PAD_1_NOPRE_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PAD_1_NOPRE_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>46;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-32=====================================
//================================LEN,RxEN,NOPRE,IFG,HUGEN===================================
class RECEIVER_CHECK_WITH_PAD_1_NOPRE_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PAD_1_NOPRE_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PAD_1_NOPRE_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==1;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==1;TXEN==0;RXEN==1;
											 LEN>46;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
 //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-33=====================================
//================================LEN,RxEN,NOPRE,,HUGEN===================================
class RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1530;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass


//=====================================test case-34=====================================
//================================LEN,RxEN,NOPRE,,HUGEN===================================
class RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==1;TXEN==0;RXEN==1;
											 LEN==1526;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass

//=====================================test case-35=====================================
//================================LEN,RxEN,NOPRE,,HUGEN===================================
class RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN==1522;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass

//=====================================test case-36=====================================
//================================LEN,RxEN,NOPRE,,HUGEN===================================
class RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        //repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==1;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==1;TXEN==0;RXEN==1;
											 LEN==1518;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
endclass

//=====================================test case-37=====================================
//================================PRO BRO COMBINATIONS==================================

class RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-38=====================================
//================================PRO BRO COMBINATIONS==================================

class RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==1;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-39=====================================
//================================PRO BRO COMBINATIONS==================================

class RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==1;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-40=====================================
//================================PRO BRO COMBINATIONS==================================
class RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==1;BRO==1;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-41=====================================
//================================PRO MISS COMBINATIONS==================================
class RECEIVER_CHECK_WITH_PRO_0_MISS_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PRO_0_MISS_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PRO_0_MISS_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-42=====================================
//================================PRO MISS COMBINATIONS==================================
class RECEIVER_CHECK_WITH_PRO_0_MISS_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_PRO_0_MISS_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_PRO_0_MISS_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==1;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-43=====================================
//================================RXEN EMPTY COMBINATIONS==================================
class RECEIVER_CHECK_WITH_RxEN_1_E_0 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_RxEN_1_E_0)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_RxEN_1_E_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==0;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

//=====================================test case-44=====================================
//================================RXEN EMPTY COMBINATIONS==================================
class RECEIVER_CHECK_WITH_RxEN_1_E_1 extends uvm_sequence #(sequence_item);
//--------------factory registration
	`uvm_object_utils(RECEIVER_CHECK_WITH_RxEN_1_E_1)
  config_class h_config;
//------------------constructor------------	
	function new(string name = "RECEIVER_CHECK_WITH_RxEN_1_E_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;

	        repeat(3)begin
		    assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;
											 RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;
											 PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;
											 LEN>1500;EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
//--------------------CONFIG CLASS RANDOMIZATION-----------------------------
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
      finish_item(req);
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
       finish_item(req);
//----------------------------------int mask config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
//----------------//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		  h_config.LEN = h_config.length_[index];
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});

		finish_item(req);
		
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
//----------------------------------INT MASK config
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
 //--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;
	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     	assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
 //----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
endclass

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//test case no:108

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass

//test_case no:107

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:106

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:105

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:104

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:103

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:102

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:101

class BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:100

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:99

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:98

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:97

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:96

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:95

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:94

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:93

class BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:92

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:91

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
      assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
     assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
      assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		 assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass




//test_case no:90

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize()with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize()with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass




//test_case no:89

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:82

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:81

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:80

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:79

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:78

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:77

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:88

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:87

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:86

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:85

class BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:84

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:83

class BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:76

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:75

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:74

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass

//test_case no:73

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:72

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:71

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass




//test_case no:70

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:69

class GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:68

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:67

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:66

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass


//test_case no:65

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass




//test_case no:64

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



//test_case no:63

class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;
//================================================ write task==================================================
   task write_register;
	        repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     $display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    #12;
   		read_register;
    endtask
  
  
endclass



	//test_case no:62

	class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass



	//test_case no:61

	class GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==0;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass


	//test_case no:60

	class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass


	//test_case no:59

	class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass


	//test_case no:58

	class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass


	//test_case no:57

	class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    #12;
	   		read_register;
	    endtask
	  
	  
	endclass


	//test_case no:56

	class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

	//--------------factory registration
		`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1)
	  config_class h_config;
		
	//------------------constructor------------	
		function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1");
			super.new(name);
		 assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

		endfunction
		int index;  //---------length queue index
	  	int RXBD_ADDR;

		
	//================================================ write task==================================================
	   task write_register;
			repeat(3)begin

		assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN inside {46,64,72};EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
		  h_config.length_.push_back(h_config.LEN);
	     end
	     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	     $display($time,"===================================================================");


		 
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d125; req.pwrite_i==1;});
	      h_config.TX_BD_NUM=req.pwdata_i;
	      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
	     $display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
	      finish_item(req);

		 
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
	      h_config.MIIADDRESS=req.pwdata_i;
	      finish_item(req);

	   
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
	      h_config.MAC_ADDR0=req.pwdata_i;
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_1,h_config.byte_0}; req.pwrite_i==1;});
	       h_config.MAC_ADDR1=req.pwdata_i;
					$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

	       finish_item(req);

		   
	//----------------------------------int mask config
	   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
	     h_config.INT_MASK=req.pwdata_i;
	     finish_item(req);
	     

	//-----------------------------int source configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
	    h_config.INT_SOURCE=req.pwdata_i;
	    finish_item(req);
	     
	//-------------------------------------------RX BD CONFIGURATION
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

			repeat(h_config.RX_BD_NUM)
		 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		//$display($time,"incremented i value=%d",RXBD_ADDR);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		//$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
			
			start_item(req);
		//$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
			finish_item(req); 
			RXBD_ADDR = RXBD_ADDR+8;
			index++; 
			//i++;
		  end
	/*
		//	repeat(h_config.RX_BD_NUM)
		  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			//int i=1024+(h_config.TX_BD_NUM*8);
		$display("incremented i value=%d",i);
			  h_config.LEN = h_config.length_[index];
			start_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

		$display($time,"------h_config.LEN = %d ",h_config.LEN);
			assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

			finish_item(req);
		$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
			start_item(req);

			assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req); 
			index++; 
			//i++;
		  end*/
		  //index =0;

	/*		  h_config.LEN = h_config.length_[1];

			start_item(req);
			assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
			finish_item(req);

			start_item(req);

			assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
			finish_item(req);
	 */    
	//-----------------------------------------------MODER config
	      start_item(req);
	      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
	      h_config.MODER=req.pwdata_i;

	      finish_item(req);
	  endtask

	    
	//================================================ read task==================================================
	   task read_register;
	      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
	//-----------------------------MAC_ADDR-0 configuration 
		  
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
	      finish_item(req);
	     
	//-----------------------------MAC_ADDR-1 configuration 
	       start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
	       finish_item(req);
	     
	//-----------------------------INT SOURCE configuration 
	    start_item(req);
	    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
	    finish_item(req);
	     
	//----------------------------------INT MASK config
	     
	     start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
	     finish_item(req);
	     
	//--------------------------------------------TX_BD_NUM CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
	      finish_item(req);

	//-------------------------------------------RX BD CONFIGURATION
			
			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			repeat(h_config.RX_BD_NUM)

		  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
		  begin
			start_item(req);
			assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
			finish_item(req);

			start_item(req);

			assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
			finish_item(req);
			RXBD_ADDR = RXBD_ADDR+8;

		  end
	//--------------------------------------------MII ADDR CONFIG
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
	      finish_item(req);
	//-----------------------------------------------MODER config
	      start_item(req);
	     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
	      finish_item(req);
	  endtask
	  
	  
	  
	//----------------------------task body---------------------------
	  task body();
			req = sequence_item::type_id::create("sequence_item");
	    	write_register;
	    //#12;
	   		//read_register;
	    endtask
	  
	  
	endclass

//test_case no:55

class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==1498;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
   // #12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:54

class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==1502;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:53

class GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==0;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==1506;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:52

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==1510;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:51

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==1514;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass



//test_case no:50

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==94;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:49

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==0;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==86;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:48

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==82;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
    // end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:47

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	       // repeat(3)begin

        assert(h_config.randomize() with{RXE==1;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==78;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass



//test_case no:46

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==1;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==74;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
  
endclass


//test_case no:45

class GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0 extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0)
  config_class h_config;
	
//------------------constructor------------	
	function new(string name = "GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));

	endfunction
	int index;  //---------length queue index
  	int RXBD_ADDR;

	
//================================================ write task==================================================
   task write_register;
	        //repeat(3)begin

        assert(h_config.randomize() with{RXE==0;RXB==0;TXE==0;TXB==0;RXE_M==1;RXB_M==1;TXE_M==0;TXB_M==0;PAD==0;HUGEN==0;FULLD==0;LOOPBCK==0;IFG==0;PRO==0;BRO==0;NOPRE==0;TXEN==0;RXEN==1;LEN==54;EMPTY==1;RXPNT==8;IRQ==1;MISS==0;TL==0;CRC==0;});
	  h_config.length_.push_back(h_config.LEN);
     //end
     //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
     //$display($time,"===================================================================");


	 
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h20; req.pwdata_i=='d127; req.pwrite_i==1;});
      h_config.TX_BD_NUM=req.pwdata_i;
      h_config.RX_BD_NUM=128 - h_config.TX_BD_NUM;
     //$display($time,"===============================TXBDNUM=%d",h_config.TX_BD_NUM);
      finish_item(req);

	 
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h30; req.pwdata_i=={27'b0,h_config.FIAD}; req.pwrite_i==1;});
      h_config.MIIADDRESS=req.pwdata_i;
      finish_item(req);

   
//-----------------------------MAC_ADDR-0 configuration 
	  
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h40; req.pwdata_i=={h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2}; req.pwrite_i==1;});
      h_config.MAC_ADDR0=req.pwdata_i;
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
       assert(req.randomize()with{req.paddr_i=='h44; req.pwdata_i=={16'b0,h_config.byte_0,h_config.byte_1}; req.pwrite_i==1;});
       h_config.MAC_ADDR1=req.pwdata_i;
				//$display($time,"=========================APB master sequence mac addr1 =%d ",req.pwdata_i);

       finish_item(req);

	   
//----------------------------------int mask config
   //  h_config.randomize() with{RXE_M==0;RXB_M==0;TXE_M==0;TXB_M==0;});
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwdata_i=={28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M}; req.pwrite_i==1;}); 
     h_config.INT_MASK=req.pwdata_i;
     finish_item(req);
     

//-----------------------------int source configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04; req.pwdata_i=={28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB}; req.pwrite_i==1;});
    h_config.INT_SOURCE=req.pwdata_i;
    finish_item(req);
     
//-------------------------------------------RX BD CONFIGURATION
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);

		repeat(h_config.RX_BD_NUM)
	 // for(int i='h0+(h_config.TX_BD_NUM*8);i<'h7ff;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        //$display($time,"incremented i value=%d",RXBD_ADDR);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        //$display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
		
		start_item(req);
        //$display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwdata_i==RXBD_ADDR+4; req.pwrite_i==1;});
		finish_item(req); 
		RXBD_ADDR = RXBD_ADDR+8;
		index++; 
		//i++;
	  end
/*
	//	repeat(h_config.RX_BD_NUM)
	  for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		//int i=1024+(h_config.TX_BD_NUM*8);
        $display("incremented i value=%d",i);
		  h_config.LEN = h_config.length_[index];
		start_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=length=%p",h_config.length_);

        $display($time,"------h_config.LEN = %d ",h_config.LEN);
		assert(req.randomize () with {req.paddr_i==i; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
                $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);

		finish_item(req);
        $display($time,"-=-=-=-=-=-=-=-=-=pwdata=%p",req.pwdata_i);
		start_item(req);

		assert(req.randomize () with {req.paddr_i==i+4; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req); 
		index++; 
		//i++;
	  end*/
	  //index =0;

/*		  h_config.LEN = h_config.length_[1];

		start_item(req);
		assert(req.randomize() with {req.paddr_i==2024; req.pwdata_i=={h_config.LEN,h_config.EMPTY,h_config.IRQ,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,1'b0,h_config.CRC,1'b0}; req.pwrite_i==1;});
		finish_item(req);

		start_item(req);

		assert(req.randomize() with {req.paddr_i==2028; req.pwdata_i=={h_config.RXPNT}; req.pwrite_i==1;});
		finish_item(req);
 */    
//-----------------------------------------------MODER config
      start_item(req);
      assert(req.randomize()with{req.paddr_i=='h00; req.pwdata_i=={16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,h_config.RXEN}; req.pwrite_i==1;});
      h_config.MODER=req.pwdata_i;

      finish_item(req);
  endtask

    
//================================================ read task==================================================
   task read_register;
      //--------------------CONFIG CLASS RANDOMIZATION-----------------------------
//-----------------------------MAC_ADDR-0 configuration 
          
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h40;req.pwrite_i==0;});
      finish_item(req);
     
//-----------------------------MAC_ADDR-1 configuration 
       start_item(req);
     assert(req.randomize()with{req.paddr_i=='h44;  req.pwrite_i==0;});
       finish_item(req);
     
//-----------------------------INT SOURCE configuration 
    start_item(req);
    assert(req.randomize()with{req.paddr_i=='h04;req.pwrite_i==0;});
    finish_item(req);
     
//----------------------------------INT MASK config
     
     start_item(req);
     assert(req.randomize()with{req.paddr_i=='h08; req.pwrite_i==0;}); 
     finish_item(req);
     
//--------------------------------------------TX_BD_NUM CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h20; req.pwrite_i==0;});
      finish_item(req);

//-------------------------------------------RX BD CONFIGURATION
		
		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)

	  //for(int i=1024+(h_config.TX_BD_NUM*8);i<2048;i=i+8)
	  begin
		start_item(req);
		assert(req.randomize () with {req.paddr_i==RXBD_ADDR;  req.pwrite_i==0;});
		finish_item(req);

		start_item(req);

		assert(req.randomize () with {req.paddr_i==RXBD_ADDR+4; req.pwrite_i==0;});
		finish_item(req);
		RXBD_ADDR = RXBD_ADDR+8;

	  end
//--------------------------------------------MII ADDR CONFIG
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h30;req.pwrite_i==0;});
      finish_item(req);
//-----------------------------------------------MODER config
      start_item(req);
     assert(req.randomize()with{req.paddr_i=='h00;  req.pwrite_i==0;});
      finish_item(req);
  endtask
  
  
  
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
    	write_register;
    //#12;
   		//read_register;
    endtask
  
endclass


