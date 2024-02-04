//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:43:26 06/07/2020 
// Design Name: 
// Module Name:    eth_wishbone 
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
module eth_wishbone
  (

   // WISHBONE common
   WB_CLK_I, WB_DAT_I, WB_DAT_O, 

   // WISHBONE slave
   WB_ADDR_I, WB_WE_I, WB_ACK_O, 
   BDCs, 

   Resetn, 

   // WISHBONE master
   m_wb_adr_o, m_wb_sel_o, m_wb_we_o, 
   m_wb_dat_o, m_wb_dat_i, m_wb_cyc_o_delayed_next_state, 
   m_wb_ack_i, m_wb_err_i, 

   m_wb_cti_o, m_wb_bte_o, 

   //TX
   MTxClk, TxStartFrm, TxEndFrm, TxUsedData, TxData, 
   TxRetry, TxAbort, TxUnderRun, TxDone, PerPacketCrcEn, 
   PerPacketPad, 

   //RX
   MRxClk, RxData, RxValid, RxStartFrm, RxEndFrm, RxAbort,
   RxStatusWriteLatched_sync2, 
  
   // Register
   r_TxEn, r_RxEn,r_Pad,r_HugEn,r_MinFL,r_MaxFL, r_TxBDNum, r_RxFlow, r_PassAll, 

   // Interrupts
   TxB_IRQ, TxE_IRQ, RxB_IRQ, RxE_IRQ, Busy_IRQ, 
  
   // Rx Status
   InvalidSymbol, LatchedCrcError, RxLateCollision, ShortFrame, DribbleNibble,
   ReceivedPacketTooBig, RxLength, LoadRxStatus, ReceivedPacketGood,
   AddressMiss, MRxErr_Detected,Length_Vs_Payload_error,Length_vs_payload_mismatch,
   ReceivedPauseFrm, 
  
   // Tx Status
   RetryCntLatched, RetryLimit, LateCollLatched, DeferLatched, RstDeferLatched,
   CarrierSenseLost,BD_TxLength	

   // Bist
`ifdef ETH_BIST
   ,
   // debug chain signals
   mbist_si_i,       // bist scan serial in
   mbist_so_o,       // bist scan serial out
   mbist_ctrl_i        // bist chain shift control
`endif

`ifdef WISHBONE_DEBUG
   ,
   dbg_dat0
`endif


   );

parameter TX_FIFO_DATA_WIDTH = `ETH_TX_FIFO_DATA_WIDTH;
parameter TX_FIFO_DEPTH      = `ETH_TX_FIFO_DEPTH;
parameter TX_FIFO_CNT_WIDTH  = `ETH_TX_FIFO_CNT_WIDTH;
parameter RX_FIFO_DATA_WIDTH = `ETH_RX_FIFO_DATA_WIDTH;
parameter RX_FIFO_DEPTH      = `ETH_RX_FIFO_DEPTH;
parameter RX_FIFO_CNT_WIDTH  = `ETH_RX_FIFO_CNT_WIDTH;

// WISHBONE common
input           WB_CLK_I;       // WISHBONE clock
input  [31:0]   WB_DAT_I;       // WISHBONE data input
output [31:0]   WB_DAT_O;       // WISHBONE data output

// WISHBONE slave
input   [9:2]   WB_ADDR_I;       // WISHBONE address input
input           WB_WE_I;        // WISHBONE write enable input
input   [3:0]   BDCs;           // Buffer descriptors are selected
output          WB_ACK_O;       // WISHBONE acknowledge output

// WISHBONE master
output  [29:0]  m_wb_adr_o;     // 
output   	    m_wb_sel_o;     // 
output          m_wb_we_o;      // 
output  [31:0]  m_wb_dat_o;     // 
output          m_wb_cyc_o_delayed_next_state;     // 
input   [31:0]  m_wb_dat_i;     // 
input           m_wb_ack_i;     // 
input           m_wb_err_i;     // 

output   [2:0]  m_wb_cti_o;     // Cycle Type Identifier
output   [1:0]  m_wb_bte_o;     // Burst Type Extension
reg      [2:0]  m_wb_cti_o;     // Cycle Type Identifier

input           Resetn;       // Resetn signal

// Rx Status signals
input           InvalidSymbol;    // Invalid symbol was received during reception in 100 Mbps mode
input           LatchedCrcError;  // CRC error
input           RxLateCollision;  // Late collision occured while receiving frame
input           ShortFrame;       // Frame shorter then the minimum size
                                  // (r_MinFL) was received while small
                                  // packets are enabled (r_RecSmall)
input           DribbleNibble;    // Extra nibble received
input           ReceivedPacketTooBig;// Received packet is bigger than r_MaxFL
input    [15:0] RxLength;         // Length of the incoming frame
reg      [15:0] RxLength_d;  
input           LoadRxStatus;     // Rx status was loaded
input           ReceivedPacketGood;  // Received packet's length and CRC are
                                     // good
input           AddressMiss;      // When a packet is received AddressMiss
                                  // status is written to the Rx BD
input 			MRxErr_Detected;

input           r_RxFlow;
input           r_PassAll;
input           ReceivedPauseFrm;


// Tx Status signals
input     [3:0] RetryCntLatched;  // Latched Retry Counter
input           RetryLimit;       // Retry limit reached (Retry Max value +1
                                  // attempts were made)
input           LateCollLatched;  // Late collision occured
input           DeferLatched;     // Defer indication (Frame was defered
                                  // before sucessfully sent)
output          RstDeferLatched;
input           CarrierSenseLost; // Carrier Sense was lost during the
                                  // frame transmission

// Tx
input           MTxClk;         // Transmit clock (from PHY)
input           TxUsedData;     // Transmit packet used data
input           TxRetry;        // Transmit packet retry
input           TxAbort;        // Transmit packet abort
input           TxDone;         // Transmission ended
output          TxStartFrm;     // Transmit packet start frame
output          TxEndFrm;       // Transmit packet end frame
output  [7:0]   TxData;         // Transmit packet data byte
output          TxUnderRun;     // Transmit packet under-run
output          PerPacketCrcEn; // Per packet crc enable
output          PerPacketPad;   // Per packet pading

// Rx
input 			Length_Vs_Payload_error;
input 			Length_vs_payload_mismatch;
input           MRxClk;         // Receive clock (from PHY)
input   [7:0]   RxData;         // Received data byte (from PHY)
input           RxValid;        // 
input           RxStartFrm;     // 
input           RxEndFrm;       // 
input           RxAbort;        // This signal is set when address doesn't
                                // match.
output          RxStatusWriteLatched_sync2;

//Register
input           r_TxEn;         // Transmit enable
input           r_RxEn;         // Receive enable
input 			r_Pad;
input 			r_HugEn;
input 	[15:0]	r_MinFL;
input 	[15:0]	r_MaxFL;
input   [7:0]   r_TxBDNum;      // Receive buffer descriptor number
output 	reg [15:0]	BD_TxLength;
// Interrupts
output TxB_IRQ;
output TxE_IRQ;
output RxB_IRQ;
output RxE_IRQ;
output Busy_IRQ;


// Bist
`ifdef ETH_BIST
input   mbist_si_i;       // bist scan serial in
output  mbist_so_o;       // bist scan serial out
input [`ETH_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i; // bist chain shift control
`endif

`ifdef WISHBONE_DEBUG
   output [31:0]                       dbg_dat0;
`endif

reg TxB_IRQ;
reg TxE_IRQ;
reg RxB_IRQ;
reg RxE_IRQ;

reg             TxStartFrm;
reg             TxEndFrm;
reg     [7:0]   TxData;

reg             TxUnderRun;
reg             TxUnderRun_wb;

reg             TxBDRead;
wire            TxStatusWrite;
reg            TxStatusWrite_f1;
reg            TxStatusWrite_f2;
reg            TxStatusWrite_f3;
reg            TxStatusWrite_f4;
reg            TxStatusWrite_f5;
reg            TxStatusWrite_f6;

reg     [1:0]   TxValidBytesLatched;

reg    [15:0]   TxLength;
reg    [15:0]   LatchedTxLength;
reg   [14:11]   TxStatus;

reg   [14:13]   RxStatus;

reg             TxStartFrm_wb;
reg             TxRetry_wb;
reg             TxAbort_wb;
reg             TxDone_wb;

reg             TxDone_wb_q;
reg             TxAbort_wb_q;
reg             TxRetry_wb_q;
reg             TxRetryPacket;
reg             TxRetryPacket_NotCleared;
reg             TxDonePacket;
reg             TxDonePacket_NotCleared;
reg             TxAbortPacket;
reg             TxAbortPacket_NotCleared;
reg             RxBDReady;
reg             RxReady;
reg             TxBDReady;

reg             RxBDRead;

reg    [31:0]   TxDataLatched;
reg     [1:0]   TxByteCnt;
reg             LastWord;
reg             ReadTxDataFromFifo_tck;

reg             BlockingTxStatusWrite;
reg             BlockingTxBDRead;

reg             Flop;


reg     [7:1]   TxBDAddress;
reg     [7:1]   RxBDAddress;

reg             TxRetrySync1;
reg             TxAbortSync1;
reg             TxDoneSync1;

reg             TxAbort_q;
reg             TxRetry_q;
reg             TxUsedData_q;

reg    [31:0]   RxDataLatched2;

reg    [31:8]   RxDataLatched1;     // Big Endian Byte Ordering

reg     [1:0]   RxValidBytes;
reg     [1:0]   RxByteCnt;
reg             LastByteIn;
reg             ShiftWillEnd;

reg             WriteRxDataToFifo;
reg    [15:0]   LatchedRxLength;
reg             RxAbortLatched;

reg             ShiftEnded;
reg             RxOverrun;

reg     [3:0]   BDWrite;                    // BD Write Enable for access from WISHBONE side
wire    [3:0]   BDWrite_next;
reg             BDRead;                     // BD Read access from WISHBONE side
wire   [31:0]   RxBDDataIn;                 // Rx BD data in
wire   [31:0]   TxBDDataIn;                 // Tx BD data in

reg             TxEndFrm_wb;

wire            TxRetryPulse;
wire            TxDonePulse;
wire            TxAbortPulse;

wire            StartRxBDRead;

wire            StartTxBDRead;

wire            TxIRQEn;
wire            WrapTxStatusBit;

wire            RxIRQEn;
wire            WrapRxStatusBit;

wire    [1:0]   TxValidBytes;

wire    [7:1]   TempTxBDAddress;
wire    [7:1]   TempRxBDAddress;

wire            RxStatusWrite;
wire            RxBufferFull;
wire            RxBufferAlmostEmpty;
wire            RxBufferEmpty;

reg             WB_ACK_O;

wire    [8:0]   RxStatusIn;
reg     [8:0]   RxStatusInLatched;

reg WbEn, WbEn_q;
reg RxEn, RxEn_q;
reg TxEn, TxEn_q;
reg r_TxEn_q;
reg r_RxEn_q;

wire ram_ce;
wire [3:0]  ram_we;
wire ram_oe;
reg [7:0]   ram_addr;
reg [31:0]  ram_di;
wire [31:0] ram_do;

reg StartTxPointerRead;
reg TxPointerRead;
reg TxEn_needed;
reg RxEn_needed;

wire StartRxPointerRead;
reg RxPointerRead;

// RX shift ending signals
reg ShiftEnded_rck;
reg ShiftEndedSync1;
reg ShiftEndedSync2;
reg ShiftEndedSync3;
reg ShiftEndedSync_c1;
reg ShiftEndedSync_c2;

wire StartShiftWillEnd;

reg StartOccured;
reg TxStartFrm_sync1;
reg TxStartFrm_sync2;
reg TxStartFrm_syncb1;
reg TxStartFrm_syncb2;

wire TxFifoClear;
wire TxBufferAlmostFull;
wire TxBufferFull;
wire TxBufferEmpty;
wire TxBufferAlmostEmpty;
wire SetReadTxDataFromMemory;
reg BlockReadTxDataFromMemory;

reg tx_burst_en;
reg rx_burst_en;
reg  [`ETH_BURST_CNT_WIDTH-1:0] tx_burst_cnt;

