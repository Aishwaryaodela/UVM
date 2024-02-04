//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:27:19 06/07/2020 
// Design Name: 
// Module Name:    eth_random 
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
module eth_random (MTxClk, Resetn, StateJam, StateJam_q, RetryCnt, NibCnt, ByteCnt, 
                   RandomEq0, RandomEqByteCnt);

input MTxClk;
input Resetn;
input StateJam;
input StateJam_q;
input [3:0] RetryCnt;
input [15:0] NibCnt;
input [9:0] ByteCnt;
output RandomEq0;
output RandomEqByteCnt;

wire Feedback;
reg [9:0] x;
wire [9:0] Random;
reg  [9:0] RandomLatched;


always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    x[9:0] <=  0;
  else
    x[9:0] <=  {x[8:0], Feedback};
end

assign Feedback = ~(x[2] ^ x[9]);

assign Random [0] = x[0];
assign Random [1] = (RetryCnt > 1) ? x[1] : 1'b0;
assign Random [2] = (RetryCnt > 2) ? x[2] : 1'b0;
assign Random [3] = (RetryCnt > 3) ? x[3] : 1'b0;
assign Random [4] = (RetryCnt > 4) ? x[4] : 1'b0;
assign Random [5] = (RetryCnt > 5) ? x[5] : 1'b0;
assign Random [6] = (RetryCnt > 6) ? x[6] : 1'b0;
assign Random [7] = (RetryCnt > 7) ? x[7] : 1'b0;
assign Random [8] = (RetryCnt > 8) ? x[8] : 1'b0;
assign Random [9] = (RetryCnt > 9) ? x[9] : 1'b0;


always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RandomLatched <=  10'h000;
  else
    begin
      if(StateJam & StateJam_q)
        RandomLatched <=  Random;
    end
end

// Random Number == 0      IEEE 802.3 page 68. If 0 we go to defer and not to backoff.
assign RandomEq0 = RandomLatched == 10'h0; 

assign RandomEqByteCnt = ByteCnt[9:0] == RandomLatched & (&NibCnt[6:0]);

endmodule

