.global sum_of_text


.extern get_path
.extern text_to_number

sum_of_text:
    pushq %rbp
    movq %rsp, %rbp
    sub $64, %rsp
    xor %r10, %r10 # initialize the sum to 0
    movq %rdi, %r10 # save the separator character in r10
    push %r10 # save the separator character on the stack
    call get_path
    pop %r10 # restore the separator character from the stack

    xor %r9, %r9 # initialize the sum to 0

    # open the file
    movq %rax, %rdi
    movq $2 , %rax
    movq $0 , %rsi
    syscall

    # save the file descriptor in r8
    xor %r8, %r8
    movq %rax, %r8


    # read the file
    xor %rcx, %rcx # offset for the buffer
    loop:
      movq %r8, %rdi
      movq $0, %rax
      lea (%rsp,%rcx,1), %rsi # read into the bottom of the stack
      movq $1, %rdx
      syscall
      
      # check if we have reached the end of the file
      cmp $0, %rax
      je finish_file

      # check if we reached the end of the line
      movb (%rsp,%rcx,1), %al
      cmpb $'\n', %al
      je finish_word

      # check if we reached the separator
      cmpb %r10b, %al
      je finish_word

      add $1, %rcx
      jmp loop

    finish_file:
      movb $0, 1(%rsp,%rcx,1)
      movq %rsp, %rdi
      call text_to_number
      cmp $-1, %rax
      je not_a_number
      add %rax, %r9
      jmp end

    finish_word:
      movb $0, 1(%rsp,%rcx,1)
      movq %rsp, %rdi
      push %rcx # save the offset for the next word
      push %r8 # save the file descriptor for the next read
      call text_to_number
      pop %r8 # restore the file descriptor
      pop %rcx # restore the offset for the next word
      cmp $-1, %rax
      je not_a_number
      add %rax, %r9
      xor %rcx, %rcx
      jmp loop

    not_a_number:
      xor %rcx, %rcx
      jmp loop

end:
   mov %r9, %rax # move the sum into rax for the return value
   leave            
   ret
