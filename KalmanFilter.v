`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2025 23:21:17
// Design Name: 
// Module Name: KalmanFilter
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


module KalmanFilter(
    input clk,
    input reset,
    input valid_in,
    input [7:0] z_k,
    output reg [7:0] x_k
);

    reg signed [7:0] x_pred; 
    reg [15:0] K_k1,K_k2, P_pred, P_k, test;
    reg [1:0] state;
    parameter Q = 16'd32;    // Process noise
    parameter R = 16'd64;  // Measurement noise
    
    parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

    always @(posedge clk) begin
        if (reset) begin
            x_k <= 8'd70; // 128.0 
            x_pred <= 8'd0;
            P_k <= 16'd70;   // Initial covariance
            state <= A;
        end else begin
            case (state) 
                A: begin 
                    if (valid_in)
                        state <= B;
                end 

                B: begin
                    //if (valid_in) begin
                        x_pred <= x_k;
                        P_pred <= P_k + Q;
                        state <= C;
                    //end
                end

                C: begin
                    K_k1 <= (P_pred);
                    K_k2 <= (P_pred + R); 
                    state <= D; 
                end 

                D: begin 

                    x_k <= x_pred + ((K_k1*z_k)/K_k2)-((K_k1*x_pred)/K_k2);
                    test <= ((K_k1*P_pred)/K_k2);
                    P_k <= K_k1 - ((K_k1*P_pred)/K_k2);

                    state <= A;
                end 
            endcase
        end
    end
endmodule