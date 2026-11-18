`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 18:23:25
// Design Name: 
// Module Name: systolic_pe
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


module systolic_pe (
    input  logic clk,
    input  logic rst,

    // Input operands
    input  logic signed [7:0] a_in,
    input  logic signed [7:0] b_in,

    // Input validity
    input  logic a_valid_in,
    input  logic b_valid_in,

    // Registered forwarding outputs
    output logic signed [7:0] a_out,
    output logic signed [7:0] b_out,

    // Forwarded validity
    output logic a_valid_out,
    output logic b_valid_out,

    // Accumulated result
    output logic signed [31:0] acc
);

    logic mac_enable;

    // Accumulate only when both operands are valid
    assign mac_enable = a_valid_in && b_valid_in;

    // Existing signed MAC module
    mac u_mac (
        .clk(clk),
        .rst(rst),
        .en(mac_enable),
        .a(a_in),
        .b(b_in),
        .acc(acc)
    );

    // Forward operands and valid signals
    always_ff @(posedge clk) begin
        if (rst) begin
            a_out       <= 8'sd0;
            b_out       <= 8'sd0;
            a_valid_out <= 1'b0;
            b_valid_out <= 1'b0;
        end
        else begin
            a_out       <= a_in;
            b_out       <= b_in;
            a_valid_out <= a_valid_in;
            b_valid_out <= b_valid_in;
        end
    end

endmodule
