
//-------- package

package pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"
typedef bit[3:0]score_board_payload[$];
	`include "config_class.sv"

	`include "sequence_item.sv"
	`include "rx_mac_sequence.sv"

	//`include "sequence.sv"
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

	`include "apb_slave_sequence.sv"
	`include "reg_field.sv"
	`include "ral_adapter.sv"
	`include "ral_sequence.sv"

	`include "master_sequencer.sv"
	`include "master_driver.sv"
	`include "apb_master_input_monitor.sv";

	`include "slave_sequencer.sv"
	`include "slave_driver.sv"

	`include "master_active_agent.sv"
	`include "slave_active_agent.sv"

	`include "rx_output_monitor.sv"
	`include "rx_passive_agent.sv"

	`include "rx_mac_sequencer.sv"
	`include "rx_mac_driver.sv"
	`include "rx_mac_input_monitor.sv"

	`include "rx_mac_active_agent.sv"
	`include "apb_env.sv"
	`include "rx_mac_env.sv"
	`include "rx_scoreboard.sv"

	`include "virtual_sequencer.sv";
	`include "virtual_seq.sv";
	`include "coverage.sv";

	`include "main_env.sv"
	`include "test.sv"
endpackage


/*
//-------- package

package pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"
	typedef bit [3:0]score_board_payload[$];
    typedef bit [31:0]read_data;

	`include "../MCS_DV06_ETHERNET_TOP/mcs_dv06_ETHERNET_config_class.sv"

	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_sequence_item.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_rx_mac_sequence.sv"
	
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_apb_master_sequence.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_apb_slave_sequence.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_reg_field.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_RAL_sequence.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_RAL_adapter.sv"


	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_driver.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_input_monitor.sv"


	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_driver.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_active_agent.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_active_agent.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_PASSIVE_AGENT/mcs_dv06_ETHERNET_apb_rx_output_monitor.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_PASSIVE_AGENT/mcs_dv06_ETHERNET_apb_rx_passive_agent.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_driver.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_input_monitor.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_active_agent.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_apb_env.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_rx_mac_env.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_rx_scoreboard.sv"
    
	//`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_coverage.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_virtual_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_virtual_sequence.sv"
    `include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_coverage.sv"

	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_main_env.sv"
	`include "mcs_dv06_ETHERNET_test.sv"

*/











/*


`include "../MCS_DV06_ETHERNET_TOP/mcs_dv06_ETHERNET_config_class.sv"

	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_sequence_item.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_rx_mac_sequence.sv"
	
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_apb_master_sequence.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_apb_slave_sequence.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_reg_field.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_RAL_sequence.sv"
	`include "../MCS_DV06_ETHERNET_RAL/mcs_dv06_ETHERNET_RAL_adapter.sv"

	//`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_apb_slave_sequence.sv"

	
	//`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_sequence.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_driver.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_input_monitor.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_driver.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_master_active_agent.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_apb_slave_active_agent.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_PASSIVE_AGENT/mcs_dv06_ETHERNET_apb_rx_output_monitor.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_PASSIVE_AGENT/mcs_dv06_ETHERNET_apb_rx_passive_agent.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_driver.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_input_monitor.sv"

	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_RX_MAC_AGENT/MCS_DV06_ETHERNET_RX_MAC_ACTIVE_AGENT/mcs_dv06_ETHERNET_rx_mac_active_agent.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_apb_env.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_rx_mac_env.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_rx_scoreboard.sv"
	`include "../MCS_DV06_ETHERNET_AGENT/MCS_DV06_ETHERNET_APB_AGENT/MCS_DV06_ETHERNET_APB_ACTIVE_AGENT/mcs_dv06_ETHERNET_virtual_sequencer.sv"
	`include "../MCS_DV06_ETHERNET_SEQUENCE/mcs_dv06_ETHERNET_virtual_sequence.sv"
	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_coverage.sv"

	`include "../MCS_DV06_ETHERNET_ENV/mcs_dv06_ETHERNET_main_env.sv"
	`include "mcs_dv06_ETHERNET_test.sv"



endpackage
*/
