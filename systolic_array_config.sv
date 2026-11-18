`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 19:06:15
// Design Name: 
// Module Name: systolic_array_config
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


module systolic_array_config (
    input logic clk,
    input logic rst,
    input logic precision_mode,

    input logic signed [7:0] a_row0,
    input logic signed [7:0] a_row1,
    input logic signed [7:0] b_col0,
    input logic signed [7:0] b_col1,

    input logic a_row0_valid,
    input logic a_row1_valid,
    input logic b_col0_valid,
    input logic b_col1_valid,

    output logic signed [31:0] c00,
    output logic signed [31:0] c01,
    output logic signed [31:0] c10,
    output logic signed [31:0] c11
);

    logic signed [7:0] a0_selected;
    logic signed [7:0] a1_selected;
    logic signed [7:0] b0_selected;
    logic signed [7:0] b1_selected;

    // Precision conversion for A row 0
    precision_selector sel_a0 (
        .data_in(a_row0),
        .precision_mode(precision_mode),
        .data_out(a0_selected)
    );

    // Precision conversion for A row 1
    precision_selector sel_a1 (
        .data_in(a_row1),
        .precision_mode(precision_mode),
        .data_out(a1_selected)
    );

    // Precision conversion for B column 0
    precision_selector sel_b0 (
        .data_in(b_col0),
        .precision_mode(precision_mode),
        .data_out(b0_selected)
    );

    // Precision conversion for B column 1
    precision_selector sel_b1 (
        .data_in(b_col1),
        .precision_mode(precision_mode),
        .data_out(b1_selected)
    );

    // Existing 2x2 systolic array
    systolic_array_2x2 u_array (
        .clk(clk),
        .rst(rst),

        .a_row0(a0_selected),
        .a_row1(a1_selected),
        .b_col0(b0_selected),
        .b_col1(b1_selected),

        .a_row0_valid(a_row0_valid),
        .a_row1_valid(a_row1_valid),
        .b_col0_valid(b_col0_valid),
        .b_col1_valid(b_col1_valid),

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

endmodule
