//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:26:41 06/07/2020 
// Design Name: 
// Module Name:    eth_miim 
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
module eth_miim
(
  Clk,
  Resetn,
  Divider,
  NoPre,
  CtrlData,
  Rgad,
  Fiad,
  WCtrlData,
  RStat,
  ScanStat,
  Mdi,
  Mdo,
  MdoEn,
  Mdc,
  Busy,
  Prsd,
  LinkFail,
  Nvalid,
  WCtrlDataStart,
  RStatStart,
  UpdateMIIRX_DATAReg
);



input         Clk;                // Host Clock
input         Resetn;              // General Resetn
input   [7:0] Divider;            // Divider for the host clock
input  [15:0] CtrlData;           // Control Data (to be written to the PHY reg.)
input   [4:0] Rgad;               // Register Address (within the PHY)
input   [4:0] Fiad;               // PHY Address
input         NoPre;              // No Preamble (no 32-bit preamble)
input         WCtrlData;          // Write Control Data operation
input         RStat;              // Read Status operation
input         ScanStat;           // Scan Status operation
input         Mdi;                // MII Management Data In

output        Mdc;                // MII Management Data Clock
output        Mdo;                // MII Management Data Output
output        MdoEn;              // MII Management Data Output Enable
output        Busy;               // Busy Signal
output        LinkFail;           // Link Integrity Signal
output        Nvalid;             // Invalid Status (qualifier for the valid scan result)

output [15:0] Prsd;               // Read Status Data (data read from the PHY)

output        WCtrlDataStart;     // This signals resets the WCTRLDATA bit in the MIIM Command register
output        RStatStart;         // This signal resets the RSTAT BIT in the MIIM Command register
output        UpdateMIIRX_DATAReg;// Updates MII RX_DATA register with read data


reg           Nvalid;
reg           EndBusy_d;          // Pre-end Busy signal
reg           EndBusy;            // End Busy signal (stops the operation in progress)

reg           WCtrlData_q1;       // Write Control Data operation delayed 1 Clk cycle
reg           WCtrlData_q2;       // Write Control Data operation delayed 2 Clk cycles
reg           WCtrlData_q3;       // Write Control Data operation delayed 3 Clk cycles
reg           WCtrlDataStart;     // Start Write Control Data Command (positive edge detected)
reg           WCtrlDataStart_q;
reg           WCtrlDataStart_q1;  // Start Write Control Data Command delayed 1 Mdc cycle
reg           WCtrlDataStart_q2;  // Start Write Control Data Command delayed 2 Mdc cycles

reg           RStat_q1;           // Read Status operation delayed 1 Clk cycle
reg           RStat_q2;           // Read Status operation delayed 2 Clk cycles
reg           RStat_q3;           // Read Status operation delayed 3 Clk cycles
reg           RStatStart;         // Start Read Status Command (positive edge detected)
reg           RStatStart_q1;      // Start Read Status Command delayed 1 Mdc cycle
reg           RStatStart_q2;      // Start Read Status Command delayed 2 Mdc cycles

reg           ScanStat_q1;        // Scan Status operation delayed 1 cycle
reg           ScanStat_q2;        // Scan Status operation delayed 2 cycles
reg           SyncStatMdcEn;      // Scan Status operation delayed at least cycles and synchronized to MdcEn

wire          WriteDataOp;        // Write Data Operation (positive edge detected)
wire          ReadStatusOp;       // Read Status Operation (positive edge detected)
wire          ScanStatusOp;       // Scan Status Operation (positive edge detected)
wire          StartOp;            // Start Operation (start of any of the preceding operations)
wire          EndOp;              // End of Operation

reg           InProgress;         // Operation in progress
reg           InProgress_q1;      // Operation in progress delayed 1 Mdc cycle
reg           InProgress_q2;      // Operation in progress delayed 2 Mdc cycles
reg           InProgress_q3;      // Operation in progress delayed 3 Mdc cycles

reg           WriteOp;            // Write Operation Latch (When asserted, write operation is in progress)
reg     [6:0] BitCounter;         // Bit Counter


