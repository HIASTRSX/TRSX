  .data
  .globl var_0
var_0:
  .zero 4

  .text
  .globl func
func:
  addi  sp, sp, -32
  sw    a0, 0(sp)
  la    t0, var_0
  lw    t0, 0(t0)
  sw    t0, 4(sp)
  lw    t0, 0(sp)
  sw    t0, 8(sp)
  lw    t0, 4(sp)
  lw    t1, 8(sp)
  add   t0, t0, t1
  sw    t0, 12(sp)
  lw    t0, 12(sp)
  la    t1, var_0
  sw    t0, 0(t1)
  la    t0, var_0
  lw    t0, 0(t0)
  sw    t0, 16(sp)
  lw    a0, 16(sp)
  addi  sp, sp, 32
  ret


  .text
  .globl main
main:
  addi  sp, sp, -32
  sw    ra, 28(sp)
  li    a0, 1
  call func
  sw    a0, 0(sp)
  lw    a0, 0(sp)
  call putint
  la    t0, var_0
  lw    t0, 0(t0)
  sw    t0, 4(sp)
  lw    t0, 4(sp)
  li    t1, 10
  mul   t0, t0, t1
  sw    t0, 8(sp)
  lw    t0, 8(sp)
  la    t1, var_0
  sw    t0, 0(t1)
  li    a0, 2
  call func
  sw    a0, 12(sp)
  lw    a0, 12(sp)
  call putint
  li    a0, 10
  call putch
  la    t0, var_0
  lw    t0, 0(t0)
  sw    t0, 16(sp)
  lw    a0, 16(sp)
  lw    ra, 28(sp)
  addi  sp, sp, 32
  ret


