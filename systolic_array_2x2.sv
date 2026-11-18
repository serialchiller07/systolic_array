`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 19:02:45
// Design Name: 
// Module Name: systolic_array_2x2
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

module systolic_array_2x2 (
    input  logic clk,
    input  logic rst,

    // Left boundary: one stream for each row of A
    input  logic signed [7:0] a_row0,
    input  logic signed [7:0] a_row1,
    input  logic a_row0_valid,
    input  logic a_row1_valid,

    // Top boundary: one stream for each column of B
    input  logic signed [7:0] b_col0,
    input  logic signed [7:0] b_col1,
    input  logic b_col0_valid,
    input  logic b_col1_valid,

    output logic signed [31:0] c00,
    output logic signed [31:0] c01,
    output logic signed [31:0] c10,
    output logic signed [31:0] c11
);
    // Registered inter-PE links. Each link has its own valid bit.
    logic signed [7:0] a00_right, a10_right;
    logic signed [7:0] b00_down,  b01_down;
    logic av00_right, av10_right;
    logic bv00_down,  bv01_down;

    systolic_pe pe00 (
        .clk(clk), .rst(rst),
        .a_in(a_row0), .b_in(b_col0),
        .a_valid_in(a_row0_valid), .b_valid_in(b_col0_valid),
        .a_out(a00_right), .b_out(b00_down),
        .a_valid_out(av00_right), .b_valid_out(bv00_down),
        .acc(c00)
    );

    systolic_pe pe01 (
        .clk(clk), .rst(rst),
        .a_in(a00_right), .b_in(b_col1),
        .a_valid_in(av00_right), .b_valid_in(b_col1_valid),
        .a_out(), .b_out(b01_down),
        .a_valid_out(), .b_valid_out(bv01_down),
        .acc(c01)
    );

    systolic_pe pe10 (
        .clk(clk), .rst(rst),
        .a_in(a_row1), .b_in(b00_down),
        .a_valid_in(a_row1_valid), .b_valid_in(bv00_down),
        .a_out(a10_right), .b_out(),
        .a_valid_out(av10_right), .b_valid_out(),
        .acc(c10)
    );

    systolic_pe pe11 (
        .clk(clk), .rst(rst),
        .a_in(a10_right), .b_in(b01_down),
        .a_valid_in(av10_right), .b_valid_in(bv01_down),
        .a_out(), .b_out(),
        .a_valid_out(), .b_valid_out(),
        .acc(c11)
    );
endmodule

