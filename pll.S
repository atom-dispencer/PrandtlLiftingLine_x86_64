
  #
  # My submission for my MMME3080 (Advanced Aerodynamics) module - a program to
  # ease calculation of Prandtl's Lifting Line Theory. This program has minimal
  # dependencies, requiring only to be linked with libc and for gnuplot to be
  # installed and runnable on the device.
  #
  # ~~~ Building ~~~
  #
  # To build, you can either use CMake:
  #   cd PrandtlLiftingLine_x86_64
  #   cmake -S . -b build
  #   cmake --build build --clean-first
  # ... or you can build it directly with GCC:
  #   cd PrandtlLiftingLine_x86_64
  #   gcc -no-pie pll.S -o pll
  #
  # ~~~ Why Assembly? ~~~
  #
  # Because it seemed like a fun idea at the time... plus someone last year 
  # thought they were cool for doing in in C++ ;) ... This program was
  # hand-written in x86_64 AT&T-style (GAS) assembly, using neovim btw. 
  # Code-generation tools were not used, but GodBolt.org was occasionally 
  # referenced for instruction or register descriptions.
  # 
  # If someone wants to be even cooler, I would accept defeat to machine-code, 
  # BASIC, MUMPS or some headache-inducing esolang :)
  #
  # ~~~ Basic Behaviour ~~~
  #
  # This program asks the user for a number of parameters to define their wing
  # (limited to linear functions of AoA and chord, see below), then formulates
  # and solves the linear system, and displays the result to the user using
  # gnuplot.
  #
  # ~~~ Caveats ~~~
  #
  # The Julia implementation which this is based on (github:mberto79/LLT) uses
  # some neat Julia features, like higher order functions, which could be done
  # in assembly but would serve little purpose. After all, if a higher-order
  # function is used so that the user can simply put their own function in, it
  # would be self-defeating in my opinion to make them write it in x86 and
  # recompile the program. Hence, this program does not accept arbitrary 
  # functions for chord or AoA. Instead, it assumes linear functions and 
  # allows the user to input coefficients.
  #

.section .data

msg:
  .asciz "mulss testing: %f\n"
b:
  .double 35223
area:
  .double 1000.0
chordR:
  .double 235666
chordT:
  .double 233

msg_read:
  .asciz "Input a double: "
fmt_read:
  .asciz "%f"

  #
  # Program/Executable
  #

.section .text
.global main

.extern printf
.extern scanf

main:
  # Set up a new GCC-style stack frame
  push %rbp
  mov %rsp, %rbp

  movsd b(%rip), %xmm0
  movsd area(%rip), %xmm1
  call f_aspect_ratio

  movsd b(%rip), %xmm0
  movsd chordR(%rip), %xmm1
  movsd chordT(%rip), %xmm2
  call f_wing_area

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
  #
  # Returns:
  #   eax: success ? 0 : 1
  #   xmm0: user input value
  #
  # Touches:
  #   ???
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
  # Touches:
  #   N/A
  # 
f_aspect_ratio:
  mulsd %xmm0, %xmm0            # b * b
  divsd %xmm1, %xmm0            # ... / area 
  ret

  #
  # Params
  #   xmm0: wingspan (m)
  #   xmm1: root chord (m)
  #   xmm2: tip chord (m)
  #
  # Returns:
  #   xmm0: wing area (m2)
  #
  # Touches:
  #   rax
  #   xmm6
  #
  # Checked:
  #   YES - Checked against a Python reimplementation of the Julia
  #
f_wing_area:
  mov $2, %rax
  cvtsi2sd %rax, %xmm6          # Generate a floating-point $2

  movsd %xmm1, %xmm7            # xmm7 = root
  addsd %xmm2, %xmm7            # xmm7 = root + tip
  mulsd %xmm0, %xmm7            # xmm7 = span * (root + tip)
  divsd %xmm6, %xmm7            # xmm7 = 0.5 * span  (root + tip)

  movsd %xmm7, %xmm0
  ret
