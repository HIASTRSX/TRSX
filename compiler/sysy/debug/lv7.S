  .text
  .globl main
main:
  addi  sp, sp, -48
  li    t0, 0
  sw    t0, 0(sp)
  li    t0, 1
  sw    t0, 4(sp)
  j     while_entry_0
while_entry_0:
  lw    t0, 0(sp)
  sw    t0, 8(sp)
  lw    t0, 8(sp)
  li    t1, 7
  slt   t0, t0, t1
  sw    t0, 12(sp)
  lw    t0, 12(sp)
  bnez  t0, Label0
  j     while_end_0
Label0:
  j     while_body_0
while_body_0:
  lw    t0, 4(sp)
  sw    t0, 16(sp)
  lw    t0, 16(sp)
  li    t1, 2
  mul   t0, t0, t1
  sw    t0, 20(sp)
  lw    t0, 20(sp)
  sw    t0, 4(sp)
  lw    t0, 0(sp)
  sw    t0, 24(sp)
  lw    t0, 24(sp)
  li    t1, 1
  add   t0, t0, t1
  sw    t0, 28(sp)
  lw    t0, 28(sp)
  sw    t0, 0(sp)
  j     while_entry_0
while_end_0:
  lw    t0, 4(sp)
  sw    t0, 32(sp)
  lw    a0, 32(sp)
  addi  sp, sp, 48
  ret


