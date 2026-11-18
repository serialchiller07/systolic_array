`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 19:49:47
// Design Name: 
// Module Name: accelerator_controller
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



module accelerator_controller (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic precision_mode,

    input logic signed [7:0] a00_in, a01_in, a10_in, a11_in,
    input logic signed [7:0] b00_in, b01_in, b10_in, b11_in,

    output logic busy,
    output logic done,

    output logic signed [31:0] c00, c01, c10, c11
);

    typedef enum logic [1:0] {
        IDLE, CLEAR, RUN, DONE
    } state_t;

    state_t state;
    logic [1:0] step_count;

    logic signed [7:0] a00, a01, a10, a11;
    logic signed [7:0] b00, b01, b10, b11;

    logic mode_reg;

    logic signed [7:0] a_row0, a_row1;
    logic signed [7:0] b_col0, b_col1;

    logic a_row0_valid, a_row1_valid;
    logic b_col0_valid, b_col1_valid;
    logic array_rst;

    assign array_rst = !rst_n || (state == CLEAR);

    assign busy = (state == CLEAR) || (state == RUN);
    assign done = (state == DONE);

    // Controller and matrix storage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            step_count <= 2'd0;
            mode_reg <= 1'b0;

            a00 <= 0; a01 <= 0;
            a10 <= 0; a11 <= 0;

            b00 <= 0; b01 <= 0;
            b10 <= 0; b11 <= 0;
        end
        else begin
            case (state)

                IDLE, DONE: begin
                    if (start) begin
                        a00 <= a00_in;
                        a01 <= a01_in;
                        a10 <= a10_in;
                        a11 <= a11_in;

                        b00 <= b00_in;
                        b01 <= b01_in;
                        b10 <= b10_in;
                        b11 <= b11_in;

                        mode_reg <= precision_mode;
                        step_count <= 2'd0;
                        state <= CLEAR;
                    end
                end

                CLEAR: begin
                    step_count <= 2'd0;
                    state <= RUN;
                end

                RUN: begin
                    if (step_count == 2'd3)
                        state <= DONE;
                    else
                        step_count <= step_count + 2'd1;
                end

                default: state <= IDLE;

            endcase
        end
    end

    // Operand scheduler
    always_comb begin
        a_row0 = 0;
        a_row1 = 0;
        b_col0 = 0;
        b_col1 = 0;

        a_row0_valid = 0;
        a_row1_valid = 0;
        b_col0_valid = 0;
        b_col1_valid = 0;

        if (state == RUN) begin
            case (step_count)

                2'd0: begin
                    a_row0 = a00;
                    b_col0 = b00;

                    a_row0_valid = 1;
                    b_col0_valid = 1;
                end

                2'd1: begin
                    a_row0 = a01;
                    a_row1 = a10;

                    b_col0 = b10;
                    b_col1 = b01;

                    a_row0_valid = 1;
                    a_row1_valid = 1;
                    b_col0_valid = 1;
                    b_col1_valid = 1;
                end

                2'd2: begin
                    a_row1 = a11;
                    b_col1 = b11;

                    a_row1_valid = 1;
                    b_col1_valid = 1;
                end

                default: begin
                    // Step 3 flushes remaining
                    // operands through PE11.
                end

            endcase
        end
    end

    // Reconfigurable systolic array
    systolic_array_config u_array (
        .clk(clk),
        .rst(array_rst),
        .precision_mode(mode_reg),

        .a_row0(a_row0),
        .a_row1(a_row1),
        .b_col0(b_col0),
        .b_col1(b_col1),

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
