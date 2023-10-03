
; Note: This file is a subset of riscv64-isa.ll for purposes
; of getting something synthesizable on high depths.

define i64 @x0() {
  ret i64 0
}

define i64 @lui(i20 signext %imm) {
  %imm.ext = sext i20 %imm to i64
  %imm.shl = shl i64 %imm.ext, 12
  ret i64 %imm.shl
}

define i64 @addi(i64 %rs1, i12 signext %imm) {
  %imm.ext = sext i12 %imm to i64
  %res = add i64 %rs1, %imm.ext
  ret i64 %res
}

define i64 @slli(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %res = shl i64 %rs1, %imm.masked
  ret i64 %res
}


