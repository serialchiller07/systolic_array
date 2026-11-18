`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 19:11:36
// Design Name: 
// Module Name: tb_systolic_array_config
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

module tb_systolic_array_config;

    logic clk = 0;
    logic rst = 0;
    logic precision_mode = 0;

    logic signed [7:0] a_row0 = 0;
    logic signed [7:0] a_row1 = 0;
    logic signed [7:0] b_col0 = 0;
    logic signed [7:0] b_col1 = 0;

    logic a_row0_valid = 0;
    logic a_row1_valid = 0;
    logic b_col0_valid = 0;
    logic b_col1_valid = 0;

    logic signed [31:0] c00, c01, c10, c11;

    integer test_count = 0;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Device Under Test
    systolic_array_config dut (
        .clk(clk),
        .rst(rst),
        .precision_mode(precision_mode),

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

    // Check all four accumulated results
    task automatic check_outputs(
        input logic signed [31:0] e00,
        input logic signed [31:0] e01,
        input logic signed [31:0] e10,
        input logic signed [31:0] e11
    );
        begin
            test_count = test_count + 1;

            if (c00 !== e00 ||
                c01 !== e01 ||
                c10 !== e10 ||
                c11 !== e11) begin

                $display("FAIL TEST %0d", test_count);
                $display("Expected: %0d %0d %0d %0d",
                         e00, e01, e10, e11);
                $display("Actual:   %0d %0d %0d %0d",
                         c00, c01, c10, c11);

                $fatal(1, "Matrix output mismatch");
            end
            else begin
                $display("PASS TEST %0d", test_count);
                $display("C = [%0d %0d; %0d %0d]",
                         c00, c01, c10, c11);
            end
        end
    endtask

    // Reset array and clear input streams
    task automatic reset_array;
        begin
            @(negedge clk);

            rst = 1;

            a_row0 = 0;
            a_row1 = 0;
            b_col0 = 0;
            b_col1 = 0;

            a_row0_valid = 0;
            a_row1_valid = 0;
            b_col0_valid = 0;
            b_col1_valid = 0;

            @(posedge clk);
            #1;

            check_outputs(0, 0, 0, 0);

            @(negedge clk);
            rst = 0;
        end
    endtask

    // Apply one cycle of systolic inputs
    task automatic step(
        input logic signed [7:0] a0, a1,
        input logic signed [7:0] b0, b1,

        input logic va0, va1,
        input logic vb0, vb1,

        input logic signed [31:0] e00, e01,
        input logic signed [31:0] e10, e11
    );
        begin
            @(negedge clk);

            a_row0 = a0;
            a_row1 = a1;
            b_col0 = b0;
            b_col1 = b1;

            a_row0_valid = va0;
            a_row1_valid = va1;
            b_col0_valid = vb0;
            b_col1_valid = vb1;

            @(posedge clk);
            #1;

            check_outputs(e00, e01, e10, e11);
        end
    endtask

    initial begin

        // =====================================
        // TEST 1: INT4 MATRIX MULTIPLICATION
        // =====================================

        $display("STARTING INT4 TEST");

        precision_mode = 1'b1;

        // A = [ 2 -1 ]
        //     [ 3  2 ]
        //
        // B = [ 1  2 ]
        //     [-2  3 ]
        //
        // Expected C = [ 4  1 ]
        //              [-1 12 ]

        reset_array();

        // Edge 1
        step(8'h02, 8'h00, 8'h01, 8'h00,
             1, 0, 1, 0,
             2, 0, 0, 0);

        // Edge 2
        // -1 = 4'hF, -2 = 4'hE
        step(8'h0F, 8'h03, 8'h0E, 8'h02,
             1, 1, 1, 1,
             4, 4, 3, 0);

        // Edge 3
        step(8'h00, 8'h02, 8'h00, 8'h03,
             0, 1, 0, 1,
             4, 1, -1, 6);

        // Edge 4
        step(8'h00, 8'h00, 8'h00, 8'h00,
             0, 0, 0, 0,
             4, 1, -1, 12);

        // Check results remain stable
        step(0, 0, 0, 0,
             0, 0, 0, 0,
             4, 1, -1, 12);

        $display("INT4 TEST PASSED");


        // =====================================
        // TEST 2: INT8 MATRIX MULTIPLICATION
        // =====================================

        $display("STARTING INT8 TEST");

        precision_mode = 1'b0;

        // A = [ 10 -20 ]
        //     [ 30  40 ]
        //
        // B = [  2  3 ]
        //     [ -4  5 ]
        //
        // Expected C = [ 100  -70 ]
        //              [-100  290 ]

        reset_array();

        // Edge 1
        step(10, 0, 2, 0,
             1, 0, 1, 0,
             20, 0, 0, 0);

        // Edge 2
        step(-20, 30, -4, 3,
             1, 1, 1, 1,
             100, 30, 60, 0);

        // Edge 3
        step(0, 40, 0, 5,
             0, 1, 0, 1,
             100, -70, -100, 90);

        // Edge 4
        step(0, 0, 0, 0,
             0, 0, 0, 0,
             100, -70, -100, 290);

        // Hold final results
        step(0, 0, 0, 0,
             0, 0, 0, 0,
             100, -70, -100, 290);

        $display("INT8 TEST PASSED");

        $display("============================");
        $display("ALL %0d TESTS PASSED", test_count);
        $display("============================");

        $finish;

    end

endmodule

