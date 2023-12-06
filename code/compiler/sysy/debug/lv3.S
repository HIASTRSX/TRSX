  .text
  .globl main
main:
  addi  sp, sp, -16
  li    t0, 2
  li    t1, 3
  mul   t0, t0, t1
  sw    t0, 0(sp)
  li    t0, 1
  lw    t1, 0(sp)
  add   t0, t0, t1
  sw    t0, 4(sp)
  lw    a0, 4(sp)
  addi  sp, sp, 16
  ret


