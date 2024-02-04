//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:27:42 06/07/2020 
// Design Name: 
// Module Name:    eth_receivecontrol 
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
module eth_receivecontrol (MTxClk, MRxClk, TxResetn, RxResetn, RxData, RxValid, RxStartFrm, 
                           RxEndFrm, RxFlow, ReceiveEnd, MAC, DlyCrcEn, TxDoneIn, 
                           TxAbortIn, TxStartFrmOut, ReceivedLengthOK, ReceivedPacketGood, 
                           TxUsedDataOutDetected, Pause, ReceivedPauseFrm, AddressOK, 
                           RxStatusWriteLatched_sync2, r_PassAll, SetPauseTimer
                          );


input       MTxClk;
input       MRxClk;
input       TxResetn; 
input       RxResetn; 
input [7:0] RxData;
input       RxValid;
input       RxStartFrm;
input       RxEndFrm;
input       RxFlow;
input       ReceiveEnd;
input [47:0]MAC;
input       DlyCrcEn;
input       TxDoneIn;
input       TxAbortIn;
input       TxStartFrmOut;
input       ReceivedLengthOK;
input       ReceivedPacketGood;
input       TxUsedDataOutDetected;
input       RxStatusWriteLatched_sync2;
input       r_PassAll;

output      Pause;
output      ReceivedPauseFrm;
output      AddressOK;
output      SetPauseTimer;


reg         Pause;
reg         AddressOK;                // Multicast or unicast address detected
reg         TypeLengthOK;             // Type/Length field contains 0x8808
reg         DetectionWindow;          // Detection of the PAUSE frame is possible within this window
reg         OpCodeOK;                 // PAUSE opcode detected (0x0001)
reg  [2:0]  DlyCrcCnt;
reg  [4:0]  ByteCnt;
reg [15:0]  AssembledTimerValue;
reg [15:0]  LatchedTimerValue;
reg         ReceivedPauseFrm;
reg         ReceivedPauseFrmWAddr;
reg         PauseTimerEq0_sync1;
reg         PauseTimerEq0_sync2;
reg [15:0]  PauseTimer;
reg         Divider2;
reg  [5:0]  SlotTimer;

wire [47:0] ReservedMulticast;        // 0x0180C2000001
wire [15:0] TypeLength;               // 0x8808
wire        ResetByteCnt;             // 
wire        IncrementByteCnt;         // 
wire        ByteCntEq0;               // ByteCnt = 0
wire        ByteCntEq1;               // ByteCnt = 1
wire        ByteCntEq2;               // ByteCnt = 2
wire        ByteCntEq3;               // ByteCnt = 3
wire        ByteCntEq4;               // ByteCnt = 4
wire        ByteCntEq5;               // ByteCnt = 5
wire        ByteCntEq12;              // ByteCnt = 12
wire        ByteCntEq13;              // ByteCnt = 13
wire        ByteCntEq14;              // ByteCnt = 14
wire        ByteCntEq15;              // ByteCnt = 15
wire        ByteCntEq16;              // ByteCnt = 16
wire        ByteCntEq17;              // ByteCnt = 17
wire        ByteCntEq18;              // ByteCnt = 18
wire        DecrementPauseTimer;      // 
wire        PauseTimerEq0;            // 
wire        ResetSlotTimer;           // 
wire        IncrementSlotTimer;       // 
wire        SlotFinished;             // 



// Reserved multicast address and Type/Length for PAUSE control
assign ReservedMulticast = 48'h0180C2000001;
assign TypeLength = 16'h8808;


