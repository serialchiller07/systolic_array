Reconfigurable INT4/INT8 2×2 Systolic Array Accelerator
A SystemVerilog RTL implementation of a 2×2 output-stationary systolic array for signed integer matrix multiplication. The design has four processing elements (PEs), each containing a multiply-accumulate (MAC) unit. Operands and validity signals propagate across the array, while each PE accumulates one output matrix element.

The design supports two selectable input interpretation modes:
- INT8 (precision_mode = 0) — each input is treated as a signed 8-bit integer (−128 to 127).
- INT4 (precision_mode = 1) — the low four bits of each input are interpreted as a signed 4-bit two's-complement integer (−8 to 7) and sign-extended to 8 bits.
Implementation note: INT4 and INT8 currently share the same signed 8×8 multiplier and 32-bit accumulator. INT4 mode changes operand interpretation; it does not implement packed INT4 arithmetic or demonstrate reduced multiplier/DSP resource usage.

Architecture
                 B column 0           B column 1
                      |                    |
                      v                    v
A row 0  ------>   [ PE00 ]  ------>    [ PE01 ]
                      |                    |
                      v                    v
A row 1  ------>   [ PE10 ]  ------>    [ PE11 ]

               C00, C01, C10, C11
- Four PEs: One 8×8 signed multiplication and 32-bit accumulation per PE.
- Data movement: A values move right; B values move down through registered inter-PE links.
- Valid gating: Multiplication results accumulate only when both operand-valid inputs are asserted.
- Precision selection: Sign extension of the low nibble in INT4 mode, or direct signed 8-bit pass-through in INT8 mode.
- Controller: A separate top-level controller captures two 2×2 matrices, clears the array, schedules staggered operands, and exposes busy/`done` signals.
For two input matrices
A = [a00 a01]     B = [b00 b01]
    [a10 a11]         [b10 b11]
the intended output is C = A × B, with:
c00 = a00*b00 + a01*b10
c01 = a00*b01 + a01*b11
c10 = a10*b00 + a11*b10
c11 = a10*b01 + a11*b11
RTL files
File	Module	Purpose
multiplier(1).sv	multiplier	Combinational signed 8×8 multiplication with 16-bit product
mac(1).sv	mac	Clocked, enable-controlled 32-bit accumulator
precision_selector(1).sv	precision_selector	Selects signed INT8 or sign-extended low-nibble INT4 operands
systolic_pe(1).sv	systolic_pe	MAC plus registered forwarding of operands and valid bits
systolic_array_2x2(1).sv	systolic_array_2x2	Connects the four PEs into a 2×2 array
systolic_array_config(1).sv	systolic_array_config	Adds precision selection at the array inputs
accelerator_controller(1).sv	accelerator_controller	Matrix input capture, operand scheduling, and busy/`done` state machine
tb_systolic_array_config.sv	tb_systolic_array_config	Directed self-checking tests for the configurable array


The filenames are kept as supplied. They can be renamed to remove (1) without changing their module names.
Verification
tb_systolic_array_config.sv generates a 100 MHz clock (#5 half-period with a 1 ns timescale), drives the configurable array directly, and compares all four output accumulators against expected values after each clock edge. A mismatch triggers $fatal.
Directed INT4 test
A = [ 2 -1 ]    B = [ 1  2 ]    Expected C = [ 4  1 ]
    [ 3  2 ]        [-2  3 ]                 [-1 12 ]
Directed INT8 test
A = [10 -20]    B = [ 2  3]     Expected C = [ 100 -70]
    [30  40]        [-4  5]                  [-100 290]
The testbench also checks reset behavior, intermediate accumulation values, and stability of the final results when all valid inputs are deasserted. It uses directed test cases rather than constrained-random or coverage-driven verification.

Verification scope: The supplied testbench instantiates systolic_array_config, not accelerator_controller. Controller handshaking, busy/`done` sequencing, and back-to-back matrix transactions are not covered by this testbench. Hardware implementation and board deployment are not established by the supplied files.
Simulating in Vivado
1. Create a new RTL Project in Vivado and select your target FPGA part or board.
2. Under Design Sources, add all seven RTL .sv files listed above (all except the testbench).
3. Under Simulation Sources, add tb_systolic_array_config.sv.
4. Set Simulation Top to tb_systolic_array_config (and, if needed, Design Top to accelerator_controller).
5. Choose Run Simulation → Run Behavioral Simulation.
6. Inspect the simulator transcript for PASS TEST lines and the final ALL ... TESTS PASSED message. Any $fatal indicates a mismatch.
The README describes the testbench's intended behavior. Simulation has not been independently executed as part of preparing this repository documentation, so no passing test result is asserted here.
Tooling and implementation scope
- Language: SystemVerilog
- Development/simulation target: AMD/Xilinx Vivado and XSim
- FPGA target: Digilent Basys 3 (Xilinx Artix-7 XC7A35T) as a project target; no board bitstream or physical deployment evidence is included
- Design style: Synchronous RTL, signed arithmetic, valid-controlled streaming, output-stationary accumulation
Future improvements
- Add an automated testbench for accelerator_controller, including start, busy, done, reset, and consecutive operations.
- Test signed INT4/INT8 boundary values and randomized matrices against an independent software reference model.
- Compare synthesis utilization and timing for the two arithmetic modes; explore genuine packed INT4 or narrower-multiplier implementations.
- Add synthesis constraints, implementation reports, and board-level validation when hardware is available.
