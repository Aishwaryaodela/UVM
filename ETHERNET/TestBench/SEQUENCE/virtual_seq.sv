
//------------ sequence class



class virtual_sequence extends uvm_sequence #(sequence_item);

//--------------factory registration
	`uvm_object_utils(virtual_sequence)
  config_class h_config;

	`uvm_declare_p_sequencer(virtual_sequencer)

	virtual intf h_intf;

sequence_1 h_seq_config;

rx_mac_sequence_final h_rx_mac_seq_final;

RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_0 test_case1;
RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_1 test_case2;
RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_0 test_case3;
RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_1 test_case4;
//---------------max frame length with pad hugen---------------
RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_0 test_case5;
RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_1 test_case6;
RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_0 test_case7;
RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_1 test_case8;
//----------------------min frame length with pad hugen-------
RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_0 test_case9;
RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_1 test_case10;
RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_0 test_case11;
RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1 test_case12;
//------------------ txen and rxen checks--------------
RECEIVER_CHECK_WITH_TxEN_0_RxEN_0 test_case13;
RECEIVER_CHECK_WITH_TxEN_0_RxEN_1 test_case14;
RECEIVER_CHECK_WITH_TxEN_1_RxEN_0 test_case15;
RECEIVER_CHECK_WITH_TxEN_1_RxEN_1 test_case16;
//---------------------------nopre with rxen=1-----------
RECEIVER_MODER_CHECK_WITH_NOPRE_0 test_case17;
RECEIVER_MODER_CHECK_WITH_NOPRE_1 test_case18;
//---------------------------ifg with rxen=1-----------
RECEIVER_MODER_CHECK_WITH_IFG_0 test_case19;
RECEIVER_MODER_CHECK_WITH_IFG_1 test_case20;
//-------------------- pad and nopre combinations checks---
RECEIVER_CHECK_WITH_PAD_0_NOPRE_0 test_case21;
RECEIVER_CHECK_WITH_PAD_0_NOPRE_1 test_case22;
RECEIVER_CHECK_WITH_PAD_1_NOPRE_0 test_case23;
RECEIVER_CHECK_WITH_PAD_1_NOPRE_1 test_case24;
//--------------hugen no pre combination checks---
RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0 test_case25;
RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1 test_case26;
RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0 test_case27;
RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1 test_case28;
//-----------------------pro bro combinations----
RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_0 test_case29;
RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_1 test_case30;
RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_0 test_case31;
RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_1 test_case32;
//------------ pro miss combination----------
RECEIVER_CHECK_WITH_PRO_0_MISS_0 test_case33;
RECEIVER_CHECK_WITH_PRO_0_MISS_1 test_case34;
//---------------------rxen==1 empty----
RECEIVER_CHECK_WITH_RxEN_1_E_0 test_case35;
RECEIVER_CHECK_WITH_RxEN_1_E_1 test_case36;

GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0 test_case_45;  
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1 test_case_46;
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0 test_case_47;
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1  test_case_48;

GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0  test_case_49;
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1  test_case_50;
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0  test_case_51;
GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1  test_case_52;

GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0  test_case_53;
GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1  test_case_54;
GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0  test_case_55;
GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1  test_case_56;

	GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0  test_case_57;
	GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1  test_case_58;
	GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0  test_case_59;
	GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1  test_case_60;

	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0  test_case_61;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1  test_case_62;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0  test_case_63;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1  test_case_64;
	
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0  test_case_65;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1  test_case_66;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0  test_case_67;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1  test_case_68;

	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0  test_case_69;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1  test_case_70;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0  test_case_71;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1  test_case_72;

	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0  test_case_73;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1  test_case_74;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0  test_case_75;
	GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1  test_case_76;

	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0   test_case_77;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1   test_case_78;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0   test_case_79;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1   test_case_80;

	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0   test_case_81;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1   test_case_82;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0   test_case_83;
	BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1   test_case_84;

	BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0   test_case_85;
	BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1   test_case_86;
	BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0   test_case_87;
  	BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1   test_case_88;

        BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0   test_case_89;
        BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1   test_case_90;
        BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0   test_case_91;
	BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1   test_case_92;

	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0   test_case_93;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1   test_case_94;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0   test_case_95;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1   test_case_96;

	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0   test_case_97;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1   test_case_98;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0   test_case_99;
	BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1   test_case_100;

	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0   test_case_101;
	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1   test_case_102;
	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0   test_case_103;
	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1   test_case_104;
	BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0   test_case_105;
        BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1   test_case_106;
        BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0   test_case_107;
        BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1   test_case_108;