// Address Detection (Multicast or unicast)
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    AddressOK <=  1'b0;
  else
  if(DetectionWindow & ByteCntEq0)  
    AddressOK <=   RxData[7:0] == ReservedMulticast[47:40] | RxData[7:0] == MAC[47:40];
  else
  if(DetectionWindow & ByteCntEq1)
    AddressOK <=  (RxData[7:0] == ReservedMulticast[39:32] | RxData[7:0] == MAC[39:32]) & AddressOK;
  else
  if(DetectionWindow & ByteCntEq2)
    AddressOK <=  (RxData[7:0] == ReservedMulticast[31:24] | RxData[7:0] == MAC[31:24]) & AddressOK;
  else
  if(DetectionWindow & ByteCntEq3)
    AddressOK <=  (RxData[7:0] == ReservedMulticast[23:16] | RxData[7:0] == MAC[23:16]) & AddressOK;
  else
  if(DetectionWindow & ByteCntEq4)
    AddressOK <=  (RxData[7:0] == ReservedMulticast[15:8]  | RxData[7:0] == MAC[15:8])  & AddressOK;
  else
  if(DetectionWindow & ByteCntEq5)
    AddressOK <=  (RxData[7:0] == ReservedMulticast[7:0]   | RxData[7:0] == MAC[7:0])   & AddressOK;
  else
  if(ReceiveEnd)
    AddressOK <=  1'b0;
end



// TypeLengthOK (Type/Length Control frame detected)
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    TypeLengthOK <=  1'b0;
  else
  if(DetectionWindow & ByteCntEq12) 
    TypeLengthOK <=  ByteCntEq12 & (RxData[7:0] == TypeLength[15:8]);
  else
  if(DetectionWindow & ByteCntEq13)
    TypeLengthOK <=  ByteCntEq13 & (RxData[7:0] == TypeLength[7:0]) & TypeLengthOK;
  else
  if(ReceiveEnd)
    TypeLengthOK <=  1'b0;
end



// Latch Control Frame Opcode
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    OpCodeOK <=  1'b0;
  else
  if(ByteCntEq16)
    OpCodeOK <=  1'b0;
  else
    begin
      if(DetectionWindow & ByteCntEq14)  
        OpCodeOK <=  ByteCntEq14 & RxData[7:0] == 8'h00;
    
      if(DetectionWindow & ByteCntEq15)
        OpCodeOK <=  ByteCntEq15 & RxData[7:0] == 8'h01 & OpCodeOK;
    end
end


// ReceivedPauseFrmWAddr (+Address Check)
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    ReceivedPauseFrmWAddr <=  1'b0;
  else
  if(ReceiveEnd)
    ReceivedPauseFrmWAddr <=  1'b0;
  else
  if(ByteCntEq16 & TypeLengthOK & OpCodeOK & AddressOK)
    ReceivedPauseFrmWAddr <=  1'b1;        
end



// Assembling 16-bit timer value from two 8-bit data
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    AssembledTimerValue[15:0] <=  16'h0;
  else
  if(RxStartFrm)
    AssembledTimerValue[15:0] <=  16'h0;
  else
    begin
      if(DetectionWindow & ByteCntEq16) 
        AssembledTimerValue[15:8] <=  RxData[7:0];
      if(DetectionWindow & ByteCntEq17)
        AssembledTimerValue[7:0] <=  RxData[7:0];
    end
end


// Detection window (while PAUSE detection is possible)
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    DetectionWindow <=  1'b1;
  else
  if(ByteCntEq18)
    DetectionWindow <=  1'b0;
  else
  if(ReceiveEnd)
    DetectionWindow <=  1'b1;
end



// Latching Timer Value
always @ (posedge MRxClk or negedge RxResetn )
begin
  if(RxResetn == 0)
    LatchedTimerValue[15:0] <=  16'h0;
  else
  if(DetectionWindow &  ReceivedPauseFrmWAddr &  ByteCntEq18)
    LatchedTimerValue[15:0] <=  AssembledTimerValue[15:0];
  else
  if(ReceiveEnd)
    LatchedTimerValue[15:0] <=  16'h0;
end



// Delayed CEC counter
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    DlyCrcCnt <=  3'h0;
  else
  if(RxValid & RxEndFrm)
    DlyCrcCnt <=  3'h0;
  else
  if(RxValid & ~RxEndFrm & ~DlyCrcCnt[2])
    DlyCrcCnt <=  DlyCrcCnt + 3'd1;
end

             
assign ResetByteCnt = RxEndFrm;
assign IncrementByteCnt = RxValid & DetectionWindow & ~ByteCntEq18 & 
			  (~DlyCrcEn | DlyCrcEn & DlyCrcCnt[2]);


