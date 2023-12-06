  .text
  .globl main
main:
  addi  sp, sp, -48
  li    t0, 0
  sw    t0, 0(sp)
  li    t0, 1
  sw    t0, 4(sp)
  li    t0, 1
  sw    t0, 8(sp)
  lw    t0, 0(sp)
  sw    t0, 12(sp)
  lw    t0, 12(sp)
  bnez  t0, Label0
  j     then_sc_0
Label0:
  j     end_sc_0
end_sc_0:
  lw    t0, 8(sp)
  sw    t0, 16(sp)
  lw    t0, 16(sp)
  bnez  t0, Label1
  j     end_0
Label1:
  j     then_0
then_sc_0:
  lw    t0, 4(sp)
  sw    t0, 20(sp)
  lw    t0, 20(sp)
  li    t1, 0
  xor   t0, t0, t1
  snez  t0, t0
  sw    t0, 24(sp)
  lw    t0, 24(sp)
  sw    t0, 8(sp)
  j     end_sc_0
then_0:
  lw    t0, 0(sp)
  sw    t0, 28(sp)
  lw    t0, 4(sp)
  sw    t0, 32(sp)
  lw    t0, 28(sp)
  lw    t1, 32(sp)
  add   t0, t0, t1
  sw    t0, 36(sp)
  lw    t0, 36(sp)
  sw    t0, 0(sp)
  j     end_0
end_0:
  lw    t0, 0(sp)
  sw    t0, 40(sp)
  lw    a0, 40(sp)
  addi  sp, sp, 48
  ret