//------------------constructor------------	
	function new(string name = "virtual_sequence");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));
    	assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));			//---- GETTING INTERFACE FROM TOP
		 
//---------------------------memory creation-------------------------
h_seq_config=sequence_1::type_id::create("h_seq_config");

h_rx_mac_seq_final=rx_mac_sequence_final :: type_id ::create("h_rx_mac_seq_final");

test_case1=RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_0::type_id::create("test_case1");
test_case2=RECEIVER_CHECK_WITH_CORRECT_FL_PAD_0_HUGEN_1::type_id::create("test_case2");
test_case3=RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_0::type_id::create("test_case3");
test_case4=RECEIVER_CHECK_WITH_CORRECT_FL_PAD_1_HUGEN_1::type_id::create("test_case4");

test_case5=RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_0::type_id::create("test_case5");
test_case6= RECEIVER_CHECK_WITH_MAXFL_PAD_0_HUGEN_1::type_id::create("test_case6");
test_case7=RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_0::type_id::create("test_case7");
test_case8=RECEIVER_CHECK_WITH_MAXFL_PAD_1_HUGEN_1::type_id::create("test_case8");

test_case9=RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_0::type_id::create("test_case9");
test_case10=RECEIVER_CHECK_WITH_MINFL_PAD_0_HUGEN_1::type_id::create("test_case10");
test_case11=RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_0::type_id::create("test_case11");
test_case12=RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1::type_id::create("test_case12");

test_case13=RECEIVER_CHECK_WITH_TxEN_0_RxEN_0::type_id::create("test_case13");
test_case14=RECEIVER_CHECK_WITH_TxEN_0_RxEN_1::type_id::create("test_case14");
test_case15=RECEIVER_CHECK_WITH_TxEN_1_RxEN_0::type_id::create("test_case15");
test_case16=RECEIVER_CHECK_WITH_TxEN_1_RxEN_1::type_id::create("test_case16");

test_case17=RECEIVER_MODER_CHECK_WITH_NOPRE_0::type_id::create("test_case17");
test_case18=RECEIVER_MODER_CHECK_WITH_NOPRE_1::type_id::create("test_case18");

test_case19=RECEIVER_MODER_CHECK_WITH_IFG_0::type_id::create("test_case19");
test_case20=RECEIVER_MODER_CHECK_WITH_IFG_1::type_id::create("test_case20");

test_case21=RECEIVER_CHECK_WITH_PAD_0_NOPRE_0::type_id::create("test_case21");
test_case22=RECEIVER_CHECK_WITH_PAD_0_NOPRE_1::type_id::create("test_case22");
test_case23=RECEIVER_CHECK_WITH_PAD_1_NOPRE_0::type_id::create("test_case23");
test_case24=RECEIVER_CHECK_WITH_PAD_1_NOPRE_1::type_id::create("test_case24");

test_case25=RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0::type_id::create("test_case25");
test_case26=RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1::type_id::create("test_case26");
test_case27=RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0::type_id::create("test_case27");
test_case28=RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1::type_id::create("test_case28");

test_case29=RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_0::type_id::create("test_case29");
test_case30=RECEIVER_MODER_CHECK_WITH_PRO_0_BRO_1::type_id::create("test_case30");
test_case31=RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_0::type_id::create("test_case31");
test_case32=RECEIVER_MODER_CHECK_WITH_PRO_1_BRO_1::type_id::create("test_case32");

test_case33=RECEIVER_CHECK_WITH_PRO_0_MISS_0::type_id::create("test_case33");
test_case34=RECEIVER_CHECK_WITH_PRO_0_MISS_1::type_id::create("test_case34");

