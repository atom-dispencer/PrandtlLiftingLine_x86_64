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

  # scanf( *64_msgFromUser, 64, stdin )
  sub $64, %rsp                 # Allocate 64 bytes on stack (stack grows down,
  lea (%rsp), %rdi              #   but data in the stack grows upwards)
  mov $64, %rsi
  mov stdin(%rip), %rdx
  call fgets

  # printf( *64_msgFromUser )
  lea (%rsp), %rdi
  xor %rax, %rax
  call printf
  add $64, %rsp                 # Free 64 bytes on stack

  # Kill the stack frame
  mov %rbp, %rsp
  pop %rbp
  # return 0
  mov $0, %eax
  ret
