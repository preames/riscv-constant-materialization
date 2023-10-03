# RISDV Constant Synthesis

## TLDR

A small tool to synthesize 64 bit constants on RISCV - mostly of use to compiler developers, and requires a lot of working around sharp edges.

## Build

For the actual synthesis part, this relies on minotaur-cs.  Follow the docker installation from https://github.com/minotaur-toolkit/minotaur/tree/dev.

Then apply the following diff, and run ninja in the minotaor build tree again.

```
@@ -208,8 +211,12 @@ AliveEngine::find_model(Transform &t,
 bool
 AliveEngine::constantSynthesis(llvm::Function &src, llvm::Function &tgt,
    unordered_map<const llvm::Argument*, llvm::Constant*>& ConstMap) {
+
+  smt::set_query_timeout("999999999");
+
   std::optional<smt::smt_initializer> smt_init;
   smt_init.emplace();
```

The default timeout is 10 seconds, this sets it to 99999 seconds or a little over 27 hours.  Zhengyang - the author of minotaur - has indicated he's likely to add a command line timeout flag to minotaur-cs, so hopefully this patch isn't needed for long.


## Usage

Edit the generate.py script to adjust depth and target constant.

```
python generate.py > unoptimized.ll
<llvm-build-dir>/bin/opt -S -O3 unoptimized -o output.ll
time ./minotaur-cs /scratch/preames/synthesis/output.ll
```

## Initial Example

For the target constant of 8589934592 and depth of 1, with the full set of candidate instructions, the results look like:

```
i8 %_reservedc_choice0 = #x0c (12)
i64 %_reservedc_imm0 = #x0000000000000021 (33)
```

If you map this back through the generated switch table, you'll find that the choice value represents bseti and the immediate is a valid bseti immediate.

You can confirm that this is what LLVM exactly generates like so:

```
llc -mtriple=riscv64 -mattr=+v,+zbs < output.ll
```

(Check only the tgt function at the very bottom of the output)


## Example Variants

For the same constant above, and depth of 2, we get:

```
i8 %_reservedc_choice0 = #x0c (12)
i64 %_reservedc_imm0 = #x0000000000000020 (32)
i8 %_reservedc_choice1 = #x02 (2)
i64 %_reservedc_imm1 = #x0000000000000000 (0)
```

This maps to the same bseti, followed by a (useless) addi with zero.  This highlights that the tool does not generate the minimal sequence, and that you may need to try a couple different depth values to find the minimal.

In practice, minimal sequences seem to often be either a prefix or a suffix of the generated sequence, but this is by no means guaranteed.

For the constant 8589934593, with depth of 2, we get:

```
unable to find constants: 
ERROR: Unsat
```

This is correct as there's no one instruction sequence to produce this constant on RV64.  With depth=2, we get:

```
i8 %_reservedc_choice0 = #x0c (12)
i64 %_reservedc_imm0 = #x0000000000000021 (33)
i8 %_reservedc_choice1 = #x03 (3)
i64 %_reservedc_imm1 = #x0000000000000001 (1)
```

This is one of several depth two sequences for producing this value.

Now, let's pick something a bit harder.  For the constant 8589935839385694 (chosen arbitrarily, this is not an interesting number to my knowledge), LLVM currently emits a load through the constant pool.

At depth 1 and 2, we quickly return Unsat.  At depth 3, unsat takes about 15s.  At depth 4, unsat takes 16m.  Higher depths were still running when this page was written, but hopefully the scalability concern is obvious.  :)


## Scalability

As highlighted in the above example, scalability on long sequences is poor.  The search space grows with number_of_instructions^depth.  This tool is most useful when either a) you have a rough idea on the possible sequence and can thus reduce the number of instructions under consideration or b) there's a 3-4 instruction sequence which can be found.

To explore longer sequences, it is strongly advised that you subset the instruction definition file and exclude as many instructions as you can.


## Basic Approach

This section provides an overview of the approach for interested readers.

The riscv64-isa.ll file defines a set of LLVM IR functions whose semantics match the rv64 instructions of the same name.  This can be checked by generating code for this file via LLVM's llc tool.  With the exception of the immediate variants, every function should generate exactly one instruction which matches its name.

We build a instruction sequence synthesizer on top of these definitions, by choosing exactly one instruction at each step.  The core primitive is the step_next function which represents the choice of a single instruction and it's immediate operand if any.  We then emit one copy of this function for each instruction in the allowed depth.  A total of one live value is modeled, so the output of one choice directly feeds the next choice.

This stack of choices forms our source function, and then we generate a target function which simply returns our constant of interest.  The task given the synthesizer is to find the values for the choices which were left symbolic in the source function.  Note that these free variables are described to minotaur-cs via special naming convention.  Arguments which start with ```_reservedc``` are the free variables to be synthesized; arguments without this prefix are normal arguments to the function.  Note that this synthesizer doesn't need normal arguments.

If you look at the generator script, or the unoptimized output file, you'll see the structure exactly as described above.  The last step before handing it to the synthesizer is to force inline and optimize everything via LLVM's opt utility.  This avoids the need for the generator to manually inline and unroll.

The optimization step can also (sometimes) reduce the search space.  As one example, the first instruction starts with a source register of X0 which unconditionally has the value 0.  Only a small handful of instructions out of the full set can produce a non-zero output given only a single zero input.  The (entirely generic) optimizer is able to exploit this property to reduce the search space with no manual work.  (You can see this by looking at the first switch in the optimized output file and noticing it has many fewer cases.)

## Costing

For clarity, this tool does not attempt to consider the cost of the selected sequence at all.  There can be multiple possible sequences at a given depth, and this tool makes no attempt to find "the cheapest" in any sense.