wire    [3:0] ByteSelect;         // Byte Select defines which byte (preamble, data, operation, etc.) is loaded and shifted through the shift register.
wire          MdcEn;              // MII Management Data Clock Enable signal is asserted for one Clk period before Mdc rises.
wire          ShiftedBit;         // This bit is output of the shift register and is connected to the Mdo signal
wire          MdcEn_n;

wire          LatchByte1_d2;
wire          LatchByte0_d2;
reg           LatchByte1_d;
reg           LatchByte0_d;
reg     [1:0] LatchByte;          // Latch Byte selects which part of Read Status Data is updated from the shift register

reg           UpdateMIIRX_DATAReg;// Updates MII RX_DATA register with read data





// Generation of the EndBusy signal. It is used for ending the MII Management operation.
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      EndBusy_d <=  1'b0;
      EndBusy <=  1'b0;
    end
  else
    begin
      EndBusy_d <=  ~InProgress_q2 & InProgress_q3;
      EndBusy   <=  EndBusy_d;
    end
end


// Update MII RX_DATA register
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    UpdateMIIRX_DATAReg <=  0;
  else
  if(EndBusy & ~WCtrlDataStart_q)
    UpdateMIIRX_DATAReg <=  1;
  else
    UpdateMIIRX_DATAReg <=  0;    
end



// Generation of the delayed signals used for positive edge triggering.
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      WCtrlData_q1 <=  1'b0;
      WCtrlData_q2 <=  1'b0;
      WCtrlData_q3 <=  1'b0;
      
      RStat_q1 <=  1'b0;
      RStat_q2 <=  1'b0;
      RStat_q3 <=  1'b0;

      ScanStat_q1  <=  1'b0;
      ScanStat_q2  <=  1'b0;
      SyncStatMdcEn <=  1'b0;
    end
  else
    begin
      WCtrlData_q1 <=  WCtrlData;
      WCtrlData_q2 <=  WCtrlData_q1;
      WCtrlData_q3 <=  WCtrlData_q2;

      RStat_q1 <=  RStat;
      RStat_q2 <=  RStat_q1;
      RStat_q3 <=  RStat_q2;

      ScanStat_q1  <=  ScanStat;
      ScanStat_q2  <=  ScanStat_q1;
      if(MdcEn)
        SyncStatMdcEn  <=  ScanStat_q2;
    end
end


// Generation of the Start Commands (Write Control Data or Read Status)
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      WCtrlDataStart <=  1'b0;
      WCtrlDataStart_q <=  1'b0;
      RStatStart <=  1'b0;
    end
  else
    begin
      if(EndBusy)
        begin
          WCtrlDataStart <=  1'b0;
          RStatStart <=  1'b0;
        end
      else
        begin
          if(WCtrlData_q2 & ~WCtrlData_q3)
            WCtrlDataStart <=  1'b1;
          if(RStat_q2 & ~RStat_q3)
            RStatStart <=  1'b1;
          WCtrlDataStart_q <=  WCtrlDataStart;
        end
    end
end 


// Generation of the Nvalid signal (indicates when the status is invalid)
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    Nvalid <=  1'b0;
  else
    begin
      if(~InProgress_q2 & InProgress_q3)
        begin
          Nvalid <=  1'b0;
        end
      else
        begin
          if(ScanStat_q2  & ~SyncStatMdcEn)
            Nvalid <=  1'b1;
        end
    end
end 

// Signals used for the generation of the Operation signals (positive edge)
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      WCtrlDataStart_q1 <=  1'b0;
      WCtrlDataStart_q2 <=  1'b0;

      RStatStart_q1 <=  1'b0;
      RStatStart_q2 <=  1'b0;

      InProgress_q1 <=  1'b0;
      InProgress_q2 <=  1'b0;
      InProgress_q3 <=  1'b0;

  	  LatchByte0_d <=  1'b0;
  	  LatchByte1_d <=  1'b0;

  	  LatchByte <=  2'b00;
    end
  else
    begin
      if(MdcEn)
        begin
          WCtrlDataStart_q1 <=  WCtrlDataStart;
          WCtrlDataStart_q2 <=  WCtrlDataStart_q1;

          RStatStart_q1 <=  RStatStart;
          RStatStart_q2 <=  RStatStart_q1;

          LatchByte[0] <=  LatchByte0_d;
          LatchByte[1] <=  LatchByte1_d;

          LatchByte0_d <=  LatchByte0_d2;
          LatchByte1_d <=  LatchByte1_d2;

          InProgress_q1 <=  InProgress;
          InProgress_q2 <=  InProgress_q1;
          InProgress_q3 <=  InProgress_q2;
        end
    end
