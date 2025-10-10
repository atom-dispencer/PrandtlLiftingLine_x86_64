
  #
  # My submission for my MMME3080 (Advanced Aerodynamics) module - a program to
  # ease calculation of Prandtl's Lifting Line Theory.
  #
  # Why assembly? Because it was an excuse to learn some assembly, plus someone
  # last year did this in C++ and thought they were cool. If someone wants to
  # be even cooler, I would accept defeat to machine-code, BASIC, MUMPS or some
  # headache-inducing esolang :)
  #

  .section .data
msg:
  .asciz "mulss testing: %f\n"
b:
  .double 500.0
area:
  .double 1000.0

msg_read:
  .asciz "Input a double: "
fmt_read:
  .asciz "%f"

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

  lea msg_read(%rip), %rdi
  call f_read_double

  # Kill the stack frame
  mov %rbp, %rsp
  pop %rbp
  # return 0
  mov $0, %eax
  ret

  #
  # Params:
  #   rdi: char* prompt
  # Returns:
  #   eax: success ? 0 : 1
  #   xmm0: user input value
  #
  # NOTE: I forgot if this works lol
f_read_double:
  push %rbp
  mov %rsp, %rbp
  sub $16, %rsp

  # printf(prompt)
  # rdi is already set
  xor %rax, %rax
  call printf

  # eax = scanf ( format, current_stack_pointer )
  lea fmt_read(%rip), %rdi
  lea (%rsp), %rsi
  call scanf

  # If read exactly 1 value, success, otherwise fail
  cmp $1, %eax
  jne _f_read_double_fail
_f_read_double_succ:

  movsd (%rsp), %xmm0

  mov $0, %eax
  jmp _f_read_double_end
_f_read_double_fail:
  mov $1, %eax
_f_read_double_end:

  add $16, %rsp
  pop %rbp 
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

