  .data
  .globl n_0
n_0:
  .zero 4

  .text
  .globl QuickSort
QuickSort:
  addi  sp, sp, -368
  sw    ra, 364(sp)
  sw    a0, 0(sp)
  sw    a1, 4(sp)
  sw    a2, 8(sp)
  lw    t0, 4(sp)
  sw    t0, 12(sp)
  lw    t0, 8(sp)
  sw    t0, 16(sp)
  lw    t0, 12(sp)
  lw    t1, 16(sp)
  slt   t0, t0, t1
  sw    t0, 20(sp)
  lw    t0, 20(sp)
  bnez  t0, Label0
  j     end_0
Label0:
  j     then_0
then_0:
  lw    t0, 4(sp)
  sw    t0, 28(sp)
  lw    t0, 28(sp)
  sw    t0, 24(sp)
  lw    t0, 8(sp)
  sw    t0, 36(sp)
  lw    t0, 36(sp)
  sw    t0, 32(sp)
  lw    t0, 4(sp)
  sw    t0, 44(sp)
  lw    t0, 0(sp)
  sw    t0, 48(sp)
  lw    t0, 48(sp)
  lw    t1, 44(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 52(sp)
  lw    t0, 52(sp)
  lw    t0, 0(t0)
  sw    t0, 56(sp)
  lw    t0, 56(sp)
  sw    t0, 40(sp)
  j     while_entry_0
end_0:
  li    a0, 0
  lw    ra, 364(sp)
  addi  sp, sp, 368
  ret
while_entry_0:
  lw    t0, 24(sp)
  sw    t0, 60(sp)
  lw    t0, 32(sp)
  sw    t0, 64(sp)
  lw    t0, 60(sp)
  lw    t1, 64(sp)
  slt   t0, t0, t1
  sw    t0, 68(sp)
  lw    t0, 68(sp)
  bnez  t0, Label1
  j     while_end_0
Label1:
  j     while_body_0
while_body_0:
  j     while_entry_1
while_end_0:
  lw    t0, 40(sp)
  sw    t0, 72(sp)
  lw    t0, 24(sp)
  sw    t0, 76(sp)
  lw    t0, 0(sp)
  sw    t0, 80(sp)
  lw    t0, 80(sp)
  lw    t1, 76(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 84(sp)
  lw    t0, 72(sp)
  lw    t1, 84(sp)
  sw    t0, 0(t1)
  lw    t0, 24(sp)
  sw    t0, 92(sp)
  lw    t0, 92(sp)
  li    t1, 1
  sub   t0, t0, t1
  sw    t0, 96(sp)
  lw    t0, 96(sp)
  sw    t0, 88(sp)
  lw    t0, 0(sp)
  sw    t0, 100(sp)
  lw    t0, 4(sp)
  sw    t0, 104(sp)
  lw    t0, 88(sp)
  sw    t0, 108(sp)
  lw    a0, 100(sp)
  lw    a1, 104(sp)
  lw    a2, 108(sp)
  call QuickSort
  sw    a0, 112(sp)
  lw    t0, 112(sp)
  sw    t0, 88(sp)
  lw    t0, 24(sp)
  sw    t0, 116(sp)
  lw    t0, 116(sp)
  li    t1, 1
  add   t0, t0, t1
  sw    t0, 120(sp)
  lw    t0, 120(sp)
  sw    t0, 88(sp)
  lw    t0, 0(sp)
  sw    t0, 124(sp)
  lw    t0, 88(sp)
  sw    t0, 128(sp)
  lw    t0, 8(sp)
  sw    t0, 132(sp)
  lw    a0, 124(sp)
  lw    a1, 128(sp)
  lw    a2, 132(sp)
  call QuickSort
  sw    a0, 136(sp)
  lw    t0, 136(sp)
  sw    t0, 88(sp)
  j     end_0
while_entry_1:
  li    t0, 0
  sw    t0, 140(sp)
  lw    t0, 24(sp)
  sw    t0, 144(sp)
  lw    t0, 32(sp)
  sw    t0, 148(sp)
  lw    t0, 144(sp)
  lw    t1, 148(sp)
  slt   t0, t0, t1
  sw    t0, 152(sp)
  lw    t0, 152(sp)
  bnez  t0, Label2
  j     end_sc_0
Label2:
  j     then_sc_0
then_sc_0:
  lw    t0, 32(sp)
  sw    t0, 156(sp)
  lw    t0, 0(sp)
  sw    t0, 160(sp)
  lw    t0, 160(sp)
  lw    t1, 156(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 164(sp)
  lw    t0, 164(sp)
  lw    t0, 0(t0)
  sw    t0, 168(sp)
  lw    t0, 40(sp)
  sw    t0, 172(sp)
  lw    t0, 172(sp)
  li    t1, 1
  sub   t0, t0, t1
  sw    t0, 176(sp)
  lw    t0, 168(sp)
  lw    t1, 176(sp)
  sgt   t0, t0, t1
  sw    t0, 180(sp)
  lw    t0, 180(sp)
  li    t1, 0
  xor   t0, t0, t1
  snez  t0, t0
  sw    t0, 184(sp)
  lw    t0, 184(sp)
  sw    t0, 140(sp)
  j     end_sc_0
end_sc_0:
  lw    t0, 140(sp)
  sw    t0, 188(sp)
  lw    t0, 188(sp)
  bnez  t0, Label3
  j     while_end_1
Label3:
  j     while_body_1
while_body_1:
  lw    t0, 32(sp)
  sw    t0, 192(sp)
  lw    t0, 192(sp)
  li    t1, 1
  sub   t0, t0, t1
  sw    t0, 196(sp)
  lw    t0, 196(sp)
  sw    t0, 32(sp)
  j     while_entry_1
while_end_1:
  lw    t0, 24(sp)
  sw    t0, 200(sp)
  lw    t0, 32(sp)
  sw    t0, 204(sp)
  lw    t0, 200(sp)
  lw    t1, 204(sp)
  slt   t0, t0, t1
  sw    t0, 208(sp)
  lw    t0, 208(sp)
  bnez  t0, Label4
  j     end_1
Label4:
  j     then_1
then_1:
  lw    t0, 32(sp)
  sw    t0, 212(sp)
  lw    t0, 0(sp)
  sw    t0, 216(sp)
  lw    t0, 216(sp)
  lw    t1, 212(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 220(sp)
  lw    t0, 220(sp)
  lw    t0, 0(t0)
  sw    t0, 224(sp)
  lw    t0, 24(sp)
  sw    t0, 228(sp)
  lw    t0, 0(sp)
  sw    t0, 232(sp)
  lw    t0, 232(sp)
  lw    t1, 228(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 236(sp)
  lw    t0, 224(sp)
  lw    t1, 236(sp)
  sw    t0, 0(t1)
  lw    t0, 24(sp)
  sw    t0, 240(sp)
  lw    t0, 240(sp)
  li    t1, 1
  add   t0, t0, t1
  sw    t0, 244(sp)
  lw    t0, 244(sp)
  sw    t0, 24(sp)
  j     end_1
end_1:
  j     while_entry_2
while_entry_2:
  li    t0, 0
  sw    t0, 248(sp)
  lw    t0, 24(sp)
  sw    t0, 252(sp)
  lw    t0, 32(sp)
  sw    t0, 256(sp)
  lw    t0, 252(sp)
  lw    t1, 256(sp)
  slt   t0, t0, t1
  sw    t0, 260(sp)
  lw    t0, 260(sp)
  bnez  t0, Label5
  j     end_sc_1
Label5:
  j     then_sc_1
then_sc_1:
  lw    t0, 24(sp)
  sw    t0, 264(sp)
  lw    t0, 0(sp)
  sw    t0, 268(sp)
  lw    t0, 268(sp)
  lw    t1, 264(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 272(sp)
  lw    t0, 272(sp)
  lw    t0, 0(t0)
  sw    t0, 276(sp)
  lw    t0, 40(sp)
  sw    t0, 280(sp)
  lw    t0, 276(sp)
  lw    t1, 280(sp)
  slt   t0, t0, t1
  sw    t0, 284(sp)
  lw    t0, 284(sp)
  li    t1, 0
  xor   t0, t0, t1
  snez  t0, t0
  sw    t0, 288(sp)
  lw    t0, 288(sp)
  sw    t0, 248(sp)
  j     end_sc_1
end_sc_1:
  lw    t0, 248(sp)
  sw    t0, 292(sp)
  lw    t0, 292(sp)
  bnez  t0, Label6
  j     while_end_2
Label6:
  j     while_body_2
while_body_2:
  lw    t0, 24(sp)
  sw    t0, 296(sp)
  lw    t0, 296(sp)
  li    t1, 1
  add   t0, t0, t1
  sw    t0, 300(sp)
  lw    t0, 300(sp)
  sw    t0, 24(sp)
  j     while_entry_2
while_end_2:
  lw    t0, 24(sp)
  sw    t0, 304(sp)
  lw    t0, 32(sp)
  sw    t0, 308(sp)
  lw    t0, 304(sp)
  lw    t1, 308(sp)
  slt   t0, t0, t1
  sw    t0, 312(sp)
  lw    t0, 312(sp)
  bnez  t0, Label7
  j     end_2
Label7:
  j     then_2
then_2:
  lw    t0, 24(sp)
  sw    t0, 316(sp)
  lw    t0, 0(sp)
  sw    t0, 320(sp)
  lw    t0, 320(sp)
  lw    t1, 316(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 324(sp)
  lw    t0, 324(sp)
  lw    t0, 0(t0)
  sw    t0, 328(sp)
  lw    t0, 32(sp)
  sw    t0, 332(sp)
  lw    t0, 0(sp)
  sw    t0, 336(sp)
  lw    t0, 336(sp)
  lw    t1, 332(sp)
  li    t2, 4
  mul   t1, t1, t2
  add   t0, t0, t1
  sw    t0, 340(sp)
  lw    t0, 328(sp)
  lw    t1, 340(sp)
  sw    t0, 0(t1)
  lw    t0, 32(sp)
  sw    t0, 344(sp)
  lw    t0, 344(sp)
  li    t1, 1
  sub   t0, t0, t1
  sw    t0, 348(sp)
  lw    t0, 348(sp)
  sw    t0, 32(sp)
  j     end_2
end_2:
  j     while_entry_0


