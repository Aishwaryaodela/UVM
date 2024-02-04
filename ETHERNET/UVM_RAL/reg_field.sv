
class MODER_REG extends uvm_reg;

	`uvm_object_utils(MODER_REG)		//--------- FACTORY REGISTRATION

	rand uvm_reg_field RXEN;			//--------- 0
	rand uvm_reg_field TXEN;			//--------- 1
	rand uvm_reg_field NOPRE;			//--------- 2
	rand uvm_reg_field BRO;				//--------- 3
	uvm_reg_field UNUSED_4;				//--------- 4
	rand uvm_reg_field PRO;				//--------- 5
	rand uvm_reg_field IFG;				//--------- 6
	rand uvm_reg_field LOOPBCK;			//--------- 7
	uvm_reg_field UNUSED_8;				//--------- 8
	rand uvm_reg_field FULLD;			//--------- 10
	uvm_reg_field UNUSED_11;			//--------- 11

	rand uvm_reg_field HUGEN;			//--------- 14
	rand uvm_reg_field PAD;				//--------- 15
	uvm_reg_field UNUSED_16;			//--------- 16


	function new(string name = "MODER_REG");
		super.new(name,32,UVM_NO_COVERAGE);		
	endfunction

	function void build();
		RXEN = uvm_reg_field::type_id::create("RXEN");
		RXEN.configure(.parent(this),
						.size(1),
						.lsb_pos(0),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		TXEN = uvm_reg_field::type_id::create("TXEN");
		TXEN.configure(.parent(this),
						.size(1),
						.lsb_pos(1),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		NOPRE = uvm_reg_field::type_id::create("NOPRE");
		NOPRE.configure(.parent(this),
						.size(1),
						.lsb_pos(2),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);	
		BRO = uvm_reg_field::type_id::create("BRO");
		BRO.configure(.parent(this),
						.size(1),
						.lsb_pos(3),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		UNUSED_4 = uvm_reg_field::type_id::create("UNUSED_4");
		UNUSED_4.configure(.parent(this),
						.size(1),
						.lsb_pos(4),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		PRO = uvm_reg_field::type_id::create("PRO");
		PRO.configure(.parent(this),
						.size(1),
						.lsb_pos(5),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		IFG = uvm_reg_field::type_id::create("IFG");
		IFG.configure(.parent(this),
						.size(1),
						.lsb_pos(6),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		LOOPBCK = uvm_reg_field::type_id::create("LOOPBCK");
		LOOPBCK.configure(.parent(this),
						.size(1),
						.lsb_pos(7),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		UNUSED_8 = uvm_reg_field::type_id::create("UNUSED_8");
		UNUSED_8.configure(.parent(this),
						.size(2),
						.lsb_pos(8),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(0),
						.individually_accessible(0)
					);
		FULLD = uvm_reg_field::type_id::create("FULLD");
		FULLD.configure(.parent(this),
						.size(1),
						.lsb_pos(10),
						.access("RW"),
						.volatile(0),
						.reset(0),
						.has_reset(1),
						.is_rand(1),
						.individually_accessible(0)
					);
		UNUSED_11 = uvm_reg_field::type_id::create("UNUSED_11");
		UNUSED_11.configure(.parent(this),
							.size(3),
							.lsb_pos(11),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);

		HUGEN = uvm_reg_field::type_id::create("HUGEN");
		HUGEN.configure(.parent(this),
							.size(1),
							.lsb_pos(14),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
		PAD = uvm_reg_field::type_id::create("PAD");
		PAD.configure(.parent(this),
							.size(1),
							.lsb_pos(15),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
		UNUSED_16 = uvm_reg_field::type_id::create("UNUSED_16");
		UNUSED_16.configure(.parent(this),
							.size(16),
							.lsb_pos(16),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);

	endfunction

endclass
	
	class INT_SOURCE extends uvm_reg;
		
		`uvm_object_utils(INT_SOURCE)		//------ FACTORY REGISTRATION
		rand uvm_reg_field TXB; 			//------ 0
		rand uvm_reg_field TXE;				//------ 1
		rand uvm_reg_field RXB;				//------ 2
		rand uvm_reg_field RXE;				//------ 3
		uvm_reg_field UNUSED;				//------ 4
		
		function new(string name = "INT_SOURCE");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(28),
							.lsb_pos(4),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			TXB = uvm_reg_field::type_id::create("TXB");
			TXB.configure(.parent(this),
							.size(1),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			TXE = uvm_reg_field::type_id::create("TXE");
			TXE.configure(.parent(this),
							.size(1),
							.lsb_pos(1),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			RXB = uvm_reg_field::type_id::create("RXB");
			RXB.configure(.parent(this),
							.size(1),
							.lsb_pos(2),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			RXE = uvm_reg_field::type_id::create("RXE");
			RXE.configure(.parent(this),
							.size(1),
							.lsb_pos(3),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);

		endfunction

	endclass


	class INT_MASK extends uvm_reg;

		`uvm_object_utils(INT_MASK)			//------ FACTORY REGISTRATION
		
		uvm_reg_field UNUSED;				//------ 4

		rand uvm_reg_field TXB_M;			//------ 0
		rand uvm_reg_field TXE_M;			//------ 1
		rand uvm_reg_field RXF_M;			//------ 2
		rand uvm_reg_field RXE_M;			//------ 3

		function new(string name = "INT_MASK");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(28),
							.lsb_pos(4),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			TXB_M = uvm_reg_field::type_id::create("TXB_M");
			TXB_M.configure(.parent(this),
							.size(1),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			TXE_M = uvm_reg_field::type_id::create("TXE_M");
			TXE_M.configure(.parent(this),
							.size(1),
							.lsb_pos(1),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			RXF_M = uvm_reg_field::type_id::create("RXF_M");
			RXF_M.configure(.parent(this),
							.size(1),
							.lsb_pos(2),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			RXE_M = uvm_reg_field::type_id::create("RXE_M");
			RXE_M.configure(.parent(this),
							.size(1),
							.lsb_pos(3),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);

		endfunction

	endclass

	class TX_BD_NUM extends uvm_reg;

		`uvm_object_utils(TX_BD_NUM)		//------ FACTORY REGISTRATION

		uvm_reg_field UNUSED;				//------ 8
		rand uvm_reg_field TXBD;			//------ 0

		function new(string name = "TXBD");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(24),
							.lsb_pos(8),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			TXBD = uvm_reg_field::type_id::create("TXBD");
			TXBD.configure(.parent(this),
							.size(8),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
		endfunction

	endclass

	class MIIADDRESS extends uvm_reg;

		`uvm_object_utils(MIIADDRESS)		//------ FACTORY REGISTRATION

		rand uvm_reg_field FIAD;			//------ 0

		uvm_reg_field UNUSED;				//------ 5

		function new(string name = "MIIADDRESS");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(27),
							.lsb_pos(5),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			FIAD = uvm_reg_field::type_id::create("FIAD");
			FIAD.configure(.parent(this),
							.size(5),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
		endfunction

	endclass

	class MAC_ADDR0 extends uvm_reg;
		
		`uvm_object_utils(MAC_ADDR0)		//------ FACTORY REGISTRATION

		rand uvm_reg_field BYTE_5;			//------ 0
		rand uvm_reg_field BYTE_4;			//------ 8
		rand uvm_reg_field BYTE_3;			//------ 16
		rand uvm_reg_field BYTE_2;			//------ 24

		function new(string name = "MAC_ADDR0");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			BYTE_5 = uvm_reg_field::type_id::create("BYTE_5");
			BYTE_5.configure(.parent(this),
							.size(8),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			BYTE_4 = uvm_reg_field::type_id::create("BYTE_4");
			BYTE_4.configure(.parent(this),
							.size(8),
							.lsb_pos(8),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			BYTE_3 = uvm_reg_field::type_id::create("BYTE_3");
			BYTE_3.configure(.parent(this),
							.size(8),
							.lsb_pos(16),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			BYTE_2 = uvm_reg_field::type_id::create("BYTE_2");
			BYTE_2.configure(.parent(this),
							.size(8),
							.lsb_pos(24),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
		endfunction

	endclass

	class MAC_ADDR1 extends uvm_reg;
		
		`uvm_object_utils(MAC_ADDR1)		//------ FACTORY REGISTRATION

		rand uvm_reg_field BYTE_1;			//------ 0
		rand uvm_reg_field BYTE_0;			//------ 8
		 uvm_reg_field UNUSED;				//------ 16

		function new(string name = "MAC_ADDR1");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			BYTE_1 = uvm_reg_field::type_id::create("BYTE_1");
			BYTE_1.configure(.parent(this),
							.size(8),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			BYTE_0 = uvm_reg_field::type_id::create("BYTE_0");
			BYTE_0.configure(.parent(this),
							.size(8),
							.lsb_pos(8),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(16),
							.lsb_pos(16),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
		endfunction

	endclass

	class TX_OFFSET_0 extends uvm_reg;

		`uvm_object_utils(TX_OFFSET_0)		//------ FACTORY REGISTRATION

		rand uvm_reg_field IRQ;				//------ 14
		rand uvm_reg_field RD;				//------ 15
		rand uvm_reg_field LEN;				//------ 16
		uvm_reg_field UNUSED;				//------ 0

		function new(string name = "TX_OFFSET_0");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			LEN = uvm_reg_field::type_id::create("LEN");
			LEN.configure(.parent(this),
							.size(16),
							.lsb_pos(16),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			IRQ = uvm_reg_field::type_id::create("IRQ");
			IRQ.configure(.parent(this),
							.size(1),
							.lsb_pos(14),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			RD = uvm_reg_field::type_id::create("RD");
			RD.configure(.parent(this),
							.size(1),
							.lsb_pos(15),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			UNUSED = uvm_reg_field::type_id::create("UNUSED");
			UNUSED.configure(.parent(this),
							.size(14),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
		endfunction

	endclass

	class TX_OFFSET_4 extends uvm_reg;

		`uvm_object_utils(TX_OFFSET_4)		//------ FACTORY REGISTRATION

		rand uvm_reg_field TXPNT;			//------ 0

		function new(string name = "TX_OFFSET_4");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			TXPNT = uvm_reg_field::type_id::create("TXPNT");
			TXPNT.configure(.parent(this),
							.size(32),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);

		endfunction

	endclass


	class RX_OFFSET_0 extends uvm_reg;

		`uvm_object_utils(RX_OFFSET_0)		//------ FACTORY REGISTRATION

		rand uvm_reg_field CRC;				//------ 1
		rand uvm_reg_field M;				//------ 7
		rand uvm_reg_field IRQ;				//------ 14
		rand uvm_reg_field E;				//------ 15	
		rand uvm_reg_field LEN;				//------ 16		
		uvm_reg_field UNUSED_0;				//------ 0
		uvm_reg_field UNUSED_2;				//------ 2
		uvm_reg_field UNUSED_8;				//------ 8

		function new(string name = "RX_OFFSET_0");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			LEN = uvm_reg_field::type_id::create("LEN");
			LEN.configure(.parent(this),
							.size(16),
							.lsb_pos(16),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			E = uvm_reg_field::type_id::create("E");
			E.configure(.parent(this),
							.size(1),
							.lsb_pos(15),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			IRQ = uvm_reg_field::type_id::create("IRQ");
			IRQ.configure(.parent(this),
							.size(1),
							.lsb_pos(14),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
					);
			M = uvm_reg_field::type_id::create("M");
			M.configure(.parent(this),
							.size(1),
							.lsb_pos(7),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			CRC = uvm_reg_field::type_id::create("CRC");
			CRC.configure(.parent(this),
							.size(1),
							.lsb_pos(1),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);
			UNUSED_0 = uvm_reg_field::type_id::create("UNUSED_0");
			UNUSED_0.configure(.parent(this),
							.size(1),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			UNUSED_2 = uvm_reg_field::type_id::create("UNUSED_2");
			UNUSED_2.configure(.parent(this),
							.size(5),
							.lsb_pos(2),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);
			UNUSED_8 = uvm_reg_field::type_id::create("UNUSED_8");
			UNUSED_8.configure(.parent(this),
							.size(6),
							.lsb_pos(8),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(0),
							.individually_accessible(0)
						);

		endfunction

	endclass

	class RX_OFFSET_4 extends uvm_reg;

		`uvm_object_utils(RX_OFFSET_4)		//------ FACTORY REGISTRATION

		rand uvm_reg_field RXPNT;			//------ 0

		function new(string name = "RX_OFFSET_4");
			super.new(name,32,UVM_NO_COVERAGE);
		endfunction

		function void build();
			RXPNT = uvm_reg_field::type_id::create("RXPNT");
			RXPNT.configure(.parent(this),
							.size(32),
							.lsb_pos(0),
							.access("RW"),
							.volatile(0),
							.reset(0),
							.has_reset(1),
							.is_rand(1),
							.individually_accessible(0)
						);

		endfunction

	endclass


	class ETHERNET_REG_BLOCK extends uvm_reg_block;

		`uvm_object_utils(ETHERNET_REG_BLOCK)

		rand MODER_REG REG_MODER;
		rand INT_SOURCE REG_INT_SOURCE;
		rand INT_MASK REG_INT_MASK;
		rand MIIADDRESS REG_MIIADDRESS;
		rand MAC_ADDR1 REG_MAC_ADDR1;
		rand MAC_ADDR0 REG_MAC_ADDR0;
		//rand TX_OFFSET_0 REG_TX_OFFSET_0;
		//rand TX_OFFSET_4 REG_TX_OFFSET_4;
		rand RX_OFFSET_0 REG_RX_OFFSET_0[128];
		rand RX_OFFSET_4 REG_RX_OFFSET_4[128];
		rand TX_BD_NUM REG_TX_BD_NUM;
		int RXBD_ADDR;
		uvm_reg_map map;
		int count;
	
		config_class h_config;
		
		function new(string name = "ETHERNET_REG_BLOCK");
			super.new(name,UVM_NO_COVERAGE);
         	assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));			
		endfunction

		function void build();
			REG_MODER = MODER_REG::type_id::create("REG_MODER");
			REG_MODER.build();
			REG_MODER.configure(this);
    		REG_MODER.add_hdl_path_slice("MODEROut",0,32);      // name, offset, bit-width

			REG_INT_SOURCE = INT_SOURCE::type_id::create("REG_INT_SOURCE");
			REG_INT_SOURCE.build();
			REG_INT_SOURCE.configure(this);
    		REG_INT_SOURCE.add_hdl_path_slice("INT_SOURCEOut",0,32);      // name, offset, bit-width

			REG_INT_MASK = INT_MASK::type_id::create("REG_INT_MASK");
			REG_INT_MASK.build();
			REG_INT_MASK.configure(this);
    		REG_INT_MASK.add_hdl_path_slice("INT_MASKOut",0,32);      // name, offset, bit-width

			REG_MIIADDRESS = MIIADDRESS::type_id::create("REG_MIIADDRESS");
			REG_MIIADDRESS.build();
			REG_MIIADDRESS.configure(this);
    		REG_MIIADDRESS.add_hdl_path_slice("MIIADDRESSOut",0,32);      // name, offset, bit-width

			REG_MAC_ADDR0 = MAC_ADDR0::type_id::create("REG_MAC_ADDR0");
			REG_MAC_ADDR0.build();
			REG_MAC_ADDR0.configure(this);
    		REG_MAC_ADDR0.add_hdl_path_slice("MAC_ADDR0Out",0,32);      // name, offset, bit-width

			REG_MAC_ADDR1 = MAC_ADDR1::type_id::create("REG_MAC_ADDR1");
			REG_MAC_ADDR1.build();
			REG_MAC_ADDR1.configure(this);
    		REG_MAC_ADDR1.add_hdl_path_slice("MAC_ADDR1Out",0,32);      // name, offset, bit-width

			REG_TX_BD_NUM = TX_BD_NUM::type_id::create("REG_TX_BD_NUM");
			REG_TX_BD_NUM.build();
			REG_TX_BD_NUM.configure(this);
    		REG_TX_BD_NUM.add_hdl_path_slice("TX_BD_NUMOut",0,32);      // name, offset, bit-width
			
			//REG_TX_OFFSET_0 = TX_OFFSET_0::type_id::create("REG_TX_OFFSET_0");
			//REG_TX_OFFSET_0.build();
			//REG_TX_OFFSET_0.configure(this);
			//REG_TX_OFFSET_4 = TX_OFFSET_4::type_id::create("REG_TX_OFFSET_4");
			//REG_TX_OFFSET_4.build();
			//REG_TX_OFFSET_4.configure(this);
			repeat(h_config.RX_BD_NUM) begin
			REG_RX_OFFSET_4[count] = RX_OFFSET_4::type_id::create("REG_RX_OFFSET_4[count]");
			REG_RX_OFFSET_4[count].build();
			REG_RX_OFFSET_4[count].configure(this);

			REG_RX_OFFSET_4[count].add_hdl_path_slice("REG_RX_OFFSET_4",0,32);
			REG_RX_OFFSET_0[count] = RX_OFFSET_0::type_id::create("REG_RX_OFFSET_0[count]");
			REG_RX_OFFSET_0[count].build();
			REG_RX_OFFSET_0[count].configure(this);
			REG_RX_OFFSET_0[count].add_hdl_path_slice("REG_RX_OFFSET_0",0,32);
			count++;
			end
			count = 0;

			map = create_map("map",'h0,4,UVM_LITTLE_ENDIAN);

			map.add_reg(REG_MODER,32'h00,"RW");
			map.add_reg(REG_INT_SOURCE,32'h04,"RW");
			map.add_reg(REG_INT_MASK,32'h08,"RW");
			map.add_reg(REG_TX_BD_NUM,32'h20,"RW");
			map.add_reg(REG_MIIADDRESS,32'h30,"RW");
			map.add_reg(REG_MAC_ADDR0,32'h40,"RW");
			map.add_reg(REG_MAC_ADDR1,32'h44,"RW");
			//map.add_reg(REG_TX_OFFSET_0,32'd1024,"RW");
			//map.add_reg(REG_TX_OFFSET_4,32'd1028,"RW");

			RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
			//$display($time,"=============FEILD = %D ",RXBD_ADDR);
			repeat(h_config.RX_BD_NUM)
				begin
					map.add_reg(REG_RX_OFFSET_0[count],RXBD_ADDR,"RW");
					map.add_reg(REG_RX_OFFSET_4[count],RXBD_ADDR+4,"RW");
					RXBD_ADDR = RXBD_ADDR + 8;
					count++;
				end


    		add_hdl_path("top.DUT.ethreg1");
			
			lock_model();
		endfunction


	endclass

