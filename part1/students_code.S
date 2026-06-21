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
    xor %r14, %r14 
    movq %rdi, %r14 
    call get_path

    xor %r13, %r13 # initialize the sum to 0

    # open the file
    movq %rax, %rdi
    movq $2 , %rax
    movq $0 , %rsi
    syscall

    # save the file descriptor in r12
    xor %r12, %r12
    movq %rax, %r12


    # read the file
    xor %r15, %r15 # offset for the buffer
    loop:
      movq %r12, %rdi
      movq $0, %rax
      lea (%rsp,%r15,1), %rsi # read into the bottom of the stack
      movq $1, %rdx
      syscall
      
      # check if we have reached the end of the file
      cmp $0, %rax
      je finish_file

      # check if we reached the end of the line
      movb (%rsp,%r15,1), %al
      cmpb $'\n', %al
      je finish_word

      # check if we reached the separator
      cmpb %r14b, %al
      je finish_word

      add $1, %r15 # increment the offset
      jmp loop

    finish_file:
      movb $0, (%rsp,%r15,1)
      movq %rsp, %rdi
      call text_to_number
      cmp $-1, %eax
      je close_file
      add %rax, %r13
      jmp close_file

    finish_word:
      movb $0, (%rsp,%r15,1)
      movq %rsp, %rdi
      call text_to_number
      cmp $-1, %eax
      je not_a_number
      add %rax, %r13

    not_a_number:
      xor %r15, %r15 # reset the offset for the next word
      jmp loop

    close_file:
      movq %r12, %rdi
      movq $3, %rax
      syscall

end:
   mov %r13, %rax # move the sum into rax for the return value 
   add $64, %rsp
   pop %r15
   pop %r14
   pop %r13
   pop %r12        
   pop %rbp   
   ret
