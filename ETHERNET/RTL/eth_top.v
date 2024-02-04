//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:22:45 06/07/2020 
// Design Name: 
// Module Name:    eth_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "ethmac_defines.v"
`include "timescale.v"

module eth_top
(
  // APB common
  pclk_i, prstn_i, pwdata_i, prdata_o, 

  // APB slave
  paddr_i, psel_i, pwrite_i, penable_i, pready_o, 

  // APB master
  m_paddr_o, m_psel_o, m_pwrite_o, 
  m_pwdata_o, m_prdata_i, m_penable_o, 
  m_pready_i,  

  int_o,
`ifdef ETH_WISHBONE_B3
  m_wb_cti_o, m_wb_bte_o, 
`endif

  //TX
  mtx_clk_pad_i, mtxd_pad_o, mtxen_pad_o, mtxerr_pad_o,

  //RX
  mrx_clk_pad_i, mrxd_pad_i, mrxdv_pad_i, mrxerr_pad_i, mcrs_pad_i 
  `ifdef ETH_COLL
	,mcoll_pad_i 
  `endif
  // MIIM
  `ifdef ETH_MIIM
    ,mdc_pad_o, md_pad_i, md_pad_o, md_padoe_o
  `endif

  // Bist
`ifdef ETH_BIST
  
  // debug chain signals
  ,mbist_si_i,       // bist scan serial in
  mbist_so_o,       // bist scan serial out
  mbist_ctrl_i        // bist chain shift control
