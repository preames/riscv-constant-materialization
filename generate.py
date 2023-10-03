
depth = 2
target_constant = 8589934593

instructions = []
with open("riscv64-isa.ll", "r") as f:
    for line in f.readlines():
        if not line.startswith("define"):
            continue

        assert(line.startswith("define i64 @"))
        name = line.split("@",1)[1].split("(")[0]
        args_str = line.split("(",1)[1].split(")")[0]
        args = []
        if "" != args_str:
            for a in args_str.split(","):
                a_type = a.split('%')[0].strip().split(' ')[0].strip()
                a_name = a.split('%')[1].strip()
                assert(a_type == "i64" or a_name == "imm")
                args.append({"type": a_type, "name" : a_name})
                pass
            pass
        instructions.append({"opcode" : name, "operands" : args})
        pass
    pass

with open("riscv64-isa.ll", "r") as f:
    for line in f.readlines():
        print (line.rstrip())
        pass
    pass

print("define i64 @step_next(i64 %vreg, i8 %choice, i64 %imm_payload) alwaysinline {")
print("entry:")
print("  switch i8 %choice, label %unreachable [")
for i in range(0, len(instructions)):
    inst = instructions[i]
    print("    i8 " + str(i) + ", label %" + inst["opcode"])
    pass
print("  ]")
print("unreachable:")
print("  ret i64 0")
for i in range(0, len(instructions)):
    inst = instructions[i]
    print(inst["opcode"] + ":");

    arg_strs = []
    for a in inst["operands"]:
        name = "imm_payload"
        if a["name"] != "imm":
            name = "vreg"
        if a["type"] != "i64":
            res = name + ".trunc" + str(i)
            print("  %" + res +" = trunc i64 %" + name + " to " + a["type"])
            name = res
            pass
        arg_strs.append(a["type"] + " %" + name)
        pass
    # FIXME: argument handling
    arg_str = "(" + ", ".join(arg_strs) + ")"
    print("  %res" + str(i) + " = call i64 @" + inst["opcode"] + arg_str)
    print("  ret i64 %res" + str(i))
    pass

print("}")
print("")


args = []
for i in range(0, depth):
    arg = "i8 %_reservedc_choice" +str(i) + ", i64 %_reservedc_imm" + str(i)
    args.append(arg)
    pass
print("define i64 @src(" + ", ".join(args) + ") {")
for i in range(0, depth):
    vr = "%step" + str(i-1)
    # Our register impliciitly starts as x0.
    if (i == 0):
        vr = "0"
    choice = "%_reservedc_choice" + str(i)
    imm = "%_reservedc_imm" + str(i)
    vr_next = "%step" + str(i)

    print ("  " + vr_next + " = call i64 @step_next(i64 " + vr + ", i8 " + choice +", i64 " +imm + ")")
    pass

print("  ret i64 %step" + str(depth-1))
print("}")


print("define i64 @tgt(" + ", ".join(args) + ") {")
print(" ret i64 " + str(target_constant))
print("}")
      




    
