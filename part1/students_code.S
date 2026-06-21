.global sum_of_text

.extern get_path
.extern text_to_number

sum_of_text:
    pushq %rbp
    movq %rsp, %rbp
    push %r12 
    push %r13
    push %r14
    push %r15
    sub $64, %rsp
    
    # =========================================================================
    # FIX: Save the separator safely to the stack before calling get_path.
    # If your C test passes it as a character (e.g., sum_of_text(..., '-')), use:
    movb %dil, 56(%rsp)     
    
    # IF your C test passes it as a string pointer (e.g., sum_of_text(..., "-")), 
    # uncomment the line below instead:
    # movb (%rdi), %al; movb %al, 56(%rsp)
    # =========================================================================

    call get_path

    xor %r13, %r13          # Initialize the sum to 0

    # Open the file
    movq %rax, %rdi
    movq $2, %rax           # Syscall 2: open
    movq $0, %rsi           # O_RDONLY
    syscall

    # Save the file descriptor in r12
    xor %r12, %r12
    movq %rax, %r12

    # Read the file
    xor %r15, %r15          # Offset for the buffer
    
loop:
    movq %r12, %rdi
    movq $0, %rax           # Syscall 0: read
    lea (%rsp,%r15,1), %rsi # Read into the bottom of the stack
    movq $1, %rdx
    syscall
      
    # Check if we have reached the end of the file
    cmp $0, %rax
    je finish_file

    # Check if we reached the end of the line
    movb (%rsp,%r15,1), %al
    cmpb $'\n', %al
    je finish_word

    # FIX: Compare against the safely preserved stack byte
    cmpb 56(%rsp), %al
    je finish_word

    add $1, %r15            # Increment the offset
    jmp loop

finish_file:
    movb $0, (%rsp,%r15,1)
    movq %rsp, %rdi
    call text_to_number
    cmp $-1, %eax
    je close_file
    cltq
    add %rax, %r13
    jmp close_file

finish_word:
    movb $0, (%rsp,%r15,1)
    movq %rsp, %rdi
    call text_to_number
    cmp $-1, %eax
    je not_a_number
    cltq
    add %rax, %r13

not_a_number:
    xor %r15, %r15          # Reset the offset for the next word
    jmp loop

close_file:
    movq %r12, %rdi
    movq $3, %rax           # Syscall 3: close
    syscall

end:
    mov %r13, %rax          # Move the sum into rax for the return value 
    add $64, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12        
    pop %rbp   
    ret