`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2025 00:35:17
// Design Name: 
// Module Name: MedianFilter
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


module MedianFilter(
    input rst,
    input [11:0] in,
    input data_valid,
    output reg [11:0] out
    );
     reg [11:0] x0, x1, x2;
     always @(posedge data_valid or posedge rst) begin
        if (rst) begin
            x0 <= 12'd0;
            x1 <= 12'd0;
            x2 <= 12'd0;
        end else begin
            x2 <= x1;
            x1 <= x0;
            x0 <= in;
        end
    end
    always @(posedge data_valid or posedge rst ) begin
        if (rst) begin
            out <= 12'd0;
        end else begin
            if ((x0 <= x1 && x1 <= x2) || (x2 <= x1 && x1 <= x0))
                out <= x1;
            else if ((x1 <= x0 && x0 <= x2) || (x2 <= x0 && x0 <= x1))
                out <= x0;
            else
                out <= x2;
            end
        end
   
endmodule
