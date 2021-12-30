`timescale 1ps / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2020 01:42:26 PM
// Design Name: 
// Module Name: psnr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module psnr(a,b,out,clk);
    input [7:0] a,b;
    input clk;
    output reg [15:0] out;  
    always@(posedge clk) begin
        out = (a-b)*(a-b);
    end
endmodule
