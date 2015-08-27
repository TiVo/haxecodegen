This program can be used to generate a self-contained complete Haxe
program.  The generated program doesn't do anything meaningful or useful,
but it can be used to test various aspects of the haxe compiler and
runtime.  As an example, a very large program consisting of thousands of
classes, interfaces, etc, can be generated and used to measure the compile
speed of the Haxe compiler, or the generated code size, or the runtime cost
of various operations in aggregate.

The parameters of program generation are configurable along as many axis as
are reasonable and useful, so that small, medium, large, very large, etc,
programs of various complexities can be generated.

The set of language features to be included in the generated code is scoped
to include all features which are expected to be troublesome along any of
the axis of generated code size, generated code speed, and generated code
memory usage (including "churn").  It is not practical to include every
language feature in the code generator, so the most useful subset is
included.  At any time, if a language feature not included in this program
is discovered to be worth inclusion, it can be added later.

Currently, the set of language features that can be included in the
generated code is:

- classes (of various numbers, size, complexity, and inheritence and
           interface implementation characteristics)
- interfacees (of various numbers, size, complexity, and inheritence
               characteristics)
- enums (of of various numbers, size, and complexity)
- anonymous classes
- class properties (with various accessor/mutator types)
- interface properties (with various accessor/mutator types)
- templates
- exception handling (try/catch/throw)
- Dynamic types (casting to/from, as well as setting values on/getting
                 values from)
- closures
- functions with complex signatures, including varargs
- iterators (especially integer iterators, to gauge unnecessary churn)
- switch pattern matching (simple and complex)
- string literals
- @:unreflective (to evaluate effectiveness)
- @:unreflective inline (to evaluate effectiveness)
- inline (to evaluate resulting code size)
- Array class
- Map class
- Bytes and ByteData classes
- EReg class

The generated code is pure haxe with no target-specific characteristics and
thus should be applicable to evaluating every haxe target type (javascript,
hxcpp, neko, etc).
