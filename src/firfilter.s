.data
# Input signal
input:      .float -3.0,7.0,89.0,-12.0,7.0,99.0,167.0,67.29,8.32,45.65,89.23,-4.0
# number of samples
n_samples:  .word 12

# Circular buffer for last 4 samples (x[n], x[n-1], x[n-2], x[n-3])
buffer:.space 16

# Filter taps (coefficients)
tap:.float 0.1, 0.4, 0.4, 0.1

# Output storage (8 words)
output:.space 48

    .text
main:
    la x5, input            # pointer to input samples
    la x6, output           # pointer to output buffer
    la x7, buffer           # buffer base pointer
    la x10, tap             # tap base pointer

    lw x8, n_samples        # number of samples (integer load)
    li x9, 0                # sample index (n)

    # --- allocate stack space for 12 floats (12*4 = 48) ; allocate 64 bytes for 16-byte alignment ---
    addi sp, sp, -64
    addi x12, sp, 0         # x12 = push pointer (will advance by +4 each push)

loop:
    #    (x[3] = x[2], x[2] = x[1], x[1] = x[0])
    flw ft0, 8(x7)          # Load x[2]
    fsw ft0, 12(x7)         # Store in x[3]
    flw ft0, 4(x7)          # Load x[1]
    fsw ft0, 8(x7)          # Store in x[2]
    flw ft0, 0(x7)          # Load x[0]
    fsw ft0, 4(x7)          # Store in x[1]

    # Load new sample x[0]
    flw ft0, 0(x5)          # (ft0 = x[n])
    fsw ft0, 0(x7)          # Store x[n] in buf[0]

    # Compute y[n] (accumulator)
    fsub.s ft1, ft1, ft1    # ft1 = 0.0

    # tap 0 (buf[0] * tap[0])
    flw ft2, 0(x7)          # Load x[n]
    flw ft3, 0(x10)         # Load tap[0]
    fmul.s ft4, ft2, ft3
    fadd.s ft1, ft1, ft4

    # tap 1 (buf[1] * tap[1])
    flw ft2, 4(x7)          # Load x[n-1]
    flw ft3, 4(x10)         # Load tap[1]
    fmul.s ft4, ft2, ft3
    fadd.s ft1, ft1, ft4

    # tap 2 (buf[2] * tap[2])
    flw ft2, 8(x7)          # Load x[n-2]
    flw ft3, 8(x10)         # Load tap[2]
    fmul.s ft4, ft2, ft3
    fadd.s ft1, ft1, ft4

    # tap 3 (buf[3] * tap[3])
    flw ft2, 12(x7)         # Load x[n-3]
    flw ft3, 12(x10)        # Load tap[3]
    fmul.s ft4, ft2, ft3
    fadd.s ft1, ft1, ft4

    #Store final output to output array
    fsw ft1, 0(x6)

    #PUSH y[n] onto software stack (fsw to memory at push pointer)
    fsw ft1, 0(x12)         # store ft1 at [push_ptr]
    addi x12, x12, 4        # advance push pointer

    # advance pointers
    addi x5, x5, 4          # next input
    addi x6, x6, 4          # next output
    addi x9, x9, 1
    blt x9, x8, loop        # loop until n_samples done

    # --- After loop: load stack values into ft0..ft11 ---
    # reset read pointer to stack base (sp)
    addi x13, sp, 0         # x13 = base of pushed values

    flw ft0, 0(x13)         # ft0 = y[0]
    flw ft1, 4(x13)         # ft1 = y[1]
    flw ft2, 8(x13)         # ft2 = y[2]
    flw ft3, 12(x13)        # ft3 = y[3]
    flw ft4, 16(x13)        # ft4 = y[4]
    flw ft5, 20(x13)        # ft5 = y[5]
    flw ft6, 24(x13)        # ft6 = y[6]
    flw ft7, 28(x13)        # ft7 = y[7]
    flw ft8, 32(x13)        # ft8 = y[8]
    flw ft9, 36(x13)        # ft9 = y[9]
    flw ft10, 40(x13)       # ft10 = y[10]
    flw ft11, 44(x13)       # ft11 = y[11]

    # restore stack pointer
    addi sp, sp, 64

done:
    nop
