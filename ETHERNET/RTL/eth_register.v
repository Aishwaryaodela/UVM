//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:28:04 06/07/2020 
// Design Name: 
// Module Name:    eth_register 
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
module eth_register(DataIn, DataOut, Write, Clk, Resetn, SyncReset);

parameter WIDTH = 8; // default parameter of the register width
parameter RESET_VALUE = 0;

input [WIDTH-1:0] DataIn;

input Write;
input Clk;
input Resetn;
input SyncReset;

output [WIDTH-1:0] DataOut;
reg    [WIDTH-1:0] DataOut;



always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    DataOut<= RESET_VALUE;
  else
  if(SyncReset)
    DataOut<= RESET_VALUE;
  else
  if(Write)                         // write
    DataOut<= DataIn;
end



endmodule   // Register