wire ReadTxDataFromMemory_2;
wire tx_burst;

reg Tx_BAD_FRAME;
reg Tx_BAD_FRAME_f1;
reg Tx_BAD_FRAME_f2;
reg Tx_BAD_FRAME_f3;
reg Tx_BAD_FRAME_f4;
reg Tx_BAD_FRAME_f5;
reg Tx_BAD_FRAME_f6;

wire [31:0] TxData_wb;
wire ReadTxDataFromFifo_wb;

wire [TX_FIFO_CNT_WIDTH-1:0] txfifo_cnt;
wire [RX_FIFO_CNT_WIDTH-1:0] rxfifo_cnt;

reg  [`ETH_BURST_CNT_WIDTH-1:0] rx_burst_cnt;

wire rx_burst;
wire enough_data_in_rxfifo_for_burst;
wire enough_data_in_rxfifo_for_burst_plus1;

reg ReadTxDataFromMemory;
wire WriteRxDataToMemory;

reg MasterWbTX;
reg MasterWbRX;

reg [29:0] m_wb_adr_o;
reg        m_penable_o_delayed;
reg        m_wb_we_o;
reg [3:0] m_wb_stb_o;

wire TxLengthEq0;
wire TxLengthLt4;

reg BlockingIncrementTxPointer;
reg [31:2] TxPointerMSB;
reg [1:0]  TxPointerLSB;
reg [1:0]  TxPointerLSB_rst;
reg [31:2] RxPointerMSB;
reg [1:0]  RxPointerLSB_rst;

wire RxBurstAcc;
wire RxWordAcc;
wire RxHalfAcc;
wire RxByteAcc;

wire ResetTxBDReady;
reg BlockingTxStatusWrite_sync1;
reg BlockingTxStatusWrite_sync2;
reg BlockingTxStatusWrite_sync3;

reg cyc_cleared;
reg IncrTxPointer;

reg  [3:0] RxByteSel;
wire MasterAccessFinished;

reg LatchValidBytes;
reg LatchValidBytes_q;

// Start: Generation of the ReadTxDataFromFifo_tck signal and synchronization to the WB_CLK_I
reg ReadTxDataFromFifo_sync1;
reg ReadTxDataFromFifo_sync2;
reg ReadTxDataFromFifo_sync3;
reg ReadTxDataFromFifo_syncb1;
reg ReadTxDataFromFifo_syncb2;
reg ReadTxDataFromFifo_syncb3;

reg RxAbortSync1;
reg RxAbortSync2;
reg RxAbortSync3;
reg RxAbortSync4;
reg RxAbortSyncb1;
reg RxAbortSyncb2;

reg RxEnableWindow;

reg SetWriteRxDataToFifo;
//reg[1:0]  stretch_rxfifo_wr_append_0sto_datain;

reg WriteRxDataToFifoSync1;
reg WriteRxDataToFifoSync2;
reg WriteRxDataToFifoSync3;

wire WriteRxDataToFifo_wb;

reg LatchedRxStartFrm;
reg SyncRxStartFrm;
reg SyncRxStartFrm_q;
reg SyncRxStartFrm_q2;
wire RxFifoReset;

wire TxError;
wire RxError;

wire TxLength_error1;
wire TxLength_error2;

reg RxStatusWriteLatched;
reg RxStatusWriteLatched_sync1;
reg RxStatusWriteLatched_sync2;
reg RxStatusWriteLatched_syncb1;
reg RxStatusWriteLatched_syncb2;
reg   m_ack_sig;
reg   m_wb_cyc_o;


assign m_wb_bte_o = 2'b00;    // Linear burst


assign m_wb_sel_o = m_wb_cyc_o;

always @ (posedge WB_CLK_I)
begin
  WB_ACK_O <= (|BDWrite) & WbEn & WbEn_q | BDRead & WbEn & ~WbEn_q;
end

assign WB_DAT_O = ram_do;

// Generic synchronous single-port RAM interface
eth_spram_256x32
     bd_ram
     (
      .clk     (WB_CLK_I),
      .rstn    (Resetn),
      .ce      (ram_ce),
      .we      (ram_we),
      .oe      (ram_oe),
      .addr    (ram_addr),
      .di      (ram_di),
      .dato    (ram_do)
`ifdef ETH_BIST
      ,
      .mbist_si_i       (mbist_si_i),
      .mbist_so_o       (mbist_so_o),
      .mbist_ctrl_i       (mbist_ctrl_i)
`endif
      );

assign ram_ce = 1'b1;
assign ram_we = (BDWrite & {4{(WbEn & WbEn_q)}}) |
                {4{(TxStatusWrite | RxStatusWrite)}};
assign ram_oe = ((BDRead & WbEn & WbEn_q )|( TxEn & TxEn_q &
                (TxBDRead | TxPointerRead)) | (RxEn & RxEn_q &
                (RxBDRead | RxPointerRead)));

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxEn_needed <= 1'b0;
  else
  if(~TxBDReady & r_TxEn & WbEn & ~WbEn_q)
    TxEn_needed <= 1'b1;
  else
  if(TxPointerRead & TxEn & TxEn_q)
    TxEn_needed <= 1'b0;
end


assign BDWrite_next = BDCs[3:0] & {4{WB_WE_I}};
// Enabling access to the RAM for three devices.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      WbEn <= 1'b1;
      RxEn <= 1'b0;
      TxEn <= 1'b0;
      ram_addr <= 8'h0;
      ram_di <= 32'h0;
      BDRead <= 1'b0;
      BDWrite <= 0;
    end
  else
    begin
      // Switching between three stages depends on enable signals
     /* verilator lint_off CASEINCOMPLETE */ // JB
      case ({WbEn_q, RxEn_q, TxEn_q, RxEn_needed, TxEn_needed})  // synopsys parallel_case
        5'b100_10, 5'b100_11 :
          begin
            WbEn <= 1'b0;
            RxEn <= 1'b1;  // wb access stage and r_RxEn is enabled
            TxEn <= 1'b0;
            ram_addr <= {RxBDAddress, RxPointerRead};
            ram_di <= RxBDDataIn;
          end
        5'b100_01 :
          begin
            WbEn <= 1'b0;
            RxEn <= 1'b0;
            TxEn <= 1'b1;  // wb access stage, r_RxEn is disabled but
                           // r_TxEn is enabled
            ram_addr <= {TxBDAddress, TxPointerRead};
            ram_di <= TxBDDataIn;
          end
        5'b010_00, 5'b010_10 :
          begin
            WbEn <= 1'b1;  // RxEn access stage and r_TxEn is disabled
            RxEn <= 1'b0;
            TxEn <= 1'b0;
            ram_addr <= WB_ADDR_I[9:2];
            ram_di <= WB_DAT_I;
			BDWrite <= BDWrite_next;
            BDRead <= (|BDCs) & ~WB_WE_I;
          end
        5'b010_01, 5'b010_11 :
          begin
            WbEn <= 1'b0;
            RxEn <= 1'b0;
            TxEn <= 1'b1;  // RxEn access stage and r_TxEn is enabled
            ram_addr <= {TxBDAddress, TxPointerRead};
            ram_di <= TxBDDataIn;
          end
        5'b001_00, 5'b001_01, 5'b001_10, 5'b001_11 :
          begin
            WbEn <= 1'b1;  // TxEn access stage (we always go to wb
                           // access stage)
            RxEn <= 1'b0;
            TxEn <= 1'b0;
            ram_addr <= WB_ADDR_I[9:2];
            ram_di <= WB_DAT_I;
			BDWrite <= BDWrite_next;
            BDRead <= (|BDCs) & ~WB_WE_I;
          end
        5'b100_00 :
          begin
            WbEn <= 1'b0;  // WbEn access stage and there is no need
                           // for other stages. WbEn needs to be
                           // switched off for a bit
          end
        5'b000_00 :
          begin
            WbEn <= 1'b1;  // Idle state. We go to WbEn access stage.
            RxEn <= 1'b0;
            TxEn <= 1'b0;
            ram_addr <= WB_ADDR_I[9:2];
            ram_di <= WB_DAT_I;
			BDWrite <= BDWrite_next;
            BDRead <= (|BDCs) & ~WB_WE_I;
          end
      endcase
      /* verilator lint_on CASEINCOMPLETE */
    end
end


// Delayed stage signals
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      WbEn_q <= 1'b0;
      RxEn_q <= 1'b0;
      TxEn_q <= 1'b0;
      r_TxEn_q <= 1'b0;
      r_RxEn_q <= 1'b0;
    end
  else
    begin
      WbEn_q <= WbEn;
      RxEn_q <= RxEn;
      TxEn_q <= TxEn;
      r_TxEn_q <= r_TxEn;
      r_RxEn_q <= r_RxEn;
    end
end

// Changes for tx occur every second clock. Flop is used for this manner.
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    Flop <= 1'b0;
  else
  if(TxDone | TxAbort | TxRetry_q)
    Flop <= 1'b0;
  else
  if(TxUsedData)
    Flop <= ~Flop;
end



assign ResetTxBDReady = TxDonePulse | TxAbortPulse | TxRetryPulse | Tx_BAD_FRAME; 

// Latching READY status of the Tx buffer descriptor
always @(posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxBDReady <= 1'b0;
  else
  if(TxEn & TxEn_q & TxBDRead)
    // TxBDReady is sampled only once at the beginning.
    TxBDReady <= ram_do[15] & (ram_do[31:16] > 4);
  else
  // Only packets larger then 4 bytes are transmitted.
  if(ResetTxBDReady)
    TxBDReady <= 1'b0;
end

// Reading the Tx buffer descriptor
assign StartTxBDRead = (TxRetryPacket_NotCleared | TxStatusWrite_f6 ) &
                       ~BlockingTxBDRead & ~TxBDReady;

always @(posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxBDRead <= 1'b1;
  else
   if(StartTxBDRead) 
    begin
		TxBDRead <= 1'b1;
    end
  else
  if(TxBDReady)
    TxBDRead <= 1'b0;
end
// Reading Tx BD pointer

always@(*)
begin

	if(TxBDRead & TxBDReady)
	begin
		if((BD_TxLength + 'd18) < r_MinFL)
			begin
			if(r_Pad==1)
				begin
					StartTxPointerRead = 1;
					Tx_BAD_FRAME = 0;
				end
				else
				begin
					StartTxPointerRead = 0;
					Tx_BAD_FRAME = 1;
				end
			end
		else if((BD_TxLength + 'd18) > r_MaxFL)	//The frame should be less than are equal to 2kb
			begin 
				if(r_HugEn && ((BD_TxLength + 'd18) <= 'd2048))
				begin
					StartTxPointerRead = 1;
					Tx_BAD_FRAME = 0;
				end
				else
				begin
					StartTxPointerRead = 0;
					Tx_BAD_FRAME = 1;
				end
			end
		else begin
			StartTxPointerRead = 1; 
			Tx_BAD_FRAME = 0;
			end
	end
	else
	begin
		StartTxPointerRead = 0;
		Tx_BAD_FRAME = 0;
	end
end
//Added by Moschip team
// Reading Tx BD Pointer
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxPointerRead <= 1'b0;
  else
  if(StartTxPointerRead)
    TxPointerRead <= 1'b1;
  else
  if(TxEn_q)
    TxPointerRead <= 1'b0;
end


// Writing status back to the Tx buffer descriptor
assign TxStatusWrite = ((TxDonePacket_NotCleared | TxAbortPacket_NotCleared) &
                       TxEn & TxEn_q & ~BlockingTxStatusWrite) | Tx_BAD_FRAME_f6;

//Note: When BAD frame comes, the int_o signal is generated at sametime for good and bad frame
always @(posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
  begin
	TxStatusWrite_f1 <= 0;
	TxStatusWrite_f2 <= 0;
	TxStatusWrite_f3 <= 0;
	TxStatusWrite_f4 <= 0;
	TxStatusWrite_f5 <= 0;
	TxStatusWrite_f6 <= 0;
  end	
  else
  begin 			  
	TxStatusWrite_f1 <= TxStatusWrite; 
	TxStatusWrite_f2 <= TxStatusWrite_f1; 
	TxStatusWrite_f3 <= TxStatusWrite_f2; 
	TxStatusWrite_f4 <= TxStatusWrite_f3; 
	TxStatusWrite_f5 <= TxStatusWrite_f4; 
	TxStatusWrite_f6 <= TxStatusWrite_f5; 
  end
end

always @(posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
  begin
	Tx_BAD_FRAME_f1 <= 0;
	Tx_BAD_FRAME_f2 <= 0;
	Tx_BAD_FRAME_f3 <= 0;
	Tx_BAD_FRAME_f4 <= 0;
	Tx_BAD_FRAME_f5 <= 0;
	Tx_BAD_FRAME_f6 <= 0;
  end	
  else
  begin 			  
	Tx_BAD_FRAME_f1 <= Tx_BAD_FRAME; 
	Tx_BAD_FRAME_f2 <= Tx_BAD_FRAME_f1; 
	Tx_BAD_FRAME_f3 <= Tx_BAD_FRAME_f2; 
	Tx_BAD_FRAME_f4 <= Tx_BAD_FRAME_f3; 
	Tx_BAD_FRAME_f5 <= Tx_BAD_FRAME_f4; 
	Tx_BAD_FRAME_f6 <= Tx_BAD_FRAME_f5; 
  end
end


// Status writing must occur only once. Meanwhile it is blocked.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingTxStatusWrite <= 1'b0;
  else
  if(~TxDone_wb & ~TxAbort_wb)
    BlockingTxStatusWrite <= 1'b0;
  else
  if(TxStatusWrite_f6)
    BlockingTxStatusWrite <= 1'b1;
end


// Synchronizing BlockingTxStatusWrite to MTxClk
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingTxStatusWrite_sync1 <= 1'b0;
  else
    BlockingTxStatusWrite_sync1 <= BlockingTxStatusWrite;
end

// Synchronizing BlockingTxStatusWrite to MTxClk
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingTxStatusWrite_sync2 <= 1'b0;
  else
    BlockingTxStatusWrite_sync2 <= BlockingTxStatusWrite_sync1;
end

// Synchronizing BlockingTxStatusWrite to MTxClk
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingTxStatusWrite_sync3 <= 1'b0;
  else
    BlockingTxStatusWrite_sync3 <= BlockingTxStatusWrite_sync2;
end

assign RstDeferLatched = BlockingTxStatusWrite_sync2 &
                         ~BlockingTxStatusWrite_sync3;

// TxBDRead state is activated only once. 
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingTxBDRead <= 1'b0;
  else
  if(StartTxBDRead)
    BlockingTxBDRead <= 1'b1;
  else
  if(~StartTxBDRead & ~TxBDReady)
    BlockingTxBDRead <= 1'b0;
end


// Latching status from the tx buffer descriptor
// Data is avaliable one cycle after the access is started (at that time
// signal TxEn is not active)

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxStatus <= 4'h0;
  else
  if(TxEn & TxEn_q & TxBDRead)
    TxStatus <= ({ram_do[14],1'b0,1'b0,1'b1});
end

//adding

always @ (posedge WB_CLK_I or negedge Resetn)
begin
	if(Resetn == 0)
		BD_TxLength <= 16'h0;
	else
	begin
		if(TxEn & TxEn_q & TxBDRead)
			BD_TxLength <= ram_do[31:16];
	end
end

//Latching length from the buffer descriptor;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxLength <= 16'h0;
  else
  if(TxEn & TxEn_q & TxBDRead)
    TxLength <= ram_do[31:16];
  else
  if(MasterWbTX & m_ack_sig)
    begin
      if(TxLengthLt4)
        TxLength <= 16'h0;
      else if(TxPointerLSB_rst==2'h0)
        TxLength <= TxLength - 16'd4;    // Length is subtracted at
                                        // the data request
      else if(TxPointerLSB_rst==2'h1)
        TxLength <= TxLength - 16'd3;    // Length is subtracted
                                         // at the data request
      else if(TxPointerLSB_rst==2'h2)
        TxLength <= TxLength - 16'd2;    // Length is subtracted
                                         // at the data request
      else if(TxPointerLSB_rst==2'h3)
        TxLength <= TxLength - 16'd1;    // Length is subtracted
                                         // at the data request
    end
	
end

//Latching length from the buffer descriptor;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    LatchedTxLength <= 16'h0;
  else
  if(TxEn & TxEn_q & TxBDRead)
    LatchedTxLength <= ram_do[31:16];
end

assign TxLengthEq0 = TxLength == 0;
assign TxLengthLt4 = TxLength < 4;


// Latching Tx buffer pointer from buffer descriptor. Only 30 MSB bits are
// latched because TxPointerMSB is only used for word-aligned accesses.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxPointerMSB <= 30'h0;
  else
  if(TxEn & TxEn_q & TxPointerRead)
    TxPointerMSB <= ram_do[31:2];
  else
  if(IncrTxPointer & ~BlockingIncrementTxPointer)
    TxPointerMSB <= TxPointerMSB + 1'b1;
end


// Latching 2 MSB bits of the buffer descriptor. Since word accesses are
// performed, valid data does not necesserly start at byte 0 (could be byte
// 0, 1, 2 or 3). This signals are used for proper selection of the start
// byte (TxData and TxByteCnt) are set by this two bits.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxPointerLSB[1:0] <= 0;
  else
  if(TxEn & TxEn_q & TxPointerRead)
    TxPointerLSB[1:0] <= ram_do[1:0];
end


// Latching 2 MSB bits of the buffer descriptor. 
// After the read access, TxLength needs to be decremented for the number of
// the valid bytes (1 to 4 bytes are valid in the first word). After the
// first read all bytes are valid so this two bits are Resetn to zero. 
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxPointerLSB_rst[1:0] <= 0;
  else
  if(TxEn & TxEn_q & TxPointerRead)
    TxPointerLSB_rst[1:0] <= ram_do[1:0];
  else
// After first access pointer is word alligned
  if(MasterWbTX & m_ack_sig)
    TxPointerLSB_rst[1:0] <= 0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    BlockingIncrementTxPointer <= 0;
  else
  if(MasterAccessFinished)
    BlockingIncrementTxPointer <= 0;
  else
  if(IncrTxPointer)
    BlockingIncrementTxPointer <= 1'b1;
end


assign SetReadTxDataFromMemory = TxEn & TxEn_q & TxPointerRead;

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromMemory <= 1'b0;
  else
  if(TxLengthEq0 | TxAbortPulse | TxRetryPulse)
    ReadTxDataFromMemory <= 1'b0;
  else
  if(SetReadTxDataFromMemory)
    ReadTxDataFromMemory <= 1'b1;
end

assign ReadTxDataFromMemory_2 = ReadTxDataFromMemory &
                                ~BlockReadTxDataFromMemory;

assign tx_burst = ReadTxDataFromMemory_2 & tx_burst_en;

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    BlockReadTxDataFromMemory <= 1'b0;
  else
  if((TxBufferAlmostFull | TxLength <= 4) & MasterWbTX & (~cyc_cleared) &
     (!(TxAbortPacket_NotCleared | TxRetryPacket_NotCleared)))
    BlockReadTxDataFromMemory <= 1'b1;
  else
  if(ReadTxDataFromFifo_wb | TxDonePacket | TxAbortPacket | TxRetryPacket)
    BlockReadTxDataFromMemory <= 1'b0;
end


assign MasterAccessFinished = m_ack_sig | m_wb_err_i;

//adding statemachine 
//Note: Making wishbone signals to compatible with apb protocol
//		Inorder to acheive apb protocol rules generating the expected penable(m_wb_cyc_o_delayed_next_state) signal using below state machine 
//		Also generating the pready(m_ack_sig) signal, when the wishbone is capturing the data. 


localparam IDLE = 0,STATE1 = 1,STATE0 = 2;
reg [1:0] state;
reg m_wb_cyc_o_delayed_next_state;
always @(posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
   state <= IDLE;
  else
   begin
	  case(state)
	     IDLE: state <= m_wb_cyc_o === 1? STATE1:IDLE;
		 STATE1: state <= m_wb_ack_i === 1?STATE0:STATE1;
		 STATE0: state <= m_wb_cyc_o === 1?STATE1:STATE0;
	  endcase
	end
end

always@(*)
begin
  case(state)
    IDLE: begin 
				m_wb_cyc_o_delayed_next_state = 0;
				m_ack_sig = 0;
			end
	 STATE1: begin
				m_wb_cyc_o_delayed_next_state = m_wb_cyc_o;
				m_ack_sig = m_wb_ack_i;
				end
	 STATE0: begin 
				m_wb_cyc_o_delayed_next_state = 0;
				m_ack_sig = 0;
				end
  endcase
end



// Enabling master wishbone access to the memory for two devices TX and RX.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      MasterWbTX <= 1'b0;
      MasterWbRX <= 1'b0;
      m_wb_adr_o <= 30'h0;
      m_wb_cyc_o <= 1'b0;
      m_wb_we_o  <= 1'b0;
      m_wb_stb_o <= 4'h0;
      cyc_cleared<= 1'b0;
      tx_burst_cnt<= 0;
      rx_burst_cnt<= 0;
      IncrTxPointer<= 1'b0;
      tx_burst_en<= 1'b1;
      rx_burst_en<= 1'b0;
      m_wb_cti_o <= 3'b0;
    end
  else
    begin
      // Switching between two stages depends on enable signals
      casez ({MasterWbTX,
             MasterWbRX,
             ReadTxDataFromMemory_2,
             WriteRxDataToMemory,
             MasterAccessFinished,
             cyc_cleared,
             tx_burst,
             rx_burst})  // synopsys parallel_case

        8'b00_10_00_10, // Idle and MRB needed
        8'b10_1?_10_1?, // MRB continues
        8'b10_10_01_10, // Clear (previously MR) and MRB needed
        8'b01_1?_01_1?: // Clear (previously MW) and MRB needed
          begin
            MasterWbTX <= 1'b1;  // tx burst
            MasterWbRX <= 1'b0;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b0;
            m_wb_stb_o <= 4'hf;
            cyc_cleared<= 1'b0;
            IncrTxPointer<= 1'b1;
            tx_burst_cnt <= tx_burst_cnt+3'h1;
            if(tx_burst_cnt==0)
              m_wb_adr_o <= TxPointerMSB;
            else
              m_wb_adr_o <= m_wb_adr_o + 1'b1;
            if(tx_burst_cnt==(`ETH_BURST_LENGTH-1))
              begin
                tx_burst_en<= 1'b0;
                m_wb_cti_o <= 3'b111;
              end
            else
              begin
                m_wb_cti_o <= 3'b010;
              end
          end
        8'b00_?1_00_?1,             // Idle and MWB needed
        8'b01_?1_10_?1,             // MWB continues
        8'b01_01_01_01,             // Clear (previously MW) and MWB needed
        8'b10_?1_01_?1 :            // Clear (previously MR) and MWB needed
          begin
            MasterWbTX <= 1'b0;  // rx burst
            MasterWbRX <= 1'b1;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b1;
            m_wb_stb_o <= RxByteSel;
            IncrTxPointer<= 1'b0;
            cyc_cleared<= 1'b0;
            rx_burst_cnt <= rx_burst_cnt+3'h1;

            if(rx_burst_cnt==0)
              m_wb_adr_o <= RxPointerMSB;
            else
              m_wb_adr_o <= m_wb_adr_o+1'b1;

            if(rx_burst_cnt==(`ETH_BURST_LENGTH-1))
              begin
                rx_burst_en<= 1'b0;
                m_wb_cti_o <= 3'b111;
              end
            else
              begin
                m_wb_cti_o <= 3'b010;
              end
          end
        8'b00_?1_00_?0 :// idle and MW is needed (data write to rx buffer)
          begin
            MasterWbTX <= 1'b0;
            MasterWbRX <= 1'b1;
            m_wb_adr_o <= RxPointerMSB;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b1;
            m_wb_stb_o <= RxByteSel;
            IncrTxPointer<= 1'b0;
          end
        8'b00_10_00_00 : // idle and MR is needed (data read from tx buffer)
          begin
            MasterWbTX <= 1'b1;
            MasterWbRX <= 1'b0;
            m_wb_adr_o <= TxPointerMSB;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b0;
            m_wb_stb_o <= 4'hf;
            IncrTxPointer<= 1'b1;
          end
        8'b10_10_01_00,// MR and MR is needed (data read from tx buffer)
        8'b01_1?_01_0?  :// MW and MR is needed (data read from tx buffer)
          begin
            MasterWbTX <= 1'b1;
            MasterWbRX <= 1'b0;
            m_wb_adr_o <= TxPointerMSB;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b0;
            m_wb_stb_o <= 4'hf;
            cyc_cleared<= 1'b0;
            IncrTxPointer<= 1'b1;
          end
        8'b01_01_01_00,// MW and MW needed (data write to rx buffer)
        8'b10_?1_01_?0 :// MR and MW is needed (data write to rx buffer)
          begin
            MasterWbTX <= 1'b0;
            MasterWbRX <= 1'b1;
            m_wb_adr_o <= RxPointerMSB;
            m_wb_cyc_o <= 1'b1;
            m_wb_we_o  <= 1'b1;
            m_wb_stb_o <= RxByteSel;
            cyc_cleared<= 1'b0;
            IncrTxPointer<= 1'b0;
          end
        8'b01_01_10_00,// MW and MW needed (cycle is cleared between
                      // previous and next access)
        8'b01_1?_10_?0,// MW and MW or MR or MRB needed (cycle is
                    // cleared between previous and next access)
        8'b10_10_10_00,// MR and MR needed (cycle is cleared between
                       // previous and next access)
        8'b10_?1_10_0? :// MR and MR or MW or MWB (cycle is cleared
                       // between previous and next access)
          begin
            m_wb_cyc_o <= 1'b0;// whatever and master read or write is
                               // needed. We need to clear m_wb_cyc_o
                               // before next access is started
            cyc_cleared<= 1'b1;
            IncrTxPointer<= 1'b0;
            tx_burst_cnt<= 0;
            tx_burst_en<= txfifo_cnt<(TX_FIFO_DEPTH-`ETH_BURST_LENGTH) & (TxLength>(`ETH_BURST_LENGTH*4+4));
            rx_burst_cnt<= 0;
            rx_burst_en<= MasterWbRX ? enough_data_in_rxfifo_for_burst_plus1 : enough_data_in_rxfifo_for_burst;  // Counter is not decremented, yet, so plus1 is used.
              m_wb_cti_o <= 3'b0;
          end
        8'b??_00_10_00,// whatever and no master read or write is needed
                       // (ack or err comes finishing previous access)
        8'b??_00_01_00 : // Between cyc_cleared request was cleared
          begin
            MasterWbTX <= 1'b0;
            MasterWbRX <= 1'b0;
            m_wb_cyc_o <= 1'b0;
            cyc_cleared<= 1'b0;
            IncrTxPointer<= 1'b0;
            rx_burst_cnt<= 0;
            // Counter is not decremented, yet, so plus1 is used.
            rx_burst_en<= MasterWbRX ? enough_data_in_rxfifo_for_burst_plus1 :
                                       enough_data_in_rxfifo_for_burst;
            m_wb_cti_o <= 3'b0;
          end
        8'b00_00_00_00:  // whatever and no master read or write is needed
                         // (ack or err comes finishing previous access)
          begin
            tx_burst_cnt<= 0;
            tx_burst_en<= txfifo_cnt<(TX_FIFO_DEPTH-`ETH_BURST_LENGTH) & (TxLength>(`ETH_BURST_LENGTH*4+4));
          end
        default:                    // Don't touch
          begin
            MasterWbTX <= MasterWbTX;
            MasterWbRX <= MasterWbRX;
            m_wb_cyc_o <= m_wb_cyc_o;
            m_wb_stb_o <= m_wb_stb_o;
            IncrTxPointer<= IncrTxPointer;
          end
      endcase
    end
end


assign TxFifoClear = (TxAbortPacket | TxRetryPacket);

eth_fifo
     #(
       .DATA_WIDTH(TX_FIFO_DATA_WIDTH),
       .DEPTH(TX_FIFO_DEPTH),
       .CNT_WIDTH(TX_FIFO_CNT_WIDTH))
tx_fifo (
       .data_in(m_wb_dat_i),
       .data_out(TxData_wb),
       .clk(WB_CLK_I),
       .resetn(Resetn),
       .write(MasterWbTX & m_ack_sig),
       .read(ReadTxDataFromFifo_wb & ~TxBufferEmpty),
       .clear(TxFifoClear),
       .full(TxBufferFull), 
       .almost_full(TxBufferAlmostFull),
       .almost_empty(TxBufferAlmostEmpty),
       .empty(TxBufferEmpty),
       .cnt(txfifo_cnt)
       );

// Start: Generation of the TxStartFrm_wb which is then synchronized to the
// MTxClk
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm_wb <= 1'b0;
  else
  if(TxBDReady & ~StartOccured & (TxBufferFull | TxLengthEq0))
    TxStartFrm_wb <= 1'b1;
  else
  if(TxStartFrm_syncb2)
    TxStartFrm_wb <= 1'b0;
end

// StartOccured: TxStartFrm_wb occurs only ones at the beginning. Then it's
// blocked.
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    StartOccured <= 1'b0;
  else
  if(TxStartFrm_wb)
    StartOccured <= 1'b1;
  else
  if(ResetTxBDReady)
    StartOccured <= 1'b0;
end

// Synchronizing TxStartFrm_wb to MTxClk
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm_sync1 <= 1'b0;
  else
    TxStartFrm_sync1 <= TxStartFrm_wb;
end

always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm_sync2 <= 1'b0;
  else
    TxStartFrm_sync2 <= TxStartFrm_sync1;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm_syncb1 <= 1'b0;
  else
    TxStartFrm_syncb1 <= TxStartFrm_sync2;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm_syncb2 <= 1'b0;
  else
    TxStartFrm_syncb2 <= TxStartFrm_syncb1;
end

always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxStartFrm <= 1'b0;
  else
  if(TxStartFrm_sync2)
    TxStartFrm <= 1'b1;
  else
  if(TxUsedData_q | ~TxStartFrm_sync2 &
     (TxRetry & (~TxRetry_q) | TxAbort & (~TxAbort_q)))
    TxStartFrm <= 1'b0;
end
// End: Generation of the TxStartFrm_wb which is then synchronized to the
// MTxClk


// TxEndFrm_wb: indicator of the end of frame
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxEndFrm_wb <= 1'b0;
  else
  if(TxLengthEq0 & TxBufferAlmostEmpty & TxUsedData)
    TxEndFrm_wb <= 1'b1;
  else
  if(TxRetryPulse | TxDonePulse | TxAbortPulse)
    TxEndFrm_wb <= 1'b0;
end

// Marks which bytes are valid within the word.
assign TxValidBytes = TxLengthLt4 ? TxLength[1:0] : 2'b0;


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    LatchValidBytes <= 1'b0;
  else
  if(TxLengthLt4 & TxBDReady)
    LatchValidBytes <= 1'b1;
  else
    LatchValidBytes <= 1'b0;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    LatchValidBytes_q <= 1'b0;
  else
    LatchValidBytes_q <= LatchValidBytes;
end


// Latching valid bytes
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxValidBytesLatched <= 2'h0;
  else
  if(LatchValidBytes & ~LatchValidBytes_q)
    TxValidBytesLatched <= TxValidBytes;
  else
  if(TxRetryPulse | TxDonePulse | TxAbortPulse)
    TxValidBytesLatched <= 2'h0;
end


assign TxIRQEn          = TxStatus[14];
assign WrapTxStatusBit  = TxStatus[13];
assign PerPacketPad     = TxStatus[12];
assign PerPacketCrcEn   = TxStatus[11];


assign RxIRQEn         = RxStatus[14];
assign WrapRxStatusBit = RxStatus[13];


// Temporary Tx and Rx buffer descriptor address
assign TempTxBDAddress[7:1] = {7{ TxStatusWrite_f6  & ~WrapTxStatusBit}} &
                              (TxBDAddress + 1'b1); // Tx BD increment or wrap
                                                    // (last BD)

assign TempRxBDAddress[7:1] = 
  {7{ WrapRxStatusBit}} & (r_TxBDNum[6:0]) | // Using first Rx BD
  {7{~WrapRxStatusBit}} & (RxBDAddress + 1'b1); // Using next Rx BD
                                                // (increment address)

// Latching Tx buffer descriptor address
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxBDAddress <= 7'h0;
  else if (r_TxEn & (~r_TxEn_q))
    TxBDAddress <= 7'h0;
  else if (TxStatusWrite_f6)
    TxBDAddress <= TempTxBDAddress;
end

// Latching Rx buffer descriptor address
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxBDAddress <= 7'h0;
  else if(r_RxEn & (~r_RxEn_q))
    RxBDAddress <= r_TxBDNum[6:0];
  else if(RxStatusWrite)
    RxBDAddress <= TempRxBDAddress;
end

//Added by Moschip team on June 10 2020

wire [8:0] TxStatusInLatched = {1'b0, 4'h0,
                                1'b0, 1'b0, 1'b0,
                                1'b0};
								
//Added by Moschip team on June 29 2020
assign RxBDDataIn = {(LatchedRxLength -'d4), 1'b0, RxStatus, 4'h0, RxStatusInLatched};
assign TxBDDataIn = {LatchedTxLength, 1'b0, TxStatus, 2'h0, TxStatusInLatched};


// Signals used for various purposes
assign TxRetryPulse   = TxRetry_wb   & ~TxRetry_wb_q;
assign TxDonePulse    = TxDone_wb    & ~TxDone_wb_q;
assign TxAbortPulse   = TxAbort_wb   & ~TxAbort_wb_q;


// Generating delayed signals
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      TxAbort_q      <= 1'b0;
      TxRetry_q      <= 1'b0;
      TxUsedData_q   <= 1'b0;
    end
  else
    begin
      TxAbort_q      <= TxAbort;
      TxRetry_q      <= TxRetry;
      TxUsedData_q   <= TxUsedData;
    end
end

// Generating delayed signals
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      TxDone_wb_q   <= 1'b0;
      TxAbort_wb_q  <= 1'b0;
      TxRetry_wb_q  <= 1'b0;
    end
  else
    begin
      TxDone_wb_q   <= TxDone_wb;
      TxAbort_wb_q  <= TxAbort_wb;
      TxRetry_wb_q  <= TxRetry_wb;
    end
end


reg TxAbortPacketBlocked;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbortPacket <= 1'b0;
  else
  if(TxAbort_wb & (~tx_burst_en) & MasterWbTX & MasterAccessFinished &
    (~TxAbortPacketBlocked) | TxAbort_wb & (~MasterWbTX) &
    (~TxAbortPacketBlocked))
    TxAbortPacket <= 1'b1;
  else
    TxAbortPacket <= 1'b0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbortPacket_NotCleared <= 1'b0;
  else
  if(TxEn & TxEn_q & TxAbortPacket_NotCleared)
    TxAbortPacket_NotCleared <= 1'b0;
  else
  if(TxAbort_wb & (~tx_burst_en) & MasterWbTX & MasterAccessFinished &
     (~TxAbortPacketBlocked) | TxAbort_wb & (~MasterWbTX) &
     (~TxAbortPacketBlocked))
    TxAbortPacket_NotCleared <= 1'b1;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbortPacketBlocked <= 1'b0;
  else
  if(!TxAbort_wb & TxAbort_wb_q)
    TxAbortPacketBlocked <= 1'b0;
  else
  if(TxAbortPacket)
    TxAbortPacketBlocked <= 1'b1;
end


reg TxRetryPacketBlocked;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetryPacket <= 1'b0;
  else
  if(TxRetry_wb & !tx_burst_en & MasterWbTX & MasterAccessFinished &
     !TxRetryPacketBlocked | TxRetry_wb & !MasterWbTX & !TxRetryPacketBlocked)
    TxRetryPacket <= 1'b1;
  else
    TxRetryPacket <= 1'b0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetryPacket_NotCleared <= 1'b0;
  else
  if(StartTxBDRead)
    TxRetryPacket_NotCleared <= 1'b0;
  else
  if(TxRetry_wb & !tx_burst_en & MasterWbTX & MasterAccessFinished &
     !TxRetryPacketBlocked | TxRetry_wb & !MasterWbTX & !TxRetryPacketBlocked)
    TxRetryPacket_NotCleared <= 1'b1;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetryPacketBlocked <= 1'b0;
  else
  if(!TxRetry_wb & TxRetry_wb_q)
    TxRetryPacketBlocked <= 1'b0;
  else
  if(TxRetryPacket)
    TxRetryPacketBlocked <= 1'b1;
end


reg TxDonePacketBlocked;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxDonePacket <= 1'b0;
  else
  if(TxDone_wb & !tx_burst_en & MasterWbTX & MasterAccessFinished &
     !TxDonePacketBlocked | TxDone_wb & !MasterWbTX & !TxDonePacketBlocked)
    TxDonePacket <= 1'b1;
  else
    TxDonePacket <= 1'b0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxDonePacket_NotCleared <= 1'b0;
  else
  if(TxEn & TxEn_q & TxDonePacket_NotCleared)
    TxDonePacket_NotCleared <= 1'b0;
  else
  if(TxDone_wb & !tx_burst_en & MasterWbTX & MasterAccessFinished &
     (~TxDonePacketBlocked) | TxDone_wb & !MasterWbTX & (~TxDonePacketBlocked))
    TxDonePacket_NotCleared <= 1'b1;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxDonePacketBlocked <= 1'b0;
  else
  if(!TxDone_wb & TxDone_wb_q)
    TxDonePacketBlocked <= 1'b0;
  else
  if(TxDonePacket)
    TxDonePacketBlocked <= 1'b1;
end


// Indication of the last word
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LastWord <= 1'b0;
  else
  if((TxEndFrm | TxAbort | TxRetry) & Flop)
    LastWord <= 1'b0;
  else
  if(TxUsedData & Flop & TxByteCnt == 2'h3)
    LastWord <= TxEndFrm_wb;
end


// Tx end frame generation
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxEndFrm <= 1'b0;
  else
  if(Flop & TxEndFrm | TxAbort | TxRetry_q)
    TxEndFrm <= 1'b0;        
  else
  if(Flop & LastWord)
    begin
      case (TxValidBytesLatched)  // synopsys parallel_case
        1 : TxEndFrm <= TxByteCnt == 2'h0;
        2 : TxEndFrm <= TxByteCnt == 2'h1;
        3 : TxEndFrm <= TxByteCnt == 2'h2;
        0 : TxEndFrm <= TxByteCnt == 2'h3;
        default : TxEndFrm <= 1'b0;
      endcase
    end
end

//Moschip Team
//Note: 1.When the TxPntr is 3,7,11,... Expected = Need to sample LSB Byte of first Location.
//		2.Actual = Sampled only LSB nibble of first location as LSB and MSB nibble is sampled from the next location as MSB nibble.

reg Delay_StartFrm1_TxUsedData1;
always @(posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
	  Delay_StartFrm1_TxUsedData1 <= 1'b0;
  else
  begin
		case(Delay_StartFrm1_TxUsedData1)
		0: begin
				if(TxStartFrm & TxUsedData & TxPointerLSB==2'h3)
					Delay_StartFrm1_TxUsedData1 <= 1;
		   end
		1: begin
				Delay_StartFrm1_TxUsedData1 <= 0;
		   end
		endcase
  end
end

// Tx data selection (latching)
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxData <= 0;
  else
  if(TxStartFrm_sync2 & ~TxStartFrm)
    case(TxPointerLSB)  // synopsys parallel_case
      2'h0 : TxData <= TxData_wb[31:24];// Big Endian Byte Ordering
      2'h1 : TxData <= TxData_wb[23:16];// Big Endian Byte Ordering
      2'h2 : TxData <= TxData_wb[15:08];// Big Endian Byte Ordering
      2'h3 : TxData <= TxData_wb[07:00];// Big Endian Byte Ordering
    endcase
  else
  if(Delay_StartFrm1_TxUsedData1)
    TxData <= TxData_wb[31:24];// Big Endian Byte Ordering
  else
  if(TxUsedData & Flop)
    begin
      case(TxByteCnt)  // synopsys parallel_case
        0 : TxData <= TxDataLatched[31:24];// Big Endian Byte Ordering
        1 : TxData <= TxDataLatched[23:16];
        2 : TxData <= TxDataLatched[15:8];
        3 : TxData <= TxDataLatched[7:0];
      endcase
    end
end


// Latching tx data
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxDataLatched[31:0] <= 32'h0;
  else
  if(TxStartFrm_sync2 & ~TxStartFrm | TxUsedData & Flop & TxByteCnt == 2'h3 |
     TxStartFrm & TxUsedData & Flop & TxByteCnt == 2'h0)
    TxDataLatched[31:0] <= TxData_wb[31:0];
end


// Tx under run
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxUnderRun_wb <= 1'b0;
  else
  if(TxAbortPulse)
    TxUnderRun_wb <= 1'b0;
  else
  if(TxBufferEmpty & ReadTxDataFromFifo_wb)
    TxUnderRun_wb <= 1'b1;
end


reg TxUnderRun_sync1;

// Tx under run
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxUnderRun_sync1 <= 1'b0;
  else
  if(TxUnderRun_wb)
    TxUnderRun_sync1 <= 1'b1;
  else
  if(BlockingTxStatusWrite_sync2)
    TxUnderRun_sync1 <= 1'b0;
end

// Tx under run
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxUnderRun <= 1'b0;
  else
  if(BlockingTxStatusWrite_sync2)
    TxUnderRun <= 1'b0;
  else
  if(TxUnderRun_sync1)
    TxUnderRun <= 1'b1;
end


// Tx Byte counter
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxByteCnt <= 2'h0;
  else
  if(TxAbort_q | TxRetry_q)
    TxByteCnt <= 2'h0;
  else
  if(TxStartFrm & ~TxUsedData)
    case(TxPointerLSB)  // synopsys parallel_case
      2'h0 : TxByteCnt <= 2'h1;
      2'h1 : TxByteCnt <= 2'h2;
      2'h2 : TxByteCnt <= 2'h3;
      2'h3 : TxByteCnt <= 2'h0;
    endcase
  else
  if(TxUsedData & Flop)
    TxByteCnt <= TxByteCnt + 1'b1;
end


always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_tck <= 1'b0;
  else
  if(TxStartFrm_sync2 & ~TxStartFrm | TxUsedData & Flop & TxByteCnt == 2'h3 &
     ~LastWord | TxStartFrm & TxUsedData & Flop & TxByteCnt == 2'h0)
     ReadTxDataFromFifo_tck <= 1'b1;
  else
  if(ReadTxDataFromFifo_syncb2 & ~ReadTxDataFromFifo_syncb3)
    ReadTxDataFromFifo_tck <= 1'b0;
end

// Synchronizing TxStartFrm_wb to MTxClk
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_sync1 <= 1'b0;
  else
    ReadTxDataFromFifo_sync1 <= ReadTxDataFromFifo_tck;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_sync2 <= 1'b0;
  else
    ReadTxDataFromFifo_sync2 <= ReadTxDataFromFifo_sync1;
end

always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_syncb1 <= 1'b0;
  else
    ReadTxDataFromFifo_syncb1 <= ReadTxDataFromFifo_sync2;
end

always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_syncb2 <= 1'b0;
  else
    ReadTxDataFromFifo_syncb2 <= ReadTxDataFromFifo_syncb1;
end

always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_syncb3 <= 1'b0;
  else
    ReadTxDataFromFifo_syncb3 <= ReadTxDataFromFifo_syncb2;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ReadTxDataFromFifo_sync3 <= 1'b0;
  else
    ReadTxDataFromFifo_sync3 <= ReadTxDataFromFifo_sync2;
end

assign ReadTxDataFromFifo_wb = ReadTxDataFromFifo_sync2 &
                               ~ReadTxDataFromFifo_sync3;
// End: Generation of the ReadTxDataFromFifo_tck signal and synchronization
// to the WB_CLK_I


// Synchronizing TxRetry signal (synchronized to WISHBONE clock)
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetrySync1 <= 1'b0;
  else
    TxRetrySync1 <= TxRetry;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetry_wb <= 1'b0;
  else
    TxRetry_wb <= TxRetrySync1;
end


// Synchronized TxDone_wb signal (synchronized to WISHBONE clock)
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxDoneSync1 <= 1'b0;
  else
    TxDoneSync1 <= TxDone;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxDone_wb <= 1'b0;
  else
    TxDone_wb <= TxDoneSync1;
end

// Synchronizing TxAbort signal (synchronized to WISHBONE clock)
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbortSync1 <= 1'b0;
  else
    TxAbortSync1 <= TxAbort;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbort_wb <= 1'b0;
  else
    TxAbort_wb <= TxAbortSync1;
end


assign StartRxBDRead = RxStatusWrite | RxAbortSync3 & ~RxAbortSync4 |
                       r_RxEn & ~r_RxEn_q;

// Reading the Rx buffer descriptor
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxBDRead <= 1'b0;
  else
  if(StartRxBDRead & ~RxReady)
    RxBDRead <= 1'b1;
  else
  if(RxBDReady)
    RxBDRead <= 1'b0;
end


// Reading of the next receive buffer descriptor starts after reception status
// is written to the previous one.

// Latching READY status of the Rx buffer descriptor
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxBDReady <= 1'b0;
  else
  if(RxPointerRead)
    RxBDReady <= 1'b0;
  else
  if(RxEn & RxEn_q & RxBDRead)
    RxBDReady <= ram_do[15];// RxBDReady is sampled only once at the beginning
end

// Latching Rx buffer descriptor status
// Data is avaliable one cycle after the access is started (at that time
// signal RxEn is not active)
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxStatus <= 2'h0;
  else
  if(RxEn & RxEn_q & RxBDRead)
    RxStatus <= {ram_do[14],1'b0};
end


// RxReady generation
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxReady <= 1'b0;
  else if(ShiftEnded | RxAbortSync2 & ~RxAbortSync3 | ~r_RxEn & r_RxEn_q)
    RxReady <= 1'b0;
  else if(RxEn & RxEn_q & RxPointerRead)
    RxReady <= 1'b1;
end


// Reading Rx BD pointer
assign StartRxPointerRead = RxBDRead & RxBDReady;

// Reading Tx BD Pointer
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxPointerRead <= 1'b0;
  else
  if(StartRxPointerRead)
    RxPointerRead <= 1'b1;
  else
  if(RxEn & RxEn_q)
    RxPointerRead <= 1'b0;
end


//Latching Rx buffer pointer from buffer descriptor;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxPointerMSB <= 30'h0;
  else
  if(RxEn & RxEn_q & RxPointerRead)
    RxPointerMSB <= ram_do[31:2];
  else
  if(MasterWbRX & m_ack_sig)
      RxPointerMSB <= RxPointerMSB + 1'b1; // Word access (always word access.
                                           // m_wb_stb_o are used for
                                           // selecting bytes)
end


//Latching last addresses from buffer descriptor (used as byte-half-word
//indicator);
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxPointerLSB_rst[1:0] <= 0;
  else
  if(MasterWbRX & m_ack_sig) // After first write all RxByteSel are active
    RxPointerLSB_rst[1:0] <= 0;
  else
  if(RxEn & RxEn_q & RxPointerRead)
    RxPointerLSB_rst[1:0] <= ram_do[1:0];
end


always @ (RxPointerLSB_rst)
begin
  case(RxPointerLSB_rst[1:0])  // synopsys parallel_case
    2'h0 : RxByteSel[3:0] = 4'hf;
    2'h1 : RxByteSel[3:0] = 4'h7;
    2'h2 : RxByteSel[3:0] = 4'h3;
    2'h3 : RxByteSel[3:0] = 4'h1;
  endcase
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxEn_needed <= 1'b0;
  else if(~RxReady & r_RxEn & WbEn & ~WbEn_q)
    RxEn_needed <= 1'b1;
  else if(RxPointerRead & RxEn & RxEn_q)
    RxEn_needed <= 1'b0;
end


// Reception status is written back to the buffer descriptor after the end
// of frame is detected.
assign RxStatusWrite = (ShiftEnded & RxEn & RxEn_q);


// Indicating that last byte is being reveived
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LastByteIn <= 1'b0;
  else
  if(ShiftWillEnd & (&RxByteCnt) | RxAbort)
    LastByteIn <= 1'b0;
  else
  if(RxValid & RxReady & RxEndFrm & ~(&RxByteCnt) & RxEnableWindow)
    LastByteIn <= 1'b1;
end
//
assign StartShiftWillEnd = LastByteIn  | (RxValid & RxEndFrm & (&RxByteCnt) &
									RxEnableWindow & Length_Vs_Payload_error == 1'b0 & (RxEndFrm & AddressMiss == 1'b0) & (RxEndFrm & MRxErr_Detected == 1'b0));
// Indicating that data reception will end
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftWillEnd <= 1'b0;
  else
  if(ShiftEnded_rck | RxAbort)
    ShiftWillEnd <= 1'b0;
  else
  if(StartShiftWillEnd)
    ShiftWillEnd <= 1'b1;
end


// Receive byte counter
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxByteCnt <= 2'h0;
  else
  if(ShiftEnded_rck | RxAbort)
    RxByteCnt <= 2'h0;
  else
  if(RxValid & RxStartFrm & RxReady)
    case(RxPointerLSB_rst)  // synopsys parallel_case
      2'h0 : RxByteCnt <= 2'h1;
      2'h1 : RxByteCnt <= 2'h2;
      2'h2 : RxByteCnt <= 2'h3;
      2'h3 : RxByteCnt <= 2'h0;
    endcase
  else
  if(RxValid & RxEnableWindow & RxReady | LastByteIn)
    RxByteCnt <= RxByteCnt + 1'b1;
end


// Indicates how many bytes are valid within the last word
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxValidBytes <= 2'h1;
  else
  if(RxValid & RxStartFrm)
    case(RxPointerLSB_rst)  // synopsys parallel_case
      2'h0 : RxValidBytes <= 2'h1;
      2'h1 : RxValidBytes <= 2'h2;
      2'h2 : RxValidBytes <= 2'h3;
      2'h3 : RxValidBytes <= 2'h0;
    endcase
  else
  if(RxValid & ~LastByteIn & ~RxStartFrm & RxEnableWindow)
    RxValidBytes <= RxValidBytes + 1'b1;
end


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxDataLatched1       <= 24'h0;
  else
  if(RxValid & RxReady & ~LastByteIn)
    if(RxStartFrm)
    begin
      case(RxPointerLSB_rst)     // synopsys parallel_case
        // Big Endian Byte Ordering
        2'h0:        RxDataLatched1[31:24] <= RxData;
        2'h1:        RxDataLatched1[23:16] <= RxData;
        2'h2:        RxDataLatched1[15:8]  <= RxData;
        2'h3:        RxDataLatched1        <= RxDataLatched1;
      endcase
    end
    else if (RxEnableWindow)
    begin
      case(RxByteCnt)     // synopsys parallel_case
        // Big Endian Byte Ordering
        2'h0:        RxDataLatched1[31:24] <= RxData;
        2'h1:        RxDataLatched1[23:16] <= RxData;
        2'h2:        RxDataLatched1[15:8]  <= RxData;
        2'h3:        RxDataLatched1        <= RxDataLatched1;
      endcase
    end
end

//Added below on May/4/2020
//Note : 1.Adding below logic to avoid the loss of writing data into rx_fifo
//       2.when loss data happens:
//			a.RTL is writing data into Fifo when there are 4 Bytes available at input pin(data_in)
//		    b.To solve this issue,
//				i.Apending 0's to the data_in .
//              ii.number of 0's are dependent on how many bits are left to make 32 bits of data_in(input of rx_fifo)
//		        iii.Generating one extra pulse of write signal(write of rx_fifo) 
//						-Generate a signal with one clock pulse width ,when  the RxEndFrm  is detected
//						-

/*always@(posedge MRxClk or negedge Resetn)
begin 
  if(Resetn == 0)
       stretch_rxfifo_wr_append_0sto_datain <= 0;
  else
  begin
  	      case(stretch_rxfifo_wr_append_0sto_datain)
		  0:begin
		        if(RxEndFrm & (Length_Vs_Payload_error | AddressMiss | MRxErr_Detected))
				begin
					 case(RxByteCnt)
					 0:stretch_rxfifo_wr_append_0sto_datain <= 3;
					 1:stretch_rxfifo_wr_append_0sto_datain <= 2;
					 2:stretch_rxfifo_wr_append_0sto_datain <= 1;
					 3:stretch_rxfifo_wr_append_0sto_datain <= 0;
					 endcase
				end
				else 
				begin
					if(RxAbort) 
						stretch_rxfifo_wr_append_0sto_datain <= 0;
				end
			end
		  1,
		  2,
		  3: stretch_rxfifo_wr_append_0sto_datain <= 0;
	      endcase
  end
end
*/

// Assembling data that will be written to the rx_fifo
/*always @ (posedge MRxClk or negedge Resetn)
begin 
  if(Resetn == 0)
    RxDataLatched2 <= 32'h0;
  else
  begin
       if(stretch_rxfifo_wr_append_0sto_datain !=0)
       begin
	        case(stretch_rxfifo_wr_append_0sto_datain)
			3: RxDataLatched2 <= {RxData,24'd0};
			2: RxDataLatched2 <= {RxDataLatched1[31:24],RxData,16'd0}; 
            1: RxDataLatched2 <= {RxDataLatched1[31:16],RxData,8'd0}; 	
			0: RxDataLatched2 <= RxDataLatched2;	
			endcase
       end 	   
	   else
	   begin
		  if(SetWriteRxDataToFifo & ~ShiftWillEnd)
			// Big Endian Byte Ordering
			RxDataLatched2 <= {RxDataLatched1[31:8], RxData};
		  else
		  begin
			  if(SetWriteRxDataToFifo & ShiftWillEnd)
				case(RxValidBytes)  // synopsys parallel_case
				  // Big Endian Byte Ordering
				  0 : RxDataLatched2 <= {RxDataLatched1[31:8],  RxData};
				  1 : RxDataLatched2 <= {RxDataLatched1[31:24], 24'h0};
				  2 : RxDataLatched2 <= {RxDataLatched1[31:16], 16'h0};
				  3 : RxDataLatched2 <= {RxDataLatched1[31:8],   8'h0};
				endcase
		  end 
		end
   end
end
*/

always @ (posedge MRxClk or negedge Resetn)
begin 
  if(Resetn == 0)
    RxDataLatched2 <= 32'h0;
  else
  if(SetWriteRxDataToFifo & ~ShiftWillEnd)
    // Big Endian Byte Ordering
    RxDataLatched2 <= {RxDataLatched1[31:8], RxData};
  else
  if(SetWriteRxDataToFifo & ShiftWillEnd)
    case(RxValidBytes)  // synopsys parallel_case
      // Big Endian Byte Ordering
      0 : RxDataLatched2 <= {RxDataLatched1[31:8],  RxData};
      1 : RxDataLatched2 <= {RxDataLatched1[31:24], 24'h0};
      2 : RxDataLatched2 <= {RxDataLatched1[31:16], 16'h0};
      3 : RxDataLatched2 <= {RxDataLatched1[31:8],   8'h0};
    endcase
end


/*always@(*)
begin
	begin
		SetWriteRxDataToFifo = (RxValid & RxReady & ~RxStartFrm & RxEnableWindow & (&RxByteCnt))
                              |(RxValid & RxReady &  RxStartFrm &(&RxPointerLSB_rst))
                              |(ShiftWillEnd & LastByteIn & (&RxByteCnt))
							  |(stretch_rxfifo_wr_append_0sto_datain>0);
	end
end								

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    WriteRxDataToFifo <= 1'b0;
  else
  begin
  	  if(SetWriteRxDataToFifo & ~RxAbort)
			WriteRxDataToFifo <= 1'b1;	
	  else
	  begin
	      if(WriteRxDataToFifoSync2) 
				WriteRxDataToFifo <= 1'b0;
		  else
		  begin
			  if(stretch_rxfifo_wr_append_0sto_datain>0) 
					WriteRxDataToFifo <= 1'b1;	 
			  else
			  begin
				  if(RxAbort)
					WriteRxDataToFifo <= 1'b0;
			  end
		  end
	  end
  end 
end
*/
always@(*)
begin
	begin
		SetWriteRxDataToFifo = (RxValid & RxReady & ~RxStartFrm & RxEnableWindow & (&RxByteCnt))
                              |(RxValid & RxReady &  RxStartFrm &(&RxPointerLSB_rst))
                              |(ShiftWillEnd & LastByteIn & (&RxByteCnt));
							  //|(stretch_rxfifo_wr_append_0sto_datain>0);
	end
end	

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    WriteRxDataToFifo <= 1'b0;
  else
  if(SetWriteRxDataToFifo & ~RxAbort)
    WriteRxDataToFifo <= 1'b1;
  else
  if(WriteRxDataToFifoSync2 | RxAbort)
    WriteRxDataToFifo <= 1'b0;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    WriteRxDataToFifoSync1 <= 1'b0;
  else
  if(WriteRxDataToFifo)
    WriteRxDataToFifoSync1 <= 1'b1;
  else
    WriteRxDataToFifoSync1 <= 1'b0;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    WriteRxDataToFifoSync2 <= 1'b0;
  else
    WriteRxDataToFifoSync2 <= WriteRxDataToFifoSync1;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    WriteRxDataToFifoSync3 <= 1'b0;
  else
    WriteRxDataToFifoSync3 <= WriteRxDataToFifoSync2;
end


assign WriteRxDataToFifo_wb = WriteRxDataToFifoSync2 &
                              ~WriteRxDataToFifoSync3;


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LatchedRxStartFrm <= 0;
  else
  if(RxStartFrm & ~SyncRxStartFrm_q)
    LatchedRxStartFrm <= 1;
  else
  if(SyncRxStartFrm_q)
    LatchedRxStartFrm <= 0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    SyncRxStartFrm <= 0;
  else
  if(LatchedRxStartFrm)
    SyncRxStartFrm <= 1;
  else
    SyncRxStartFrm <= 0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    SyncRxStartFrm_q <= 0;
  else
    SyncRxStartFrm_q <= SyncRxStartFrm;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    SyncRxStartFrm_q2 <= 0;
  else
    SyncRxStartFrm_q2 <= SyncRxStartFrm_q;
end


assign RxFifoReset = SyncRxStartFrm_q & ~SyncRxStartFrm_q2;

eth_fifo #(
           .DATA_WIDTH(RX_FIFO_DATA_WIDTH),
           .DEPTH(RX_FIFO_DEPTH),
           .CNT_WIDTH(RX_FIFO_CNT_WIDTH))
rx_fifo (
         .clk            (WB_CLK_I),
         .resetn          (Resetn),
         // Inputs
         .data_in        (RxDataLatched2),
         .write          (WriteRxDataToFifo_wb & ~RxBufferFull),
         .read           (MasterWbRX & m_ack_sig),
         .clear          (RxFifoReset),
         // Outputs
         .data_out       (m_wb_dat_o), 
         .full           (RxBufferFull),
         .almost_full    (),
         .almost_empty   (RxBufferAlmostEmpty), 
         .empty          (RxBufferEmpty),
         .cnt            (rxfifo_cnt)
        );

assign enough_data_in_rxfifo_for_burst = rxfifo_cnt>=`ETH_BURST_LENGTH;
assign enough_data_in_rxfifo_for_burst_plus1 = rxfifo_cnt>`ETH_BURST_LENGTH;
assign WriteRxDataToMemory = ~RxBufferEmpty;
assign rx_burst = rx_burst_en & WriteRxDataToMemory;


// Generation of the end-of-frame signal
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEnded_rck <= 1'b0;
  else
  if(~RxAbort & SetWriteRxDataToFifo & StartShiftWillEnd)
    ShiftEnded_rck <= 1'b1;
  else
  if(RxAbort | ShiftEndedSync_c1 & ShiftEndedSync_c2)
    ShiftEnded_rck <= 1'b0;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEndedSync1 <= 1'b0;
  else
    ShiftEndedSync1 <= ShiftEnded_rck;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEndedSync2 <= 1'b0;
  else
    ShiftEndedSync2 <= ShiftEndedSync1;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEndedSync3 <= 1'b0;
  else
  if(ShiftEndedSync1 & ~ShiftEndedSync2)
    ShiftEndedSync3 <= 1'b1;
  else
  if(ShiftEnded)
    ShiftEndedSync3 <= 1'b0;
end

// Generation of the end-of-frame signal
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEnded <= 1'b0;
  else
  if(ShiftEndedSync3 & MasterWbRX & m_ack_sig & RxBufferAlmostEmpty & ~ShiftEnded)
    ShiftEnded <= 1'b1;
  else
  if(RxStatusWrite)
    ShiftEnded <= 1'b0;
end

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEndedSync_c1 <= 1'b0;
  else
    ShiftEndedSync_c1 <= ShiftEndedSync2;
end

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ShiftEndedSync_c2 <= 1'b0;
  else
    ShiftEndedSync_c2 <= ShiftEndedSync_c1;
end

// Generation of the end-of-frame signal
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxEnableWindow <= 1'b0;
  else if(RxStartFrm)
    RxEnableWindow <= 1'b1;
  else if(RxEndFrm | RxAbort)
    RxEnableWindow <= 1'b0;
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSync1 <= 1'b0;
  else
    RxAbortSync1 <= RxAbortLatched;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSync2 <= 1'b0;
  else
    RxAbortSync2 <= RxAbortSync1;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSync3 <= 1'b0;
  else
    RxAbortSync3 <= RxAbortSync2;
end

always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSync4 <= 1'b0;
  else
    RxAbortSync4 <= RxAbortSync3;
end

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSyncb1 <= 1'b0;
  else
    RxAbortSyncb1 <= RxAbortSync2;
end

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortSyncb2 <= 1'b0;
  else
    RxAbortSyncb2 <= RxAbortSyncb1;
end


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxAbortLatched <= 1'b0;
  else
  if(RxAbortSyncb2)
    RxAbortLatched <= 1'b0;
  else
  if(RxAbort)
    RxAbortLatched <= 1'b1;
end
//Added the logic by Moschip team 27 june 2020
always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
		RxLength_d <= 0;
	else
		RxLength_d[15:0] <= RxLength[15:0];
end

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LatchedRxLength[15:0] <= 16'h0;
  else
  if(LoadRxStatus)
    LatchedRxLength[15:0] <= RxLength_d[15:0];
end

assign RxStatusIn = {1'b0,
                     AddressMiss,
                     1'b0,
                     1'b0,
                     1'b0,
                     ReceivedPacketTooBig,
                     1'b0,
                     LatchedCrcError,
                     1'b0};

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxStatusInLatched <= 'h0;
  else
  if(LoadRxStatus)
    RxStatusInLatched <= RxStatusIn;
end


// Rx overrun
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxOverrun <= 1'b0;
  else if(RxStatusWrite)
    RxOverrun <= 1'b0;
  else if(RxBufferFull & WriteRxDataToFifo_wb)
    RxOverrun <= 1'b1;
end

//added by Moschip Team on june 5th
assign TxError =  RetryLimit | LateCollLatched | Tx_BAD_FRAME_f6;


// ShortFrame (RxStatusInLatched[2]) can not set an error because short frames
// are aborted when signal r_RecSmall is set to 0 in MODER register. 
// AddressMiss is identifying that a frame was received because of the
// promiscous mode and is not an error
assign RxError = (|RxStatusInLatched[6:3])|(|RxStatusInLatched[0])| RxStatusIn[7] | (RxEndFrm & Length_Vs_Payload_error) | (RxEndFrm & MRxErr_Detected) ;
// Latching and synchronizing RxStatusWrite signal. This signal is used for
// clearing the ReceivedPauseFrm signal
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxStatusWriteLatched <= 1'b0;
  else
  if(RxStatusWriteLatched_syncb2)
    RxStatusWriteLatched <= 1'b0;        
  else
  if(RxStatusWrite)
    RxStatusWriteLatched <= 1'b1;
end


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxStatusWriteLatched_sync1 <= 1'b0;
      RxStatusWriteLatched_sync2 <= 1'b0;
    end
  else
    begin
      RxStatusWriteLatched_sync1 <= RxStatusWriteLatched;
      RxStatusWriteLatched_sync2 <= RxStatusWriteLatched_sync1;
    end
end


always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxStatusWriteLatched_syncb1 <= 1'b0;
      RxStatusWriteLatched_syncb2 <= 1'b0;
    end
  else
    begin
      RxStatusWriteLatched_syncb1 <= RxStatusWriteLatched_sync2;
      RxStatusWriteLatched_syncb2 <= RxStatusWriteLatched_syncb1;
    end
end


// Tx Done Interrupt
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxB_IRQ <= 1'b0;
  else
  if(TxStatusWrite & TxIRQEn)
	TxB_IRQ <= ~TxError;
  else
    TxB_IRQ <= 1'b0;
end

// Tx Error Interrupt
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    TxE_IRQ <= 1'b0;
  else
  if(TxStatusWrite & TxIRQEn)
    TxE_IRQ <= TxError;
  else
    TxE_IRQ <= 1'b0;
end

// Rx Done Interrupt
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxB_IRQ <= 1'b0;
  else
  if(RxStatusWrite & RxIRQEn & ReceivedPacketGood &
     (~ReceivedPauseFrm | ReceivedPauseFrm & r_PassAll & (~r_RxFlow)))
    RxB_IRQ <= (~RxError);
  else
    RxB_IRQ <= 1'b0;
end


//Added by Moschip team on july 4 2020
reg  rxe_low;
reg [6:0] count;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0) 
  begin
	  rxe_low <= 1'b1;  
  end
  else 
  if(RxE_IRQ)
	  rxe_low <= 1'b0;
  else if(count == 'd40)
  begin 
		rxe_low <= 1'b1;
  end
end
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0) count <= 'd0;
  else if(rxe_low == 1'b0) 
		begin
			count <= count + 1'b1;
				if(count == 'd40)
				count <= 1'b0;
		end
   else 
		count <= count;
end
  
  
  //added by moschip team(rajesh)
reg rxbadcount_en;
reg [6:0] rxbadcount;
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0) begin
  rxbadcount_en <= 0;
  end
  //else if(RxE_IRQ == 1'b1) begin
  else if(((RxEndFrm & AddressMiss & rxe_low) | (RxEndFrm & Length_Vs_Payload_error & rxe_low) | (RxEndFrm & MRxErr_Detected & rxe_low)) & RxIRQEn & (~ReceivedPauseFrm | ReceivedPauseFrm
     & r_PassAll & (~r_RxFlow))) begin
  //else if (RxEndFrm == 1'b1) begin
  rxbadcount_en <= 1'b1;
  end
  else if(rxbadcount == 'd100-1'b1) begin
  rxbadcount_en <= 1'b0;
  end
  else begin
  rxbadcount_en <= rxbadcount_en;
  end
  end
  
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0) begin
  rxbadcount <= 0;
  end
  else if(rxbadcount_en == 1'b1) begin
  rxbadcount <= rxbadcount + 1'b1;
  end
  else begin
  rxbadcount <= 0;
  end
  end
  reg rxbadstatuswrite;
  
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0) begin 	
  rxbadstatuswrite <= 1'b0;
  end
  else if(rxbadcount == 'd95) begin
  //if(RxBDDataIn[1]==1'b1 | RxBDDataIn[3]==1'b1 | RxBDDataIn[7]==1'b1)
  rxbadstatuswrite <= 1'b1;
  end
  else begin
  rxbadstatuswrite <= 1'b0;
  end
  end
  always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxE_IRQ <= 1'b0;
  else
    if(rxbadstatuswrite == 1'b1)
    RxE_IRQ <= 1'b1;
  else
    RxE_IRQ <= 1'b0;
end

  
/*	
// Rx Error Interrupt
always @ (posedge WB_CLK_I or negedge Resetn)
begin
  if(Resetn == 0)
    RxE_IRQ <= 1'b0;
  else
    if((RxStatusWrite | (RxEndFrm & AddressMiss & rxe_low) | (RxEndFrm & Length_Vs_Payload_error & rxe_low) | (RxEndFrm & MRxErr_Detected & rxe_low)) & RxIRQEn & (~ReceivedPauseFrm | ReceivedPauseFrm
     & r_PassAll & (~r_RxFlow)))
    RxE_IRQ <= RxError;
  else
    RxE_IRQ <= 1'b0;
end
*/

// Busy Interrupt

reg Busy_IRQ_rck;
reg Busy_IRQ_sync1;
reg Busy_IRQ_sync2;
reg Busy_IRQ_sync3;
reg Busy_IRQ_syncb1;
reg Busy_IRQ_syncb2;


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    Busy_IRQ_rck <= 1'b0;
  else
  if(RxValid & RxStartFrm & ~RxReady)
    Busy_IRQ_rck <= 1'b1;
  else
  if(Busy_IRQ_syncb2)
    Busy_IRQ_rck <= 1'b0;
end

always @ (posedge WB_CLK_I)
begin
    Busy_IRQ_sync1 <= Busy_IRQ_rck;
    Busy_IRQ_sync2 <= Busy_IRQ_sync1;
    Busy_IRQ_sync3 <= Busy_IRQ_sync2;
end

always @ (posedge MRxClk)
begin
    Busy_IRQ_syncb1 <= Busy_IRQ_sync2;
    Busy_IRQ_syncb2 <= Busy_IRQ_syncb1;
end

assign Busy_IRQ = Busy_IRQ_sync2 & ~Busy_IRQ_sync3;


// Assign the debug output
`ifdef WISHBONE_DEBUG
// Top byte, burst progress counters
assign dbg_dat0[31] = 0;
assign dbg_dat0[30:28] = rx_burst_cnt;
assign dbg_dat0[27] = 0;
assign dbg_dat0[26:24] = tx_burst_cnt;
// Third byte
assign dbg_dat0[23] = 0; //rx_ethside_fifo_sel;
assign dbg_dat0[22] = 0; //rx_wbside_fifo_sel;
assign dbg_dat0[21] = 0; //rx_fifo0_empty;
assign dbg_dat0[20] = 0; //rx_fifo1_empty;
assign dbg_dat0[19] = 0; //overflow_bug_reset;
assign dbg_dat0[18] = 0; //RxBDOK;
assign dbg_dat0[17] = 0; //write_rx_data_to_memory_go;
assign dbg_dat0[16] = 0; //rx_wb_last_writes;
// Second byte - TxBDAddress - or TX BD address pointer
assign dbg_dat0[15:8] = { BlockingTxBDRead , TxBDAddress};
// Bottom byte - FSM controlling vector
assign dbg_dat0[7:0] = {MasterWbTX,
                       MasterWbRX,
                       ReadTxDataFromMemory_2,
                       WriteRxDataToMemory,
                       MasterAccessFinished,
                       cyc_cleared,
                       tx_burst,
                       rx_burst};
`endif


endmodule


