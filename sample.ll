;; Toy example for testing minotaur-cs.  

define i64 @tgt(i8 %_reservedc_choice0, i64 %_reservedc_imm0, i8 %_reservedc_choice1, i64 %_reservedc_imm1) {
  ret i64 257478
}
define i64 @src(i8 %_reservedc_choice0, i64 %_reservedc_imm0, i8 %_reservedc_choice1, i64 %_reservedc_imm1) {
  ret i64 %_reservedc_imm1
}
