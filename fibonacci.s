# Fibonacci sequence calculator
# Calculate Fibonacci sequence up to 20 iterations
# Stores results in memory starting at address 0

    # Initialize registers
    addi x1, x0, 1      # x1 = 1 (first fibonacci number)
    addi x2, x0, 1      # x2 = 1 (second fibonacci number)
    addi x3, x0, 0      # x3 = 0 (memory address counter)
    addi x4, x0, 20     # x4 = 20 (number of iterations)
    addi x5, x0, 0      # x5 = 0 (iteration counter)

    # Store the first two Fibonacci numbers (both 1)
    sw x1, 0(x3)        # Store first value at mem[0]
    addi x3, x3, 4      # Increment memory pointer by 4 bytes
    sw x2, 0(x3)        # Store second value at mem[4]
    addi x3, x3, 4      # Increment memory pointer by 4 bytes
    addi x5, x5, 2      # We've already calculated 2 numbers

fibonacci_loop:
    # Check if we've reached 20 iterations
    beq x5, x4, done    # If counter == 20, we're done
    
    # Calculate next Fibonacci number: x6 = x1 + x2
    add x6, x1, x2
    
    # Store the calculated value in memory
    sw x6, 0(x3)
    addi x3, x3, 4      # Increment memory pointer by 4 bytes
    
    # Shift values for next iteration: x1 = x2, x2 = x6
    addi x1, x2, 0      # x1 = x2
    addi x2, x6, 0      # x2 = x6
    
    # Increment counter
    addi x5, x5, 1
    
    # Loop back for next iteration
    jal x0, fibonacci_loop

done:
    # End of program
    addi x7, x0, 1      # Set x7 to 1 to indicate completion
    
    # Infinite loop to stop execution
halt_loop:
    jal x0, halt_loop 