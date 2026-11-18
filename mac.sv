`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 14:51:41
// Design Name: 
// Module Name: mac
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


module mac (
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [31:0] acc
);

    logic signed [15:0] product;
    logic signed [31:0] product_extended;

    // Instantiate existing multiplier
    multiplier u_multiplier (
        .a(a),
        .b(b),
        .product(product)
    );

    // Sign extension: 16 bits to 32 bits
    assign product_extended = {{16{product[15]}}, product};

    // Sequential accumulator
    always_ff @(posedge clk) begin
        if (rst)
            acc <= 32'sd0;
        else if (en)
            acc <= acc + product_extended;
    end

endmodule