end 


// Generation of the Operation signals
assign WriteDataOp  = WCtrlDataStart_q1 & ~WCtrlDataStart_q2;    
assign ReadStatusOp = RStatStart_q1     & ~RStatStart_q2;
assign ScanStatusOp = SyncStatMdcEn     & ~InProgress & ~InProgress_q1 & ~InProgress_q2;
assign StartOp      = WriteDataOp | ReadStatusOp | ScanStatusOp;

// Busy
assign Busy = WCtrlData | WCtrlDataStart | RStat | RStatStart | SyncStatMdcEn | EndBusy | InProgress | InProgress_q3 | Nvalid;


// Generation of the InProgress signal (indicates when an operation is in progress)
// Generation of the WriteOp signal (indicates when a write is in progress)
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      InProgress <=  1'b0;
      WriteOp <=  1'b0;
    end
  else
    begin
      if(MdcEn)
        begin
          if(StartOp)
            begin
              if(~InProgress)
                WriteOp <=  WriteDataOp;
              InProgress <=  1'b1;
            end
          else
            begin
              if(EndOp)
                begin
                  InProgress <=  1'b0;
                  WriteOp <=  1'b0;
                end
            end
        end
    end
end



// Bit Counter counts from 0 to 63 (from 32 to 63 when NoPre is asserted)
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    BitCounter[6:0] <=  7'h0;
  else
    begin
      if(MdcEn)
        begin
          if(InProgress)
            begin
              if(NoPre & ( BitCounter == 7'h0 ))
                BitCounter[6:0] <=  7'h21;
              else
                BitCounter[6:0] <=  BitCounter[6:0] + 1;
            end
          else
            BitCounter[6:0] <=  7'h0;
        end
    end
end


// Operation ends when the Bit Counter reaches 63
assign EndOp = BitCounter==63;

assign ByteSelect[0] = InProgress & ((NoPre & (BitCounter == 7'h0)) | (~NoPre & (BitCounter == 7'h20)));
assign ByteSelect[1] = InProgress & (BitCounter == 7'h28);
assign ByteSelect[2] = InProgress & WriteOp & (BitCounter == 7'h30);
assign ByteSelect[3] = InProgress & WriteOp & (BitCounter == 7'h38);


// Latch Byte selects which part of Read Status Data is updated from the shift register
assign LatchByte1_d2 = InProgress & ~WriteOp & BitCounter == 7'h37;
assign LatchByte0_d2 = InProgress & ~WriteOp & BitCounter == 7'h3F;


// Connecting the Clock Generator Module
eth_clockgen clkgen(.Clk(Clk), .Resetn(Resetn), .Divider(Divider[7:0]), .MdcEn(MdcEn), .MdcEn_n(MdcEn_n), .Mdc(Mdc) 
                   );

// Connecting the Shift Register Module
eth_shiftreg shftrg(.Clk(Clk), .Resetn(Resetn), .MdcEn_n(MdcEn_n), .Mdi(Mdi), .Fiad(Fiad), .Rgad(Rgad), 
                    .CtrlData(CtrlData), .WriteOp(WriteOp), .ByteSelect(ByteSelect), .LatchByte(LatchByte), 
                    .ShiftedBit(ShiftedBit), .Prsd(Prsd), .LinkFail(LinkFail)
                   );

// Connecting the Output Control Module
eth_outputcontrol outctrl(.Clk(Clk), .Resetn(Resetn), .MdcEn_n(MdcEn_n), .InProgress(InProgress), 
                          .ShiftedBit(ShiftedBit), .BitCounter(BitCounter), .WriteOp(WriteOp), .NoPre(NoPre), 
                          .Mdo(Mdo), .MdoEn(MdoEn)
                         );

endmodule

