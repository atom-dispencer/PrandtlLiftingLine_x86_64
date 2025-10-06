  .section .data
msg:
  .asciz "mulss testing: %f\n"
b:
  .double 500.0
area:
  .double 1000.0

.section .text
.global main

.extern printf

main:
  # Set up a new GCC-style stack frame
  push %rbp
  mov %rsp, %rbp

  movsd b(%rip), %xmm0
  movsd area(%rip), %xmm1
  call f_aspect_ratio

  # printf(msg, float)
  sub $64, %rsp
  lea msg(%rip), %rdi     
  movsd %xmm0, (%rsp)
  call printf
  add $64, %rsp

  # Kill the stack frame
  mov %rbp, %rsp
  pop %rbp
  # return 0
  mov $0, %eax
  ret

  #
  # Params:
  #   xxm0: float b
  #   xmm1: float area
  #
  # Returns:
  #   xmm0: float aspect_ratio
  # 
f_aspect_ratio:
  push %rbp
  mov %rsp, %rbp

  mulsd %xmm0, %xmm0            # b * b
  divsd %xmm1, %xmm0            # ... / area 

  pop %rbp
  ret

