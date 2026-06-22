.globl my_ili_handler
.extern what_to_do, old_ili_handler

.text
.align 4, 0x90
my_ili_handler:
   pushq %rdi
   pushq %rsi
   pushq %rdx
   pushq %rcx
   pushq %r8
   pushq %r9
   pushq %r10
   pushq %r11
   pushq %rbx
   pushq %rbp
   pushq %r12
   pushq %r13
   pushq %r14
   pushq %r15
   pushq %rax

   xorq %rdi, %rdi
   movq 120(%rsp), %rbx
   movb (%rbx), %dil

   cmpb $0X0F, %dil
   je TowByte
OneByte:
   movb (%rbx), %dil
   movq $1, %r12
   jmp callWhatToDo

TowByte:
   movb 1(%rbx), %dil
   movq $2, %r12

callWhatToDo:
   call what_to_do

   cmpq $0, %rax
   je oldHandler

   addq %r12, 120(%rsp)
   movq %rax, 112(%rsp)
   popq %rax
   popq %r15
   popq %r14
   popq %r13
   popq %r12
   popq %rbp
   popq %rbx
   popq %r11
   popq %r10
   popq %r9
   popq %r8
   popq %rcx
   popq %rdx
   popq %rsi
   popq %rdi

    iretq


oldHandler:
   popq %rax
   popq %r15
   popq %r14
   popq %r13
   popq %r12
   popq %rbp
   popq %rbx
   popq %r11
   popq %r10
   popq %r9
   popq %r8
   popq %rcx
   popq %rdx
   popq %rsi
   popq %rdi

   jmp old_ili_handler

  ####### Some smart student's code here #######
