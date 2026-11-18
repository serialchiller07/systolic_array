`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 19:00:12
// Design Name: 
// Module Name: precision_selector
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


module precision_selector (
    input  logic signed [7:0] data_in,
    input  logic precision_mode,
    output logic signed [7:0] data_out
);

    // precision_mode = 0 : INT8
    // precision_mode = 1 : INT4

    always_comb begin
        if (precision_mode == 1'b1)
            data_out = {{4{data_in[3]}}, data_in[3:0]};
        else
            data_out = data_in;
    end

endmodule
