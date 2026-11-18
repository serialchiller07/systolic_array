
# Reconfigurable INT4/INT8 Systolic Array Accelerator

A SystemVerilog-based implementation of a **2×2 reconfigurable systolic array accelerator** designed for signed integer matrix multiplication.

The architecture consists of four Processing Elements (PEs), each performing Multiply-Accumulate (MAC) operations. The design supports selectable **INT4 and INT8 precision modes**, enabling matrix multiplication with different operand bit widths.

The project targets the **Xilinx Artix-7 FPGA (Digilent Basys 3)** and uses AMD Vivado for RTL development and simulation.

## Key Features

- 2×2 systolic array architecture with four processing elements.
- Configurable signed INT4 and INT8 operand modes.
- 32-bit accumulators for matrix multiplication.
- Registered operand propagation between processing elements.
- Valid-signal-controlled MAC operations.
- Dedicated precision selection module.
- Accelerator controller for matrix loading and computation scheduling.
- Self-checking SystemVerilog testbench.
- Directed verification of INT4 and INT8 matrix multiplication.

## Architecture

The systolic array follows an output-stationary dataflow, where each PE accumulates one element of the output matrix.

```text
                  B Column 0        B Column 1
                      |                 |
                      v                 v
 A Row 0 ------->   [PE00] --------> [PE01]
                      |                 |
                      v                 v
 A Row 1 ------->   [PE10] --------> [PE11]

             Output Matrix: C = A × B
```

Each Processing Element performs:

```text
ACC = ACC + (A × B)
```

The operands propagate through the array while the partial sums remain in their respective processing elements.

## Precision Modes

| Mode | Selection | Input Range |
|------|-----------|-------------|
| INT8 | precision_mode = 0 | -128 to +127 |
| INT4 | precision_mode = 1 | -8 to +7 |

In INT4 mode, the lower four bits of each operand are interpreted as a signed 4-bit integer and sign-extended to eight bits.

Both modes currently share the same signed 8-bit multiplier hardware. The implementation provides selectable operand precision but does not yet implement dedicated packed INT4 multiplication.

## Matrix Multiplication

For two 2×2 matrices:

```text
A = [a00  a01]       B = [b00  b01]
    [a10  a11]           [b10  b11]
```

The output matrix is:

```text
C = [c00  c01]
    [c10  c11]
```

Where:

```text
c00 = a00*b00 + a01*b10
c01 = a00*b01 + a01*b11
c10 = a10*b00 + a11*b10
c11 = a10*b01 + a11*b11
```

## RTL Modules

| Module | Description |
|--------|-------------|
| multiplier | Signed 8×8 multiplication |
| mac | Multiply-accumulate operation with 32-bit accumulator |
| precision_selector | INT4/INT8 operand selection and sign extension |
| systolic_pe | Processing element with MAC and operand forwarding |
| systolic_array_2x2 | Four-PE systolic array architecture |
| systolic_array_config | Configurable precision interface |
| accelerator_controller | Matrix loading, control FSM, and scheduling |

## Project Structure

```text
Systolic-Array-Accelerator/
│
├── accelerator_controller.sv
├── mac.sv
├── multiplier.sv
├── precision_selector.sv
├── systolic_array_2x2.sv
├── systolic_array_config.sv
├── systolic_pe.sv
├── tb_systolic_array_config.sv
└── README.md
```

## Verification

The project includes a self-checking SystemVerilog testbench for validating the configurable systolic array.

The testbench covers:

- INT4 matrix multiplication.
- INT8 matrix multiplication.
- Reset functionality.
- Intermediate MAC accumulation.
- Output comparison against expected results.
- Output stability after valid inputs are deasserted.

### Test Case 1: INT4 Matrix Multiplication

Input matrices:

```text
A = [2  -1]       B = [ 1  2]
    [3   2]           [-2  3]
```

Expected output:

```text
C = [ 4   1]
    [-1  12]
```

### Test Case 2: INT8 Matrix Multiplication

Input matrices:

```text
A = [10  -20]       B = [ 2  3]
    [30   40]           [-4  5]
```

Expected output:

```text
C = [ 100  -70]
    [-100  290]
```

The testbench compares computed outputs against expected results and reports errors when mismatches are detected.

**Verification scope:** The included testbench verifies `systolic_array_config`. The accelerator controller requires separate verification.

## Tools and Technologies

- **HDL:** Verilog / SystemVerilog
- **Development Environment:** AMD Vivado
- **Simulation:** Vivado XSim
- **FPGA Target:** Xilinx Artix-7 XC7A35T
- **Development Board:** Digilent Basys 3
- **Clock Target:** 100 MHz

## How to Simulate

1. Open AMD Vivado.
2. Create a new RTL project.
3. Add all seven RTL modules under Design Sources.
4. Add `tb_systolic_array_config.sv` under Simulation Sources.
5. Set `tb_systolic_array_config` as the simulation top.
6. Select **Run Simulation → Run Behavioral Simulation**.
7. Observe the waveforms and check the simulation transcript for test results.

The testbench uses automated comparisons and `$fatal` to detect incorrect outputs.

## Future Improvements

- Dedicated INT4 arithmetic datapath optimization.
- Randomized verification with signed boundary cases.
- Accelerator controller verification.
- FPGA resource utilization analysis.
- Timing and power optimization.
- Hardware implementation on Basys 3.
- Extension to larger systolic arrays and CNN acceleration.

## Author

**Rutva Gandhi**  
B.Tech, Electronics and Communication Engineering  
Indian Institute of Information Technology, Nagpur
