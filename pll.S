  .section .data
msg:
  .asciz "Prandtl says hi!\n"

.section .text
.global main

.extern printf

main:
  # Set up a new GCC-style stack frame
  push %rbp
  mov %rsp, %rbp

  # printf(msg)
  lea msg(%rip), %rdi     
  xor %rax, %rax
  call printf


  # Kill the stack frame
  mov %rbp, %rsp
  pop %rbp
  # return 0
  mov $0, %eax
  ret
