  .text
  .globl main
main:
  addi  sp, sp, -32
  li    t0, 1
  sw    t0, 0(sp)
  li    t0, 2
  sw    t0, 4(sp)
  li    t0, 2
  sw    t0, 8(sp)
  lw    t0, 4(sp)
  sw    t0, 12(sp)
  lw    t0, 8(sp)
  sw    t0, 16(sp)
  lw    t0, 12(sp)
  lw    t1, 16(sp)
  add   t0, t0, t1
  sw    t0, 20(sp)
  lw    t0, 20(sp)
  sw    t0, 4(sp)
  lw    t0, 4(sp)
  sw    t0, 24(sp)
  lw    a0, 24(sp)
  addi  sp, sp, 32
  ret


