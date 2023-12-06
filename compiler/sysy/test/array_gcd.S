  .data
  .globl n_0
n_0:
  .zero 4

  .text
  .globl gcd
gcd:
  addi  sp, sp, -96
  sw    a0, 0(sp)
  sw    a1, 4(sp)
  lw    t0, 0(sp)
  sw    t0, 16(sp)
  lw    t0, 4(sp)
  sw    t0, 20(sp)
  lw    t0, 16(sp)
  lw    t1, 20(sp)
  slt   t0, t0, t1
  sw    t0, 24(sp)
  lw    t0, 24(sp)
  bnez  t0, Label0
  j     end_0
Label0:
  j     then_0
then_0:
  lw    t0, 0(sp)
  sw    t0, 28(sp)
  lw    t0, 28(sp)
  sw    t0, 8(sp)
  lw    t0, 4(sp)
  sw    t0, 32(sp)
  lw    t0, 32(sp)
  sw    t0, 0(sp)
  lw    t0, 8(sp)
  sw    t0, 36(sp)
  lw    t0, 36(sp)
  sw    t0, 4(sp)
  j     end_0
end_0:
  lw    t0, 0(sp)
  sw    t0, 40(sp)
  lw    t0, 4(sp)
  sw    t0, 44(sp)
  lw    t0, 40(sp)
  lw    t1, 44(sp)
  rem   t0, t0, t1
  sw    t0, 48(sp)
  lw    t0, 48(sp)
  sw    t0, 12(sp)
  j     while_entry_0
while_entry_0:
  lw    t0, 12(sp)
  sw    t0, 52(sp)
  lw    t0, 52(sp)
  li    t1, 0
  xor   t0, t0, t1
  snez  t0, t0
  sw    t0, 56(sp)
  lw    t0, 56(sp)
  bnez  t0, Label1
  j     while_end_0
Label1:
  j     while_body_0
while_body_0:
  lw    t0, 4(sp)
  sw    t0, 60(sp)
  lw    t0, 60(sp)
  sw    t0, 0(sp)
  lw    t0, 12(sp)
  sw    t0, 64(sp)
  lw    t0, 64(sp)
  sw    t0, 4(sp)
  lw    t0, 0(sp)
  sw    t0, 68(sp)
  lw    t0, 4(sp)
  sw    t0, 72(sp)
  lw    t0, 68(sp)
  lw    t1, 72(sp)
  rem   t0, t0, t1
  sw    t0, 76(sp)
  lw    t0, 76(sp)
  sw    t0, 12(sp)
  j     while_entry_0
while_end_0:
  lw    t0, 4(sp)
  sw    t0, 80(sp)
  lw    a0, 80(sp)
  addi  sp, sp, 96
  ret


  .text
  .globl main
main:
  addi  sp, sp, -32
  sw    ra, 28(sp)
  li    t0, 10
  sw    t0, 0(sp)
  li    t0, 1478
  sw    t0, 4(sp)
  lw    t0, 0(sp)
  sw    t0, 8(sp)
  lw    t0, 4(sp)
  sw    t0, 12(sp)
  lw    a0, 8(sp)
  lw    a1, 12(sp)
  call gcd
  sw    a0, 16(sp)
  lw    a0, 16(sp)
  lw    ra, 28(sp)
  addi  sp, sp, 32
  ret