test_case35=RECEIVER_CHECK_WITH_RxEN_1_E_0::type_id::create("test_case35");
test_case36=RECEIVER_CHECK_WITH_RxEN_1_E_1::type_id::create("test_case36");


        test_case_45   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0 :: type_id :: create("test_case_45");  
        test_case_46   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1 :: type_id :: create("test_case_46");
	    test_case_47   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0 :: type_id :: create("test_case_47");
        test_case_48   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1 :: type_id :: create("test_case_48");
                          
        test_case_49   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0 :: type_id :: create("test_case_49");
        test_case_50   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1 :: type_id :: create("test_case_50");
        test_case_51   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0 :: type_id :: create("test_case_51");
        test_case_52   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1 :: type_id :: create("test_case_52");
                                                                                          
        test_case_53   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0 :: type_id :: create("test_case_53");
        test_case_54   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1 :: type_id :: create("test_case_54");
        test_case_55   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0 :: type_id :: create("test_case_55");
        test_case_56   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1 :: type_id :: create("test_case_56");
                                                                                          
        test_case_57   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0 :: type_id :: create("test_case_57");
        test_case_58   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1 :: type_id :: create("test_case_58");
        test_case_59   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0 :: type_id :: create("test_case_59");
        test_case_60   =   GOOD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1 :: type_id :: create("test_case_60");
                                                                                          
        test_case_61   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0 :: type_id :: create("test_case_61");
        test_case_62   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1 :: type_id :: create("test_case_62");
        test_case_63   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0 :: type_id :: create("test_case_63");
        test_case_64   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1 :: type_id :: create("test_case_64");
                          
        test_case_65   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0 :: type_id :: create("test_case_65");
        test_case_66   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1 :: type_id :: create("test_case_66");
        test_case_67   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0 :: type_id :: create("test_case_67");
        test_case_68   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1 :: type_id :: create("test_case_68");
                                                                             
        test_case_69   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0 :: type_id :: create("test_case_69");
        test_case_70   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1 :: type_id :: create("test_case_70");
        test_case_71   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0 :: type_id :: create("test_case_71");
        test_case_72   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1 :: type_id :: create("test_case_72");
                                                                             
        test_case_73   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0 :: type_id :: create("test_case_73");
        test_case_74   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1 :: type_id :: create("test_case_74");
        test_case_75   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0 :: type_id :: create("test_case_75");
        test_case_76   =   GOOD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1 :: type_id :: create("test_case_76");
                                                                             
        test_case_77   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_0  :: type_id :: create("test_case_77");
        test_case_78   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_0_RXB_1  :: type_id :: create("test_case_78");
        test_case_79   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_0  :: type_id :: create("test_case_79");
        test_case_80   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_1_RXE_1_RXB_1  :: type_id :: create("test_case_80");
                                                                             
        test_case_81   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_0  :: type_id :: create("test_case_81");
        test_case_82   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_0_RXB_1  :: type_id :: create("test_case_82");
        test_case_83   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_0  :: type_id :: create("test_case_83");
        test_case_84   =   BAD_FRAME_WITH_IRQ_1_RXE_M_1_RXB_M_0_RXE_1_RXB_1  :: type_id :: create("test_case_84");
                                                                             
        test_case_85   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_0  :: type_id :: create("test_case_85");
        test_case_86   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_0_RXB_1  :: type_id :: create("test_case_86");
        test_case_87   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_0  :: type_id :: create("test_case_87");
        test_case_88   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_1_RXE_1_RXB_1  :: type_id :: create("test_case_88");
                                                                             
        test_case_89   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_0  :: type_id :: create("test_case_89");
        test_case_90   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_0_RXB_1  :: type_id :: create("test_case_90");
        test_case_91   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_0  :: type_id :: create("test_case_91");
        test_case_92   =   BAD_FRAME_WITH_IRQ_1_RXE_M_0_RXB_M_0_RXE_1_RXB_1  :: type_id :: create("test_case_92");
                                                                             
        test_case_93   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_0  :: type_id :: create("test_case_93");
        test_case_94   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_0_RXB_1  :: type_id :: create("test_case_94");
        test_case_95   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_0  :: type_id :: create("test_case_95");
        test_case_96   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_1_RXE_1_RXB_1  :: type_id :: create("test_case_96");
                                                                             
        test_case_97   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_0  :: type_id :: create("test_case_97");
        test_case_98   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_0_RXB_1  :: type_id :: create("test_case_98");
        test_case_99   =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_0  :: type_id :: create("test_case_99");
        test_case_100  =   BAD_FRAME_WITH_IRQ_0_RXE_M_1_RXB_M_0_RXE_1_RXB_1  :: type_id :: create("test_case_100");
                                                                            
        test_case_101  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_0  :: type_id :: create("test_case_101");
        test_case_102  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_0_RXB_1  :: type_id :: create("test_case_102");
        test_case_103  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_0  :: type_id :: create("test_case_103");
        test_case_104  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_1_RXE_1_RXB_1  :: type_id :: create("test_case_104");
                                                                            
        test_case_105  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_0  :: type_id :: create("test_case_105");
        test_case_106  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_0_RXB_1  :: type_id :: create("test_case_106");
        test_case_107  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_0  :: type_id :: create("test_case_107");
        test_case_108  =   BAD_FRAME_WITH_IRQ_0_RXE_M_0_RXB_M_0_RXE_1_RXB_1  :: type_id :: create("test_case_108");
	endfunction
