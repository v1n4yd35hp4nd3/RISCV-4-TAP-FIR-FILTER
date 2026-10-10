# RISCV-4-TAP-FIR-FILTER
# 4-Tap FIR Filter Using RISC-V Assembly

## Overview

This project implements a **4-tap Finite Impulse Response (FIR) digital filter using RISC-V assembly language and floating-point instructions**. The implementation demonstrates how a digital signal-processing algorithm can be executed at the instruction level using the RISC-V F extension.

The computed output is verified against MATLAB's built-in `filter()` function to validate the correctness of the implementation.

## Objectives

- Implement a 4-tap FIR filter using RISC-V assembly.
- Understand sample delays and weighted accumulation in digital filtering.
- Perform floating-point multiplication and addition using RISC-V instructions.
- Manage input samples, filter coefficients, intermediate values, and outputs in memory.
- Verify the assembly implementation using MATLAB.

## FIR Filter Theory

A Finite Impulse Response filter computes its output using a finite number of input samples. Unlike an Infinite Impulse Response (IIR) filter, it does not use previous output samples as feedback.

The output is given by:

\[
y[n]=\sum_{k=0}^{M-1}h[k]x[n-k]
\]

For this implementation, the four-tap equation is:

\[
\begin{aligned}
y[n] ={}& 0.1x[n] + 0.4x[n-1]\\
        &+ 0.4x[n-2] + 0.1x[n-3]
\end{aligned}
\]

where:
- \(x[n]\) is the current input sample.
- \(h[k]\) represents the filter coefficients.
- \(y[n]\) is the filtered output.
- The initial delay-buffer samples are zero.

The symmetric coefficients provide a linear-phase FIR structure, apart from the usual floating-point numerical precision considerations.

## System Parameters

| Parameter | Value |
|---|---|
| Filter type | Finite Impulse Response (FIR) |
| Number of taps | 4 |
| Filter order | 3 |
| Tap coefficients | `[0.1, 0.4, 0.4, 0.1]` |
| Input samples | 8 |
| Arithmetic | 32-bit floating point |
| Implementation | RISC-V assembly |
| Verification | MATLAB |

## Input Data

The input samples used in the assembly implementation are:

```text
[-3.0, 7.0, 89.0, -12.0, 7.0, 99.0, 167.0, 67.29]
```

The filter coefficients are:

```text
[0.1, 0.4, 0.4, 0.1]
```

The input samples and coefficients are stored in the assembly data segment. A four-element delay buffer holds the most recent samples required for each filtering operation.

## Implementation Methodology

### 1. Memory Initialization

The input samples, tap coefficients, output memory, and delay buffer are defined in the data segment. The delay buffer must begin with zero-valued samples so that the initial outputs correctly account for unavailable past inputs.

### 2. Sample Buffer Update

For every new input sample, the previous samples are shifted through the four-element buffer. The newest input is loaded into the first position.

The buffer represents:

```text
buffer[0] = x[n]
buffer[1] = x[n-1]
buffer[2] = x[n-2]
buffer[3] = x[n-3]
```

### 3. Floating-Point Multiply–Accumulate

The RISC-V F extension instructions perform the filtering operations:

| Instruction | Purpose |
|---|---|
| `flw` | Load a floating-point value from memory |
| `fsw` | Store a floating-point value in memory |
| `fmul.s` | Multiply two single-precision floating-point values |
| `fadd.s` | Accumulate the weighted sample products |
| `fsub.s` | Initialize the accumulator to zero |
| `addi` | Update pointers and loop counters |
| `blt` | Control the filtering loop |

For each sample, the four weighted products are accumulated to calculate the corresponding output.

### 4. Output Storage

The calculated output is stored in the output memory region. The implementation also saves the outputs on the software stack and subsequently loads the first eight results into floating-point registers `ft0` through `ft7` for inspection.

## Results

The eight filtered outputs obtained from the input sequence are:

| Sample | Filtered output |
|---|---:|
| y[0] | -0.3000 |
| y[1] | -0.5000 |
| y[2] | 10.5000 |
| y[3] | 36.0000 |
| y[4] | 32.2000 |
| y[5] | 16.8000 |
| y[6] | 57.9000 |
| y[7] | 113.8290 |

These values are consistent with the expected four-tap FIR convolution using the specified input sequence and coefficients.

## MATLAB Verification

The assembly output is checked using MATLAB's built-in `filter()` function.

```matlab
input = [-3 7 89 -12 7 99 167 67.29];
coeff = [0.1 0.4 0.4 0.1];

y = filter(coeff, 1, input);

disp(y);
```

Expected output:

```text
-0.3000  -0.5000  10.5000  36.0000 ...
32.2000  16.8000  57.9000  113.8290
```

The agreement between the RISC-V results and MATLAB reference output validates the filtering algorithm for the tested input sequence.

## Applications

Four-tap FIR filters are useful in several signal-processing applications:

- **Noise reduction and signal smoothing:** Reducing high-frequency fluctuations in sampled signals.
- **Sensor processing:** Smoothing sensor measurements and ADC-converted signals.
- **Control systems:** Preprocessing motor feedback, potentiometer readings, and encoder measurements.
- **Biomedical signal processing:** Filtering sampled ECG and EEG signals.

## Key Concepts Demonstrated

- RISC-V assembly programming.
- Floating-point arithmetic using the RISC-V F extension.
- FIR filter theory and discrete-time convolution.
- Sliding-window sample management.
- Memory addressing and pointer updates.
- Stack-based storage and register inspection.
- Algorithm verification using MATLAB.

## Conclusion

This project demonstrates the implementation of a four-tap FIR filter at the RISC-V assembly level. The filter uses a four-sample delay buffer and explicit floating-point multiplication and accumulation instructions to compute each output sample.

MATLAB verification confirms that the computed output sequence matches the reference FIR implementation for the tested input. The project provides practical experience in low-level programming, computer architecture, and digital signal processing.
