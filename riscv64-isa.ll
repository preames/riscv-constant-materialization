;; Formal semantics (in LLVM IR) for A subset of the RISCV ISA
;; with XLEN=64 (i.e. rv64).  Current instruction set taken
;; from RISCVMatInt.cpp

define i64 @lui(i20 signext %imm) {
  %imm.ext = sext i20 %imm to i64
  %imm.shl = shl i64 %imm.ext, 12
  ret i64 %imm.shl
}

define i64 @add(i64 %rs1, i64 %rs2) {
  %res = add i64 %rs1, %rs2
  ret i64 %res
}

define i64 @addi(i64 %rs1, i12 signext %imm) {
  %imm.ext = sext i12 %imm to i64
  %res = add i64 %rs1, %imm.ext
  ret i64 %res
}

define i64 @addiw(i64 %rs1, i12 signext %imm) {
  %imm.ext = sext i12 %imm to i64
  %add = add i64 %rs1, %imm.ext
  %add.trunc = trunc i64 %add to i32
  %add.sext = sext i32 %add.trunc to i64
  ret i64 %add.sext
}


define i64 @xori(i64 %rs1, i12 signext %imm) {
  %imm.ext = sext i12 %imm to i64
  %res = xor i64 %rs1, %imm.ext
  ret i64 %res
}

define i64 @sh1add(i64 %rs1, i64 %rs2) {
  %rs1.shl = shl i64 %rs1, 1
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @sh2add(i64 %rs1, i64 %rs2) {
  %rs1.shl = shl i64 %rs1, 2
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @sh3add(i64 %rs1, i64 %rs2) {
  %rs1.shl = shl i64 %rs1, 3
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @add.uw(i64 %rs1, i64 %rs2) {
  %rs1.trunc = trunc i64 %rs1 to i32
  %rs1.low = zext i32 %rs1.trunc to i64
  %res = add i64 %rs1.low, %rs2
  ret i64 %res
}

define i64 @sh1add.uw(i64 %rs1, i64 %rs2) {
  %rs1.trunc = trunc i64 %rs1 to i32
  %rs1.low = zext i32 %rs1.trunc to i64
  %rs1.shl = shl i64 %rs1.low, 1
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @sh2add.uw(i64 %rs1, i64 %rs2) {
  %rs1.trunc = trunc i64 %rs1 to i32
  %rs1.low = zext i32 %rs1.trunc to i64
  %rs1.shl = shl i64 %rs1.low, 2
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @sh3add.uw(i64 %rs1, i64 %rs2) {
  %rs1.trunc = trunc i64 %rs1 to i32
  %rs1.low = zext i32 %rs1.trunc to i64
  %rs1.shl = shl i64 %rs1.low, 3
  %res = add i64 %rs1.shl, %rs2
  ret i64 %res
}

define i64 @bseti(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %bit = shl i64 1, %imm.masked
  %res = or i64 %rs1, %bit
  ret i64 %res
}

define i64 @bclri(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %bit = shl i64 1, %imm.masked
  %bit.not = xor i64 %bit, -1
  %res = and i64 %rs1, %bit.not
  ret i64 %res
}

define i64 @binvi(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %bit = shl i64 1, %imm.masked
  %res = xor i64 %rs1, %bit
  ret i64 %res
}

declare i64 @llvm.fshr.i64(i64 %a, i64 %b, i64 %c)

define i64 @rori(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %res = call i64 @llvm.fshr.i64(i64 %rs1, i64 %rs1, i64 %imm.masked)
  ret i64 %res
}

define i64 @slli(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %res = shl i64 %rs1, %imm.masked
  ret i64 %res
}

define i64 @srli(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %res = lshr i64 %rs1, %imm.masked
  ret i64 %res
}

define i64 @srai(i64 %rs1, i6 zeroext %imm) {
  %imm.ext = zext i6 %imm to i64
  %imm.masked = and i64 %imm.ext, 63
  %res = ashr i64 %rs1, %imm.masked
  ret i64 %res
}

; Consider adding MULH, MULHU, and MULHSU
define i64 @mul(i64 %rs1, i64 %rs2) {
  %res = mul i64 %rs1, %rs2
  ret i64 %res
}

define i64 @mulw(i64 %rs1, i64 %rs2) {
  %rs1.trunc = trunc i64 %rs1 to i32
  %rs1.low = zext i32 %rs1.trunc to i64
  %rs2.trunc = trunc i64 %rs2 to i32
  %rs2.low = zext i32 %rs2.trunc to i64
  %res = mul i64 %rs1.low, %rs2.low
  %res.trunc = trunc i64 %res to i32
  %res.low = sext i32 %res.trunc to i64
  ret i64 %res.low
}

;; NOTE: These are wrong due to div-by-zero and signed-overflow cases
;; need to add conditional paths before correctly match instruction
;; semantics.
;; define i64 @div(i64 %rs1, i64 %rs2) {
;;   %res = sdiv i64 %rs1, %rs2
;;   ret i64 %res
;; }
;;
;; define i64 @divu(i64 %rs1, i64 %rs2) {
;;   %res = udiv i64 %rs1, %rs2
;;   ret i64 %res
;; }
;;
;; define i64 @rem(i64 %rs1, i64 %rs2) {
;;   %res = srem i64 %rs1, %rs2
;;   ret i64 %res
;; }
;;
;; define i64 @remu(i64 %rs1, i64 %rs2) {
;;   %res = urem i64 %rs1, %rs2
;;   ret i64 %res
;; }