`endif

);


parameter TX_FIFO_DATA_WIDTH = `ETH_TX_FIFO_DATA_WIDTH;
parameter TX_FIFO_DEPTH      = `ETH_TX_FIFO_DEPTH;
parameter TX_FIFO_CNT_WIDTH  = `ETH_TX_FIFO_CNT_WIDTH;
parameter RX_FIFO_DATA_WIDTH = `ETH_RX_FIFO_DATA_WIDTH;
parameter RX_FIFO_DEPTH      = `ETH_RX_FIFO_DEPTH;
parameter RX_FIFO_CNT_WIDTH  = `ETH_RX_FIFO_CNT_WIDTH;


// APB common
input           pclk_i;     // APB clock
input           prstn_i;     // APB reset
input   [31:0]  pwdata_i;     // APB data input
output  [31:0]  prdata_o;     // APB data output
wire          pslverr;     // APB slave error output

// APB slave
input   [31:0]  paddr_i;     // APB address input
input      		psel_i;     // APB slave select input
wire 	[3:0]	pstb_i = 4'b1111; //apb_byte select input
input           pwrite_i;      // APB write enable input
input           penable_i;     // APB enable input
output          pready_o;     // APB ready output

// APB master
output  [31:0]  m_paddr_o;
output   		m_psel_o;
output          m_pwrite_o;
input   [31:0]  m_prdata_i;
output  [31:0]  m_pwdata_o;
output          m_penable_o;
input           m_pready_i;
wire           m_perr_i = 0;
output 			int_o;
wire    [29:0]  m_wb_adr_tmp;

`ifdef ETH_WISHBONE_B3
output   [2:0]  m_wb_cti_o;   // Cycle Type Identifier
output   [1:0]  m_wb_bte_o;   // Burst Type Extension
`endif

// Tx
input           mtx_clk_pad_i; // Transmit clock (from PHY)
output   [3:0]  mtxd_pad_o;    // Transmit nibble (to PHY)
output          mtxen_pad_o;   // Transmit enable (to PHY)
output          mtxerr_pad_o;  // Transmit error (to PHY)

// Rx
input           mrx_clk_pad_i; // Receive clock (from PHY)
input    [3:0]  mrxd_pad_i;    // Receive nibble (from PHY)
input           mrxdv_pad_i;   // Receive data valid (from PHY)
input           mrxerr_pad_i;  // Receive data error (from PHY)
input           mcrs_pad_i;    // Carrier sense (from PHY)
// Common Tx and Rx
`ifdef ETH_COLL
input          mcoll_pad_i;   // Collision (from PHY)
`else
wire          mcoll_pad_i = 0;   // Collision (from PHY)
`endif
// MII Management interface
`ifdef ETH_MIIM
input           md_pad_i;      // MII data input (from I/O cell)
output          mdc_pad_o;     // MII Management data clock (to PHY)
output          md_pad_o;      // MII data output (to I/O cell)
output        md_padoe_o;    // MII data output enable (to I/O cell)
`else
wire           md_pad_i = 0;      // MII data input (from I/O cell)
wire          mdc_pad_o;     // MII Management data clock (to PHY)
wire          md_pad_o;      // MII data output (to I/O cell)
wire          md_padoe_o;    // MII data output enable (to I/O cell)
`endif
wire         int_o;         // Interrupt output

// Bist
`ifdef ETH_BIST
input   mbist_si_i;       // bist scan serial in
output  mbist_so_o;       // bist scan serial out
input [`ETH_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;       // bist chain shift control
`endif

wire    [31:0]  wb_dbg_dat0;

wire     [7:0]  r_ClkDiv;
wire            r_MiiNoPre;
wire    [15:0]  r_CtrlData;
wire     [4:0]  r_FIAD;
wire     [4:0]  r_RGAD;
wire            r_WCtrlData;
wire            r_RStat;
wire            r_ScanStat;
wire            NValid_stat;
wire            Busy_stat;
wire            LinkFail;
wire    [15:0]  Prsd;             // Read Status Data (data read from the PHY)
wire            WCtrlDataStart;
wire            RStatStart;
wire            UpdateMIIRX_DATAReg;

wire            TxStartFrm;
wire            TxEndFrm;
wire            TxUsedData;
wire     [7:0]  TxData;
wire            TxRetry;
wire            TxAbort;
wire            TxUnderRun;
wire            TxDone;


reg             WillSendControlFrame_sync1;
reg             WillSendControlFrame_sync2;
reg             WillSendControlFrame_sync3;
reg             RstTxPauseRq;

reg             TxPauseRq_sync1;
reg             TxPauseRq_sync2;
reg             TxPauseRq_sync3;
reg             TPauseRq;


initial
begin
  $display("          *********************************************");
  $display("          =============================================");
  $display("          eth_top.v will be removed shortly.");
  $display("          Please use ethmac.v as top level file instead");
  $display("          =============================================");
  $display("          *********************************************");
end
// Connecting Miim module
eth_miim miim1
(
  .Clk(pclk_i),
  .Resetn(prstn_i),
  .Divider(r_ClkDiv),
  .NoPre(r_MiiNoPre),
  .CtrlData(r_CtrlData),
  .Rgad(r_RGAD),
  .Fiad(r_FIAD),
  .WCtrlData(r_WCtrlData),
  .RStat(r_RStat),
  .ScanStat(r_ScanStat),
  .Mdi(md_pad_i),
  .Mdo(md_pad_o),
  .MdoEn(md_padoe_o),
  .Mdc(mdc_pad_o),
  .Busy(Busy_stat),
  .Prsd(Prsd),
  .LinkFail(LinkFail),
  .Nvalid(NValid_stat),
  .WCtrlDataStart(WCtrlDataStart),
  .RStatStart(RStatStart),
  .UpdateMIIRX_DATAReg(UpdateMIIRX_DATAReg)
);




wire  [3:0] RegCs;          // Connected to registers
wire [31:0] RegDataOut;     // Multiplexed to prdata_o
wire        r_RecSmall;     // Receive small frames
wire        r_LoopBck;      // Loopback
wire        r_TxEn;         // Tx Enable
wire        r_RxEn;         // Rx Enable
wire [15:0]	BD_TxLength;		// Buffer descriptor length
wire 		MRxClk_Lb;		//Muxed MRxClk
wire        MRxDV_Lb;       // Muxed MII receive data valid
wire        MRxErr_Lb;      // Muxed MII Receive Error
wire  [3:0] MRxD_Lb;        // Muxed MII Receive Data
wire        Transmitting;   // Indication that TxEthMAC is transmitting
wire        r_HugEn;        // Huge packet enable
wire        r_DlyCrcEn;     // Delayed CRC enabled
wire [15:0] r_MaxFL;        // Maximum frame length

wire [15:0] r_MinFL;        // Minimum frame length
wire        ShortFrame;
wire        DribbleNibble;  // Extra nibble received
wire        ReceivedPacketTooBig; // Received packet is too big
wire [47:0] r_MAC;          // MAC address
wire        LoadRxStatus;   // Rx status was loaded
wire [31:0] r_HASH0;        // HASH table, lower 4 bytes
wire [31:0] r_HASH1;        // HASH table, upper 4 bytes
wire  [7:0] r_TxBDNum;      // Receive buffer descriptor number
wire  [6:0] r_IPGT;         // 
wire  [6:0] r_IPGR1;        // 
wire  [6:0] r_IPGR2;        // 
wire  [5:0] r_CollValid;    // 
wire [15:0] r_TxPauseTV;    // Transmit PAUSE value
wire        r_TxPauseRq;    // Transmit PAUSE request

wire  [3:0] r_MaxRet;       //
wire        r_NoBckof;      // 
wire        r_ExDfrEn;      // 
wire        r_TxFlow;       // Tx flow control enable
wire        r_IFG;          // Minimum interframe gap for incoming packets

wire        TxB_IRQ;        // Interrupt Tx Buffer
wire        TxE_IRQ;        // Interrupt Tx Error
wire        RxB_IRQ;        // Interrupt Rx Buffer
wire        RxE_IRQ;        // Interrupt Rx Error
wire        Busy_IRQ;       // Interrupt Busy (lack of buffers)

wire        ByteSelected;
wire        BDAck;
wire [31:0] BD_prdata_o;    // prdata_o that comes from the Wishbone module
                            //(for buffer descriptors read/write)
wire  [3:0] BDCs;           // Buffer descriptor CS
wire        CsMiss;         // When access to the address between 0x800
                            // and 0xfff occurs, acknowledge is set
                            // but data is not valid.
wire        r_Pad;
wire        r_CrcEn;
wire        r_FullD;
wire        r_Pro;
wire        r_Bro;
wire 		r_Iam;
wire        r_NoPre;
wire        r_RxFlow;
wire        r_PassAll;
wire        TxCtrlEndFrm;
wire        StartTxDone;
wire        SetPauseTimer;
wire        TxUsedDataIn;
wire        TxDoneIn;
wire        TxAbortIn;
wire        PerPacketPad;
wire        PadOut;
wire        PerPacketCrcEn;
wire        CrcEnOut;
wire        TxStartFrmOut;
wire        TxEndFrmOut;
wire        ReceivedPauseFrm;
wire        ControlFrmAddressOK;
wire        RxStatusWriteLatched_sync2;
wire        LateCollision;
wire        DeferIndication;
wire        LateCollLatched;
wire        DeferLatched;
wire        RstDeferLatched;
wire        CarrierSenseLost;
wire 		Length_Vs_Payload_error;
wire 		Length_vs_payload_mismatch;
wire 		MRxErr_Detected;
wire        temp_pready_o;
reg [31:0] temp_prdata_o;
reg       temp_perr_o;

`ifdef ETH_REGISTERED_OUTPUTS
  reg         temp_pready_o_reg;
  reg [31:0]  temp_prdata_o_reg;
  reg         temp_perr_o_reg;
`endif


wire wb_psel_o;
wire wb_penable_o;
wire wb_pwrite_o;
wire [31:0]wb_pwdata_o;
wire [31:0]wb_paddr_o;
wire apb_bd_bridge_pready_o;
wire [31:0]apb_bd_bridge_prdata_o;


assign ByteSelected = psel_i;
assign RegCs[3] =  psel_i &  penable_i & ByteSelected & ~paddr_i[11] & ~paddr_i[10] & pstb_i[3];   // 0x0   - 0x3FF
assign RegCs[2] =  psel_i & penable_i & ByteSelected & ~paddr_i[11] & ~paddr_i[10] & pstb_i[2];   // 0x0   - 0x3FF
assign RegCs[1] =  psel_i & penable_i & ByteSelected & ~paddr_i[11] & ~paddr_i[10] & pstb_i[1];   // 0x0   - 0x3FF
assign RegCs[0] =  psel_i & penable_i & ByteSelected & ~paddr_i[11] & ~paddr_i[10] & pstb_i[0];   // 0x0   - 0x3FF

assign BDCs[3]  =  wb_psel_o & wb_penable_o & ~wb_paddr_o[11] &  wb_paddr_o[10] & pstb_i[3];   // 0x400 - 0x7FF	// 0100_0000_0000	0111_1111_1111
assign BDCs[2]  =  wb_psel_o & wb_penable_o & ~wb_paddr_o[11] &  wb_paddr_o[10] & pstb_i[2];   // 0x400 - 0x7FF
assign BDCs[1]  =  wb_psel_o & wb_penable_o & ~wb_paddr_o[11] &  wb_paddr_o[10] & pstb_i[1];   // 0x400 - 0x7FF
assign BDCs[0]  =  wb_psel_o & wb_penable_o & ~wb_paddr_o[11] &  wb_paddr_o[10] & pstb_i[0];   // 0x400 - 0x7FF

assign CsMiss =   wb_psel_o & wb_penable_o & wb_paddr_o[11];                   // 0x800 - 0xfFF	1000_0000_0100


//Moschip Team
always @(*)
begin
  if(|RegCs)  
	begin
		if(~pwrite_i)
			temp_prdata_o = RegDataOut; 
		else
			temp_prdata_o = 'dz;
	end
  else
    begin
		if(|BDCs & ~wb_pwrite_o)
		    temp_prdata_o = apb_bd_bridge_prdata_o;
		else
			temp_prdata_o = 'dz;
	end
	
end
`ifdef ETH_REGISTERED_OUTPUT
  assign pready_o = temp_pready_o_reg;
  assign prdata_o[31:0] = temp_prdata_o_reg;	//register outputs are needed so commenting them.
  assign pslverr = temp_perr_o_reg;
`else
  assign pready_o = temp_pready_o;
  assign prdata_o[31:0] = temp_prdata_o;
  assign pslverr = temp_perr_o;
`endif

`ifdef ETH_AVALON_BUS
  // As Avalon has no corresponding "error" signal, I (erroneously) will
  // send an ack to Avalon, even when accessing undefined memory. This
  // is a grey area in Avalon vs. Wishbone specs: My understanding
  // is that Avalon expects all memory addressable by the addr bus feeding
  // a slave to be, at the very minimum, readable.
  assign temp_pready_o = (|RegCs) | BDAck | CsMiss;
`else // APB
//Moschip Team
//Note: Generating the pready by depending on psel, penable and paddr.
//		Depending on paddr, pready can be multiplexed between RegCs and BDCs
  assign temp_pready_o = (|RegCs) | apb_bd_bridge_pready_o;
`endif


`ifdef ETH_REGISTERED_OUTPUT
  always @ (posedge pclk_i or negedge prstn_i)
  begin
    if(prstn_i == 0)
      begin
        temp_pready_o_reg <= 1'b0;
        temp_prdata_o_reg <= 32'h0;
        temp_perr_o_reg <= 1'b0;
      end
    else
      begin
        temp_pready_o_reg <= temp_pready_o & ~temp_pready_o_reg;
        temp_prdata_o_reg <= temp_prdata_o;
        temp_perr_o_reg <= temp_perr_o & ~temp_perr_o_reg;
      end
  end
`endif


// Connecting Ethernet registers
eth_registers ethreg1
(
  .wdata(pwdata_i),
  .addr(paddr_i[9:2]),
  .Rw(pwrite_i),
  .Cs(RegCs),
  .Clk(pclk_i),
  .Resetn(prstn_i),
  .DataOut(RegDataOut),
  .r_RecSmall(r_RecSmall),
  .r_Pad(r_Pad),
  .r_HugEn(r_HugEn),
  .r_CrcEn(r_CrcEn),
  .r_DlyCrcEn(r_DlyCrcEn),
  .r_FullD(r_FullD),
  .r_ExDfrEn(r_ExDfrEn),
  .r_NoBckof(r_NoBckof),
  .r_LoopBck(r_LoopBck),
  .r_IFG(r_IFG),
  .r_Pro(r_Pro),
  .r_Iam(r_Iam),
  .r_Bro(r_Bro),
  .r_NoPre(r_NoPre),
  .r_TxEn(r_TxEn),
  .r_RxEn(r_RxEn),
  .Busy_IRQ(Busy_IRQ),
  .RxE_IRQ(RxE_IRQ),
  .RxB_IRQ(RxB_IRQ),
  .TxE_IRQ(TxE_IRQ),
  .TxB_IRQ(TxB_IRQ),
  .r_IPGT(r_IPGT),
  .r_IPGR1(r_IPGR1),
  .r_IPGR2(r_IPGR2),
  .r_MinFL(r_MinFL),
  .r_MaxFL(r_MaxFL),
  .r_MaxRet(r_MaxRet),
  .r_CollValid(r_CollValid),
  .r_TxFlow(r_TxFlow),
  .r_RxFlow(r_RxFlow),
  .r_PassAll(r_PassAll),
  .r_MiiNoPre(r_MiiNoPre),
  .r_ClkDiv(r_ClkDiv),
  .r_WCtrlData(r_WCtrlData),
  .r_RStat(r_RStat),
  .r_ScanStat(r_ScanStat),
  .r_RGAD(r_RGAD),
  .r_FIAD(r_FIAD),
  .r_CtrlData(r_CtrlData),
  .NValid_stat(NValid_stat),
  .Busy_stat(Busy_stat),
  .LinkFail(LinkFail),
  .r_MAC(r_MAC),
  .WCtrlDataStart(WCtrlDataStart),
  .RStatStart(RStatStart),
  .UpdateMIIRX_DATAReg(UpdateMIIRX_DATAReg),
  .Prsd(Prsd),
  .r_TxBDNum(r_TxBDNum),
  .int_o(int_o),
  .r_HASH0(r_HASH0),
  .r_HASH1(r_HASH1),
  .r_TxPauseRq(r_TxPauseRq),
  .r_TxPauseTV(r_TxPauseTV),
  .RstTxPauseRq(RstTxPauseRq),
  .TxCtrlEndFrm(TxCtrlEndFrm),
  .StartTxDone(StartTxDone),
  .TxClk(mtx_clk_pad_i),
  .RxClk(mrx_clk_pad_i),
  .dbg_dat(wb_dbg_dat0),
  .SetPauseTimer(SetPauseTimer)
  
);



wire  [7:0] RxData;
wire        RxValid;
wire        RxStartFrm;
wire        RxEndFrm;
wire        RxAbort;

wire        WillTransmit;            // Will transmit (to RxEthMAC)
wire        ResetCollision;          // Reset Collision (for synchronizing 
                                     // collision)
wire  [7:0] TxDataOut;               // Transmit Packet Data (to TxEthMAC)
wire        WillSendControlFrame;
wire        ReceiveEnd;
wire        ReceivedPacketGood;
wire        ReceivedLengthOK;
wire        InvalidSymbol;
wire        LatchedCrcError;
wire        RxLateCollision;
wire  [3:0] RetryCntLatched;   
wire  [3:0] RetryCnt;   
wire        StartTxAbort;   
wire        MaxCollisionOccured;   
wire        RetryLimit;   
wire        StatePreamble; 
wire 		StateSFD;  
wire 		StateSA;
wire 		StateDA;
wire 		StateLength;
wire  [1:0] StateData; 

// Connecting MACControl
eth_maccontrol maccontrol1
(
  .MTxClk(mtx_clk_pad_i),
  .TPauseRq(TPauseRq),
  .TxPauseTV(r_TxPauseTV),
  .TxDataIn(TxData),
  .TxStartFrmIn(TxStartFrm),
  .TxEndFrmIn(TxEndFrm),
  .TxUsedDataIn(TxUsedDataIn),
  .TxDoneIn(TxDoneIn),
  .TxAbortIn(TxAbortIn),
  .MRxClk(mrx_clk_pad_i),
  .RxData(RxData),
  .RxValid(RxValid),
  .RxStartFrm(RxStartFrm),
  .RxEndFrm(RxEndFrm),
  .ReceiveEnd(ReceiveEnd),
  .ReceivedPacketGood(ReceivedPacketGood),
  .TxFlow(r_TxFlow),
  .RxFlow(r_RxFlow),
  .DlyCrcEn(r_DlyCrcEn),
  .MAC(r_MAC),
  .PadIn(r_Pad),
  .PadOut(PadOut),
  .CrcEnIn(r_CrcEn),
  .CrcEnOut(CrcEnOut),
  .TxResetn(prstn_i),
  .RxResetn(prstn_i),
  .ReceivedLengthOK(ReceivedLengthOK),
  .TxDataOut(TxDataOut),
  .TxStartFrmOut(TxStartFrmOut),
  .TxEndFrmOut(TxEndFrmOut),
  .TxUsedDataOut(TxUsedData),
  .TxDoneOut(TxDone),
  .TxAbortOut(TxAbort),
  .WillSendControlFrame(WillSendControlFrame),
  .TxCtrlEndFrm(TxCtrlEndFrm),
  .ReceivedPauseFrm(ReceivedPauseFrm),
  .ControlFrmAddressOK(ControlFrmAddressOK),
  .SetPauseTimer(SetPauseTimer),
  .RxStatusWriteLatched_sync2(RxStatusWriteLatched_sync2),
  .r_PassAll(r_PassAll)
);



wire TxCarrierSense;          // Synchronized CarrierSense (to Tx clock)
wire Collision;               // Synchronized Collision

reg CarrierSense_Tx1;
reg CarrierSense_Tx2;
reg Collision_Tx1;
reg Collision_Tx2;

reg RxEnSync;                 // Synchronized Receive Enable
reg WillTransmit_q;
reg WillTransmit_q2;



// Muxed MII receive data valid
assign MRxDV_Lb = r_LoopBck? mtxen_pad_o : mrxdv_pad_i & RxEnSync;

// Muxed MII Receive Error
assign MRxErr_Lb = r_LoopBck? mtxerr_pad_o : mrxerr_pad_i & RxEnSync;

// Muxed MII Receive Data
assign MRxD_Lb[3:0] = r_LoopBck? mtxd_pad_o[3:0] : mrxd_pad_i[3:0];



// Connecting TxEthMAC
eth_txethmac txethmac1
(
  .MTxClk(mtx_clk_pad_i),
  .Resetn(prstn_i),
  .CarrierSense(TxCarrierSense),
  .Collision(Collision),
  .TxData(TxDataOut),
  .TxStartFrm(TxStartFrmOut),
  .TxUnderRun(TxUnderRun),
  .TxEndFrm(TxEndFrmOut),
  .Pad(PadOut),
  .No_Preamble(r_NoPre),		
  .MAC_Address(r_MAC),
  .DA_Address({3'd0,r_FIAD[4],r_FIAD[3:0],40'd0}),
  .Payload_length(BD_TxLength),
  .r_LoopBck(r_LoopBck),
  .MinFL(r_MinFL),
  .CrcEn(CrcEnOut),
  .FullD(r_FullD),
  .HugEn(r_HugEn),
  .DlyCrcEn(r_DlyCrcEn),
  .IPGT(r_IPGT),
  .IPGR1(r_IPGR1),
  .IPGR2(r_IPGR2),
  .CollValid(r_CollValid),
  .MaxRet(r_MaxRet),
  .NoBckof(r_NoBckof),
  .ExDfrEn(r_ExDfrEn),
  .MaxFL(r_MaxFL),
  .MTxEn(mtxen_pad_o),
  .MTxD(mtxd_pad_o),
  .MTxErr(mtxerr_pad_o),
  .TxUsedData(TxUsedDataIn),
  .TxDone(TxDoneIn),
  .TxRetry(TxRetry),
  .TxAbort(TxAbortIn),
  .WillTransmit(WillTransmit),
  .ResetCollision(ResetCollision),
  .RetryCnt(RetryCnt),
  .StartTxDone(StartTxDone),
  .StartTxAbort(StartTxAbort),
  .MaxCollisionOccured(MaxCollisionOccured),
  .LateCollision(LateCollision),
  .DeferIndication(DeferIndication),
  .StatePreamble(StatePreamble),
  .StateSFD(StateSFD),
  .StateDA(StateDA),
  .StateSA(StateSA),
  .StateLength(StateLength),
  .StateData(StateData)   
);




wire  [15:0]  RxByteCnt;
wire          RxByteCntEq0;
wire          RxByteCntGreat2;
wire          RxByteCntMaxFrame;
wire          RxCrcError;
wire          RxStateIdle;
wire          RxStatePreamble;
wire          RxStateSFD;
wire   [1:0]  RxStateData;
wire 		  RxStateDA;
wire		  RxStateSA;
wire 		  RxStateLength;
wire          AddressMiss;




// Connecting RxEthMAC
eth_rxethmac rxethmac1
(
  .MRxClk(mrx_clk_pad_i),
  .MRxDV(MRxDV_Lb),
  .MRxD(MRxD_Lb),
  .MRxErr(MRxErr_Lb),
  .Transmitting(Transmitting),
  .Pad(PadOut),
  .HugEn(r_HugEn),
  .DlyCrcEn(r_DlyCrcEn),
  .r_MinFL(r_MinFL),
  .MaxFL(r_MaxFL),
  .r_IFG(r_IFG),
  .No_Preamble(r_NoPre),
  .Resetn(prstn_i),
  .RxData(RxData),
  .RxValid(RxValid),
  .RxStartFrm(RxStartFrm),
  .RxEndFrm(RxEndFrm),
  .ByteCnt(RxByteCnt),
  .ByteCntEq0(RxByteCntEq0),
  .ByteCntGreat2(RxByteCntGreat2),
  .ByteCntMaxFrame(RxByteCntMaxFrame),
  .CrcError(RxCrcError),
  .StateIdle(RxStateIdle),
  .StatePreamble(RxStatePreamble),
  .StateSFD(RxStateSFD),
  .StateData(RxStateData),
  .StateDA(RxStateDA),
  .StateSA(RxStateSA),
  .StateLength(RxStateLength),
  .MAC(r_MAC),
  .r_Pro(r_Pro),
  .r_Bro(r_Bro),
  .r_Iam(r_Iam),
  .r_HASH0(r_HASH0),
  .r_HASH1(r_HASH1),
  .RxAbort(RxAbort),
  .AddressMiss(AddressMiss),
  .PassAll(r_PassAll),
  .ControlFrmAddressOK(ControlFrmAddressOK),
  .Length_Vs_Payload_error(Length_Vs_Payload_error),
  .MRxErr_Detected(MRxErr_Detected),
  .Length_vs_payload_mismatch(Length_vs_payload_mismatch)
);


// MII Carrier Sense Synchronization
always @ (posedge mtx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    begin
      CarrierSense_Tx1 <=  1'b0;
      CarrierSense_Tx2 <=  1'b0;
    end
  else
    begin
      CarrierSense_Tx1 <=  mcrs_pad_i;
      CarrierSense_Tx2 <=  CarrierSense_Tx1;
    end
end

assign TxCarrierSense = ~r_FullD & CarrierSense_Tx2;


// MII Collision Synchronization
always @ (posedge mtx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    begin
      Collision_Tx1 <=  1'b0;
      Collision_Tx2 <=  1'b0;
    end
  else
    begin
      Collision_Tx1 <=  mcoll_pad_i;
      if(ResetCollision)
        Collision_Tx2 <=  1'b0;
      else
      if(Collision_Tx1)
        Collision_Tx2 <=  1'b1;
    end
end


// Synchronized Collision
assign Collision = ~r_FullD & Collision_Tx2;



// Delayed WillTransmit
always @ (posedge mrx_clk_pad_i)
begin
  WillTransmit_q <=  WillTransmit;
  WillTransmit_q2 <=  WillTransmit_q;
end 


assign Transmitting = ~r_FullD & WillTransmit_q2;


always @ (posedge mrx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    RxEnSync <=  1'b0;
  else
	if(~mrxdv_pad_i)
		RxEnSync <=  r_RxEn;
end

// Synchronizing WillSendControlFrame to WB_CLK;
always @ (posedge pclk_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    WillSendControlFrame_sync1 <= 1'b0;
  else
    WillSendControlFrame_sync1 <= WillSendControlFrame;
end

always @ (posedge pclk_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    WillSendControlFrame_sync2 <= 1'b0;
  else
    WillSendControlFrame_sync2 <= WillSendControlFrame_sync1;
end

always @ (posedge pclk_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    WillSendControlFrame_sync3 <= 1'b0;
  else
    WillSendControlFrame_sync3 <= WillSendControlFrame_sync2;
end

always @ (posedge pclk_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    RstTxPauseRq <= 1'b0;
  else
    RstTxPauseRq <= WillSendControlFrame_sync2 & ~WillSendControlFrame_sync3;
end




// TX Pause request Synchronization
always @ (posedge mtx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    begin
      TxPauseRq_sync1 <=  1'b0;
      TxPauseRq_sync2 <=  1'b0;
      TxPauseRq_sync3 <=  1'b0;
    end
  else
    begin
      TxPauseRq_sync1 <=  (r_TxPauseRq & r_TxFlow);
      TxPauseRq_sync2 <=  TxPauseRq_sync1;
      TxPauseRq_sync3 <=  TxPauseRq_sync2;
    end
end


always @ (posedge mtx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    TPauseRq <=  1'b0;
  else
    TPauseRq <=  TxPauseRq_sync2 & (~TxPauseRq_sync3);
end


wire LatchedMRxErr;
reg RxAbort_latch;
//reg RxAbort_sync1;
reg RxAbort_wb;
reg RxAbortRst_sync1;
reg RxAbortRst;

// Synchronizing RxAbort to the APB clock
always @ (posedge mrx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    RxAbort_latch <=  1'b0;
  else if(RxAbort)
    RxAbort_latch <=  1'b1;
  else if(RxAbortRst)
    RxAbort_latch <=  1'b0;
end

always @ (posedge pclk_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    begin
//      RxAbort_sync1 <=  1'b0;
      RxAbort_wb    <=  1'b0;
      RxAbort_wb    <=  1'b0;
    end
  else
    begin
      RxAbort_wb    <=  RxAbort_latch;
    end
end

always @ (posedge mrx_clk_pad_i or negedge prstn_i)
begin
  if(prstn_i == 0)
    begin
      RxAbortRst_sync1 <=  1'b0;
      RxAbortRst       <=  1'b0;
    end
  else
    begin
      RxAbortRst_sync1 <=  RxAbort_wb;
      RxAbortRst       <=  RxAbortRst_sync1;
    end
end

//Moschip Team 
//Note: To compatible apb signals with the wishbone signals added the below module.
//		Inputs are APB supported signals, outputs are wishbone supported signals.

apb_BDs_bridge u_apb_BDs_bridge(

//apb signals
.apb_pclk_i(pclk_i),
.apb_presetn_i(prstn_i),
.apb_psel_i(psel_i),
.apb_penable_i(penable_i),
.apb_pwrite_i(pwrite_i),
.apb_pwdata_i(pwdata_i),
.apb_paddr_i(paddr_i),
.apb_prdata_o(apb_bd_bridge_prdata_o),	
.apb_pready_o(apb_bd_bridge_pready_o),	

//wishbone signals
.wb_psel_o(wb_psel_o),
.wb_penable_o(wb_penable_o),
.wb_pwrite_o(wb_pwrite_o),
.wb_pwdata_o(wb_pwdata_o),
.wb_paddr_o(wb_paddr_o),
.wb_prdata_i(BD_prdata_o),
.wb_BDAck_i(BDAck)
);



// Connecting Wishbone module
eth_wishbone #(.TX_FIFO_DATA_WIDTH(TX_FIFO_DATA_WIDTH),
	       .TX_FIFO_DEPTH     (TX_FIFO_DEPTH),
	       .TX_FIFO_CNT_WIDTH (TX_FIFO_CNT_WIDTH),
	       .RX_FIFO_DATA_WIDTH(RX_FIFO_DATA_WIDTH),
	       .RX_FIFO_DEPTH     (RX_FIFO_DEPTH),
	       .RX_FIFO_CNT_WIDTH (RX_FIFO_CNT_WIDTH))
wishbone
(
  .WB_CLK_I(pclk_i),
  .WB_DAT_I(wb_pwdata_o),
  .WB_DAT_O(BD_prdata_o),

  // WISHBONE slave
  .WB_ADDR_I(wb_paddr_o[9:2]),
  .WB_WE_I(wb_pwrite_o),
  .BDCs(BDCs),
  .WB_ACK_O(BDAck),
  .Resetn(prstn_i),

  // WISHBONE master
  .m_wb_adr_o(m_wb_adr_tmp),
  .m_wb_sel_o(m_psel_o),
  .m_wb_we_o(m_pwrite_o),
  .m_wb_dat_i(m_prdata_i),
  .m_wb_dat_o(m_pwdata_o),
  .m_wb_cyc_o_delayed_next_state(m_penable_o),	
  .m_wb_ack_i(m_pready_i),
  .m_wb_err_i(m_perr_i),
  
`ifdef ETH_WISHBONE_B3
  .m_wb_cti_o(m_wb_cti_o),
  .m_wb_bte_o(m_wb_bte_o), 
`endif

    //TX
  .MTxClk(mtx_clk_pad_i),
  .TxStartFrm(TxStartFrm),
  .TxEndFrm(TxEndFrm),
  .TxUsedData(TxUsedData),
  
  .TxData(TxData),
  .TxRetry(TxRetry),
  .TxAbort(TxAbort),
  .TxUnderRun(TxUnderRun),
  .TxDone(TxDone),
  .PerPacketCrcEn(PerPacketCrcEn),
  .PerPacketPad(PerPacketPad),

  // Register
  .r_TxEn(r_TxEn),
  .r_RxEn(r_RxEn),
  .r_Pad(r_Pad),
  .r_HugEn(r_HugEn),
  .r_MinFL(r_MinFL),
  .r_MaxFL(r_MaxFL),
  .r_TxBDNum(r_TxBDNum),
  .r_RxFlow(r_RxFlow),
  .r_PassAll(r_PassAll), 
  .BD_TxLength(BD_TxLength),
  //RX
  .MRxClk(mrx_clk_pad_i),
  .RxData(RxData),
  .RxValid(RxValid),
  .RxStartFrm(RxStartFrm),
  .RxEndFrm(RxEndFrm),
  .Busy_IRQ(Busy_IRQ),
  .RxE_IRQ(RxE_IRQ),
  .RxB_IRQ(RxB_IRQ),
  .TxE_IRQ(TxE_IRQ),
  .TxB_IRQ(TxB_IRQ), 


  .RxAbort(RxAbort_wb),
  .RxStatusWriteLatched_sync2(RxStatusWriteLatched_sync2), 

  .InvalidSymbol(InvalidSymbol),
  .LatchedCrcError(LatchedCrcError),
  .RxLength(RxByteCnt),
  .RxLateCollision(RxLateCollision),
  .ShortFrame(ShortFrame),
  .DribbleNibble(DribbleNibble),
  .ReceivedPacketTooBig(ReceivedPacketTooBig),
  .LoadRxStatus(LoadRxStatus),
  .RetryCntLatched(RetryCntLatched),
  .RetryLimit(RetryLimit),
  .LateCollLatched(LateCollLatched),
  .DeferLatched(DeferLatched),
  .RstDeferLatched(RstDeferLatched),
  .CarrierSenseLost(CarrierSenseLost),
  .ReceivedPacketGood(ReceivedPacketGood),
  .AddressMiss(AddressMiss),
  .MRxErr_Detected(MRxErr_Detected),
  .Length_Vs_Payload_error(Length_Vs_Payload_error),
  .Length_vs_payload_mismatch(Length_vs_payload_mismatch),
  .ReceivedPauseFrm(ReceivedPauseFrm)
  
`ifdef ETH_BIST
  ,
  .mbist_si_i       (mbist_si_i),
  .mbist_so_o       (mbist_so_o),
  .mbist_ctrl_i       (mbist_ctrl_i)
`endif
`ifdef WISHBONE_DEBUG
  ,
  .dbg_dat0(wb_dbg_dat0)
`endif

);

assign m_paddr_o = {m_wb_adr_tmp, 2'h0};

// Connecting MacStatus module
eth_macstatus macstatus1 
(
  .MRxClk(mrx_clk_pad_i),
  .Resetn(prstn_i),
  .ReceiveEnd(ReceiveEnd),
  .ReceivedPacketGood(ReceivedPacketGood),
  .ReceivedLengthOK(ReceivedLengthOK),
  .RxCrcError(RxCrcError),
  .MRxErr(MRxErr_Lb),
  .MRxDV(MRxDV_Lb),
  .RxStateSFD(RxStateSFD),
  .RxStateData(RxStateData),
  .RxStatePreamble(RxStatePreamble),
  .RxStateIdle(RxStateIdle),
  .RxStateDA(RxStateDA),
  .RxStateSA(RxStateSA),
  .RxStateLength(RxStateLength),
  .Transmitting(Transmitting),
  .RxByteCnt(RxByteCnt),
  .RxByteCntEq0(RxByteCntEq0),
  .RxByteCntGreat2(RxByteCntGreat2),
  .RxByteCntMaxFrame(RxByteCntMaxFrame),
  .InvalidSymbol(InvalidSymbol),
  .MRxD(MRxD_Lb),
  .LatchedCrcError(LatchedCrcError),
  .Collision(mcoll_pad_i),
  .CollValid(r_CollValid),
  .RxLateCollision(RxLateCollision),
  .r_RecSmall(r_RecSmall),
  .r_MinFL(r_MinFL),
  .r_MaxFL(r_MaxFL),
  .ShortFrame(ShortFrame),
  .DribbleNibble(DribbleNibble),
  .ReceivedPacketTooBig(ReceivedPacketTooBig),
  .r_HugEn(r_HugEn),
  .LoadRxStatus(LoadRxStatus),
  .RetryCnt(RetryCnt),
  .StartTxDone(StartTxDone),
  .StartTxAbort(StartTxAbort),
  .RetryCntLatched(RetryCntLatched),
  .MTxClk(mtx_clk_pad_i),
  .MaxCollisionOccured(MaxCollisionOccured),
  .RetryLimit(RetryLimit),
  .LateCollision(LateCollision),
  .LateCollLatched(LateCollLatched),
  .DeferIndication(DeferIndication),
  .DeferLatched(DeferLatched),
  .RstDeferLatched(RstDeferLatched),
  .TxStartFrm(TxStartFrmOut),
  .StatePreamble(StatePreamble),
  .StateSFD(StateSFD),
  .StateDA(StateDA),
  .StateSA(StateSA),
  .StateLength(StateLength),
  .StateData(StateData),
  .CarrierSense(CarrierSense_Tx2),
  .CarrierSenseLost(CarrierSenseLost),
  .TxUsedData(TxUsedDataIn),
  .LatchedMRxErr(LatchedMRxErr),
  .Loopback(r_LoopBck),
  .r_FullD(r_FullD)
);


endmodule

