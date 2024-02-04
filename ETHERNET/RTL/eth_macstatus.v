//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:26:11 06/07/2020 
// Design Name: 
// Module Name:    eth_macstatus 
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

`include "timescale.v"
module eth_macstatus(
                      MRxClk, Resetn, ReceivedLengthOK, ReceiveEnd, ReceivedPacketGood, RxCrcError, 
                      MRxErr, MRxDV, RxStateSFD, RxStateData, RxStatePreamble, RxStateIdle,RxStateDA,RxStateSA,RxStateLength, Transmitting, 
                      RxByteCnt, RxByteCntEq0, RxByteCntGreat2, RxByteCntMaxFrame, 
                      InvalidSymbol, MRxD, LatchedCrcError, Collision, CollValid, RxLateCollision,
                      r_RecSmall, r_MinFL, r_MaxFL, ShortFrame, DribbleNibble, ReceivedPacketTooBig, r_HugEn,
                      LoadRxStatus, StartTxDone, StartTxAbort, RetryCnt, RetryCntLatched, MTxClk, MaxCollisionOccured, 
                      RetryLimit, LateCollision, LateCollLatched, DeferIndication, DeferLatched, RstDeferLatched, TxStartFrm,
                      StatePreamble,StateSFD,StateDA,StateSA,StateLength, StateData, CarrierSense, CarrierSenseLost, TxUsedData, LatchedMRxErr, Loopback, 
                      r_FullD
                    );




input         MRxClk;
input         Resetn;
input         RxCrcError;
input         MRxErr;
input         MRxDV;

input         RxStateSFD;
input   [1:0] RxStateData;
input         RxStatePreamble;
input         RxStateIdle;
input 		  RxStateDA;
input 		  RxStateSA;
input 		  RxStateLength;
input         Transmitting;
input  [15:0] RxByteCnt;
input         RxByteCntEq0;
input         RxByteCntGreat2;
input         RxByteCntMaxFrame;
input   [3:0] MRxD;
input         Collision;
input   [5:0] CollValid;
input         r_RecSmall;
input  [15:0] r_MinFL;
input  [15:0] r_MaxFL;
input         r_HugEn;
input         StartTxDone;
input         StartTxAbort;
input   [3:0] RetryCnt;
input         MTxClk;
input         MaxCollisionOccured;
input         LateCollision;
input         DeferIndication;
input         TxStartFrm;
input         StatePreamble;
input 		  StateSFD;
input 		  StateDA;
input 		  StateSA;
input 		  StateLength;
input   [1:0] StateData;
input         CarrierSense;
input         TxUsedData;
input         Loopback;
input         r_FullD;


output        ReceivedLengthOK;
output        ReceiveEnd;
output        ReceivedPacketGood;
output        InvalidSymbol;
output        LatchedCrcError;
output        RxLateCollision;
output        ShortFrame;
output        DribbleNibble;
output        ReceivedPacketTooBig;
output        LoadRxStatus;
output  [3:0] RetryCntLatched;
output        RetryLimit;
output        LateCollLatched;
output        DeferLatched;
input         RstDeferLatched;
output        CarrierSenseLost;
output        LatchedMRxErr;


reg           ReceiveEnd;

reg           LatchedCrcError;
reg           LatchedMRxErr;
reg           LoadRxStatus;
reg           InvalidSymbol;
reg     [3:0] RetryCntLatched;
reg           RetryLimit;
reg           LateCollLatched;
reg           DeferLatched;
reg           CarrierSenseLost;

wire          TakeSample;
reg 		  TakeSample_d;
wire          SetInvalidSymbol; // Invalid symbol was received during reception in 100Mbps 

// Crc error
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LatchedCrcError <= 1'b0;
  else
  if(RxStateSFD)
    LatchedCrcError <= 1'b0;
  else
  if(RxStateData[1] | TakeSample_d)			
    LatchedCrcError <= RxCrcError & ~RxByteCntEq0;
end


// LatchedMRxErr
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn)
    LatchedMRxErr <= 1'b0;
  else
  if(MRxErr & MRxDV & (RxStatePreamble | RxStateSFD |RxStateDA | RxStateSA | RxStateLength |(|RxStateData) | RxStateIdle & ~Transmitting))
    LatchedMRxErr <= 1'b1;
  else
    LatchedMRxErr <= 1'b0;
end


// ReceivedPacketGood
assign ReceivedPacketGood = ~LatchedCrcError;


// ReceivedLengthOK
assign ReceivedLengthOK = RxByteCnt[15:0] >= r_MinFL[15:0] & RxByteCnt[15:0] <= r_MaxFL[15:0];





// Time to take a sample
assign TakeSample = (|RxStateData)   & (~MRxDV)                    |
                      RxStateData[1] &   MRxDV & RxByteCntMaxFrame;		

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
	TakeSample_d <= 0;
  else
    TakeSample_d <= TakeSample;
end

// LoadRxStatus
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LoadRxStatus <= 1'b0;
  else
    LoadRxStatus <= TakeSample_d;
end



// ReceiveEnd
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReceiveEnd  <= 1'b0;
  else
    ReceiveEnd  <= LoadRxStatus;                     
end


// Invalid Symbol received during 100Mbps mode
assign SetInvalidSymbol = MRxDV & MRxErr & MRxD[3:0] == 4'he;


// InvalidSymbol
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    InvalidSymbol <= 1'b0;
  else
  if(LoadRxStatus & ~SetInvalidSymbol)
    InvalidSymbol <= 1'b0;
  else
  if(SetInvalidSymbol)
    InvalidSymbol <= 1'b1;
end


// Late Collision

reg RxLateCollision;
reg RxColWindow;
// Collision Window
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxLateCollision <= 1'b0;
  else
  if(LoadRxStatus)
    RxLateCollision <= 1'b0;
  else
  if(Collision & (~r_FullD) & (~RxColWindow | r_RecSmall))
    RxLateCollision <= 1'b1;
end

// Collision Window
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RxColWindow <= 1'b1;
  else
  if(~Collision & RxByteCnt[5:0] == CollValid[5:0] & RxStateData[1])
    RxColWindow <= 1'b0;
  else
  if(RxStateIdle)
    RxColWindow <= 1'b1;
end


// ShortFrame
reg ShortFrame;
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ShortFrame <= 1'b0;
  else
  if(LoadRxStatus)
    ShortFrame <= 1'b0;
  else
  if(TakeSample)
    ShortFrame <= RxByteCnt[15:0] < r_MinFL[15:0];		
end


// DribbleNibble
reg DribbleNibble;
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    DribbleNibble <= 1'b0;
  else
  if(RxStateSFD)
    DribbleNibble <= 1'b0;
  else
  if(~MRxDV & RxStateData[0])
    DribbleNibble <= 1'b1;
end


reg ReceivedPacketTooBig;
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ReceivedPacketTooBig <= 1'b0;
  else
  if(LoadRxStatus)
    ReceivedPacketTooBig <= 1'b0;
  else
  if(TakeSample_d)
   	 ReceivedPacketTooBig <= ~r_HugEn && ((RxByteCnt[15:0]+'d14) > r_MaxFL[15:0] ); 
end



// Latched Retry counter for tx status
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RetryCntLatched <= 4'h0;
  else
  if(StartTxDone | StartTxAbort)
    RetryCntLatched <= RetryCnt;
end


// Latched Retransmission limit
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RetryLimit <= 1'h0;
  else
  if(StartTxDone | StartTxAbort)
    RetryLimit <= MaxCollisionOccured;
end


// Latched Late Collision
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    LateCollLatched <= 1'b0;
  else
  if(StartTxDone | StartTxAbort)
    LateCollLatched <= LateCollision;
end



// Latched Defer state
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    DeferLatched <= 1'b0;
  else
  if(DeferIndication)
    DeferLatched <= 1'b1;
  else
  if(RstDeferLatched)
    DeferLatched <= 1'b0;
end


// CarrierSenseLost
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    CarrierSenseLost <= 1'b0;
  else
  if((StatePreamble | StateSFD | StateDA | StateSA | StateLength | (|StateData)) & ~CarrierSense & ~Loopback & ~Collision & ~r_FullD)	
    CarrierSenseLost <= 1'b1;
  else
  if(TxStartFrm)
    CarrierSenseLost <= 1'b0;
end


endmodule

