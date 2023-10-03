;; Note: This is a manually written example of synthesis at depth two,
;; and was written as a POC before the generator script was written.
;; Other than as a tool for understanding the approach, it is otherwise
;; of minimal interest.

define i64 @x0() {
  ret i64 0
}

;; TODO: immarg
define i64 @lui(i20 signext %a) {
  %a.ext = sext i20 %a to i64
  %a.shl = shl i64 %a.ext, 12
  ret i64 %a.shl
}

define i64 @add(i64 %a, i64 %b) {
  %res = add i64 %a, %b
  ret i64 %res
}

;; TODO: immarg
define i64 @addi(i64 %a, i12 signext %b) {
  %b.ext = sext i12 %b to i64
  %res = add i64 %a, %b.ext
  ret i64 %res
}

;; TODO: immarg
define i64 @addiw(i64 %rs1, i12 signext %imm) {
  %imm.ext = sext i12 %imm to i64
  %add = add i64 %rs1, %imm.ext
  %add.trunc = trunc i64 %add to i32
  %add.sext = sext i32 %add.trunc to i64
  ret i64 %add.sext
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


define i64 @step_next(i64 %vreg, i8 %choice, i64 %imm_payload) {
entry:
  switch i8 %choice, label %unreachable [
    i8 0, label %x0
    i8 1, label %lui
    i8 2, label %addi
  ]
unreachable:
  unreachable
x0:
  %res = call i64 @x0()
  ret i64 %res

lui:
  %imm0 = trunc i64 %imm_payload to i20
  %res0 = call i64 @lui(i20 %imm0)
  ret i64 %res0

addi:
  %imm1 = trunc i64 %imm_payload to i12
  %res1 = call i64 @addi(i64 %vreg, i12 %imm1)
  ret i64 %res1
}

define i64 @start_step(i8 %choice, i64 %imm_payload) {
entry:
  switch i8 %choice, label %unreachable [
    i8 0, label %x0
    i8 1, label %lui
  ]
unreachable:
  ret i64 poison
x0:
  %res = call i64 @x0()
  ret i64 %res

lui:
  %imm0 = trunc i64 %imm_payload to i20
  %res0 = call i64 @lui(i20 %imm0)
  ret i64 %res0
}


;; declare i64 @add(i64 %a, i64 %b)
;; declare i64 @addi(i64 %a, i12 signext %b)
;; declare i64 @addiw(i64 %rs1, i12 signext %imm)
;; declare i64 @sh1add(i64 %rs1, i64 %rs2)
;; declare i64 @sh2add(i64 %rs1, i64 %rs2)
;; declare i64 @sh3add(i64 %rs1, i64 %rs2)
;; declare i64 @add.uw(i64 %rs1, i64 %rs2)
;; declare i64 @sh1add.uw(i64 %rs1, i64 %rs2)
;; declare i64 @sh2add.uw(i64 %rs1, i64 %rs2)
;; declare i64 @sh3add.uw(i64 %rs1, i64 %rs2)
;; declare i64 @bseti(i64 %rs1, i6 zeroext %imm)
;; declare i64 @bclri(i64 %rs1, i6 zeroext %imm)
;; declare i64 @slli(i64 %rs1, i6 zeroext %imm)
;; declare i64 @srli(i64 %rs1, i6 zeroext %imm)
;; declare i64 @srai(i64 %rs1, i6 zeroext %imm)
;; declare i64 @mul(i64 %rs1, i64 %rs2)
;; declare i64 @mulw(i64 %rs1, i64 %rs2)


define i64 @tgt(i8 %_reservedc_choice0, i64 %_reservedc_imm0, i8 %_reservedc_choice1, i64 %_reservedc_imm1) {
  ret i64 2554839
}

define i64 @src(i8 %_reservedc_choice0, i64 %_reservedc_imm0, i8 %_reservedc_choice1, i64 %_reservedc_imm1) {
  %step1 = call i64 @start_step(i8 %_reservedc_choice0, i64 %_reservedc_imm0)
  %step2 = call i64 @step_next(i64 %step1, i8 %_reservedc_choice1, i64 %_reservedc_imm1)
  ret i64 %step2
}