//----------------------------task body---------------------------
  task body();
		req = sequence_item::type_id::create("sequence_item");
        
     
		h_config.do_ =1;
		h_seq_config.start(p_sequencer.h_m_seqr);

		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);

        wait(h_config.output_write)
	    h_config.count++;

		h_config.do_ =1;
		test_case1.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
	
		h_config.do_ =1;
		test_case2.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

	
		h_config.do_ =1;
		test_case3.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
	

		h_config.do_ =1;
		test_case4.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++; 
	/*		
		h_config.do_ =1;
		test_case5.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
*/
		h_config.do_ =1;
		test_case6.start(p_sequencer.h_m_seqr);
		//$display("================================================================88888888888888888888888888888888");
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
			
		h_config.do_ =1;
		test_case7.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
			
		h_config.do_ =1;
		test_case8.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
			
		h_config.do_ =1;
		test_case9.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case10.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case11.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case12.start(p_sequencer.h_m_seqr);					//=======RECEIVER_CHECK_WITH_MINFL_PAD_1_HUGEN_1
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
/*
		h_config.do_ =1;
		test_case13.start(p_sequencer.h_m_seqr);					//===== RECEIVER_CHECK_WITH_TxEN_0_RxEN_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
*/
		h_config.do_ =1;
		test_case14.start(p_sequencer.h_m_seqr);					//==== RECEIVER_CHECK_WITH_TxEN_0_RxEN_1
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

	/*	h_config.do_ =1;
		test_case15.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_TxEN_1_RxEN_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case16.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_TxEN_1_RxEN_1
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
*/
		h_config.do_ =1;
		test_case17.start(p_sequencer.h_m_seqr);					//=== RECEIVER_MODER_CHECK_WITH_NOPRE_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
/*
		h_config.do_ =1;
		test_case18.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case19.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case20.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
*/
		h_config.do_ =1;
		test_case21.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_PAD_0_NOPRE_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case25.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case26.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_HUGEN_0_NOPRE_1
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case27.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_0
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case28.start(p_sequencer.h_m_seqr);					//=== RECEIVER_CHECK_WITH_HUGEN_1_NOPRE_1
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		
		h_config.do_ =1;
		test_case_45.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case_46.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case_47.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case_48.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case_49.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;

		h_config.do_ =1;
		test_case_53.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
		
		h_config.do_ =1;
		test_case_54.start(p_sequencer.h_m_seqr);
		h_rx_mac_seq_final.start(p_sequencer.h_rx_mac_seqr);
		wait(h_config.output_write)
		h_config.count++;
    endtask
  
  
endclass
  


  