// Byte counter
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    ByteCnt[4:0] <=  5'h0;
  else
  if(ResetByteCnt)
    ByteCnt[4:0] <=  5'h0;
  else
  if(IncrementByteCnt)
    ByteCnt[4:0] <=  ByteCnt[4:0] + 5'd1;
end


assign ByteCntEq0 = RxValid & ByteCnt[4:0] == 5'h0;
assign ByteCntEq1 = RxValid & ByteCnt[4:0] == 5'h1;
assign ByteCntEq2 = RxValid & ByteCnt[4:0] == 5'h2;
assign ByteCntEq3 = RxValid & ByteCnt[4:0] == 5'h3;
assign ByteCntEq4 = RxValid & ByteCnt[4:0] == 5'h4;
assign ByteCntEq5 = RxValid & ByteCnt[4:0] == 5'h5;
assign ByteCntEq12 = RxValid & ByteCnt[4:0] == 5'h0C;
assign ByteCntEq13 = RxValid & ByteCnt[4:0] == 5'h0D;
assign ByteCntEq14 = RxValid & ByteCnt[4:0] == 5'h0E;
assign ByteCntEq15 = RxValid & ByteCnt[4:0] == 5'h0F;
assign ByteCntEq16 = RxValid & ByteCnt[4:0] == 5'h10;
assign ByteCntEq17 = RxValid & ByteCnt[4:0] == 5'h11;
assign ByteCntEq18 = RxValid & ByteCnt[4:0] == 5'h12 & DetectionWindow;


assign SetPauseTimer = ReceiveEnd & ReceivedPauseFrmWAddr & ReceivedPacketGood & ReceivedLengthOK & RxFlow;
assign DecrementPauseTimer = SlotFinished & |PauseTimer;


// PauseTimer[15:0]
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    PauseTimer[15:0] <=  16'h0;
  else
  if(SetPauseTimer)
    PauseTimer[15:0] <=  LatchedTimerValue[15:0];
  else
  if(DecrementPauseTimer)
    PauseTimer[15:0] <=  PauseTimer[15:0] - 16'd1;
end

assign PauseTimerEq0 = ~(|PauseTimer[15:0]);



// Synchronization of the pause timer
always @ (posedge MTxClk or negedge TxResetn)
begin
  if(TxResetn == 0)
    begin
      PauseTimerEq0_sync1 <=  1'b1;
      PauseTimerEq0_sync2 <=  1'b1;
    end
  else
    begin
      PauseTimerEq0_sync1 <=  PauseTimerEq0;
      PauseTimerEq0_sync2 <=  PauseTimerEq0_sync1;
    end
end


// Pause signal generation
always @ (posedge MTxClk or negedge TxResetn)
begin
  if(TxResetn == 0)
    Pause <=  1'b0;
  else
  if((TxDoneIn | TxAbortIn | ~TxUsedDataOutDetected) & ~TxStartFrmOut)
    Pause <=  RxFlow & ~PauseTimerEq0_sync2;
end


// Divider2 is used for incrementing the Slot timer every other clock
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    Divider2 <=  1'b0;
  else
  if(|PauseTimer[15:0] & RxFlow)
    Divider2 <=  ~Divider2;
  else
    Divider2 <=  1'b0;
end


assign ResetSlotTimer = (RxResetn == 0);
assign IncrementSlotTimer =  Pause & RxFlow & Divider2;


// SlotTimer
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    SlotTimer[5:0] <=  6'h0;
  else
  if(ResetSlotTimer)
    SlotTimer[5:0] <=  6'h0;
  else
  if(IncrementSlotTimer)
    SlotTimer[5:0] <=  SlotTimer[5:0] + 6'd1;
end


assign SlotFinished = &SlotTimer[5:0] & IncrementSlotTimer;  // Slot is 512 bits (64 bytes)



// Pause Frame received
always @ (posedge MRxClk or negedge RxResetn)
begin
  if(RxResetn == 0)
    ReceivedPauseFrm <= 1'b0;
  else
  if(RxStatusWriteLatched_sync2 & r_PassAll | ReceivedPauseFrm & (~r_PassAll))
    ReceivedPauseFrm <= 1'b0;
  else
  if(ByteCntEq16 & TypeLengthOK & OpCodeOK)
    ReceivedPauseFrm <= 1'b1;        
end

endmodule

