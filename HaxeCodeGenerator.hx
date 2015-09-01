/**
 * Copyright 2015 TiVo, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

/**
 * This program can be used to generate a self-contained complete Haxe
 * program.  The generated program doesn't do anything meaningful or useful,
 * but it can be used to test various aspects of the haxe compiler and
 * runtime.  As an example, a very large program consisting of thousands of
 * classes, interfaces, etc, can be generated and used to measure the compile
 * speed of the Haxe compiler, or the generated code size, or the runtime cost
 * of various operations in aggregate.
 *
 * The parameters of program generation are configurable along as many axis as
 * are reasonable and useful, so that small, medium, large, very large, etc,
 * programs of various complexities can be generated.
 *
 * The set of language features to be included in the generated code is scoped
 * to include all features which are expected to be troublesome along any of
 * the axis of generated code size, generated code speed, and generated code
 * memory usage (including "churn").  It is not practical to include every
 * language feature in the code generator, so the most useful subset is
 * included.  At any time, if a language feature not included in this program
 * is discovered to be worth inclusion, it can be added later.
 *
 * Currently, the set of language features that can be included in the
 * generated code is:
 *
 * - classes (of various numbers, size, complexity, and inheritence and
 *            interface implementation characteristics)
 * - interfaces (of various numbers, size, complexity, and inheritence
 *               characteristics)
 * - enums (of of various numbers, size, and complexity)
 * - anonymous classes
 * - class properties (with various accessor/mutator types)
 * - interface properties (with various accessor/mutator types)
 * - templates
 * - exception handling (try/catch/throw)
 * - Dynamic types (casting to/from, as well as setting values on/getting
 *                  values from)
 * - closures
 * - functions with complex signatures, including varargs
 * - iterators (especially integer iterators, to gauge unnecessary churn)
 * - switch pattern matching (simple and complex)
 * - string literals
 * - @:unreflective (to evaluate effectiveness)
 * - @:unreflective inline (to evaluate effectiveness)
 * - inline (to evaluate resulting code size)
 * - Array class
 * - Map class
 * - Bytes and ByteData classes
 * - EReg class
 *
 * The generated code is pure haxe with no target-specific characteristics and
 * thus should be applicable to evaluating every haxe target type (javascript,
 * hxcpp, neko, etc).
 *
 * TODO:
 *
 * - templates
 * - exception handling (try/catch/throw)
 * - Dynamic types (casting to/from, as well as getting values from)
 * - closures
 * - functions with varargs
 * - @:unreflective (to evaluate effectiveness)
 * - @:unreflective inline (to evaluate effectiveness)
 * - Bytes and ByteData classes
 * - EReg class
 **/

class HaxeCodeGenerator
{
    public static function main() : Int
    {
        // Load options from command line.  Returns false if there was an
        // error.
        if (!Options.load()) {
            Sys.stderr().writeString(Options.usageString);
            Sys.stderr().writeString("\n");
            return -1;
        }

        if (Options.help) {
            Sys.println(Options.usageString);
            return 0;
        }

        Sys.println("Using random seed: " + Options.randomSeed);
        Random.seed(Options.randomSeed);

        // Make the output directory as needed
        try {
            if (sys.FileSystem.isDirectory(Options.outdir)) {
                Util.err("Refusing to overwrite existing output directory " +
                    Options.outdir);
                return -1;
            }
        }
        catch (e : Dynamic) {
        }

        try {
            sys.FileSystem.createDirectory(Options.outdir);
        }
        catch (e : Dynamic) {
            Util.err("Failed to create output directory " + Options.outdir +
                ": " + e);
            return -1;
        }

        // Create classes
        GenClass.generate();

        // Create interfaces
        GenInterface.generate();

        // Create enums
        GenEnum.generate();
        
        // Define class hierarchy
        GenClass.createHierarchy();
        
        // Define interface hierarchy
        GenInterface.createHierarchy();

        // Define enum elements
        GenEnum.createElements();

        // Define interface functions
        GenInterface.createFunctions();

        // Define class functions
        GenClass.createFunctions();

        // Define interface properties
        GenInterface.createProperties();

        // Define class fields
        GenClass.createFields();

        // Collect implementation and inheritence relationships
        GenClass.collectRelationships();

        // Fill class functions with statements
        GenClass.fillFunctions();

        // Now generate the runStatements functions
        GenClass.createRunStatementsFunctions();

        // Emit classes
        GenClass.emit();

        // Emit interfaces
        GenInterface.emit();

        // Emit enums
        GenEnum.emit();

        // Emit the "statics" class
        var path = Options.outdir + "/Statics.hx";
        var out;
        try {
            out = sys.io.File.write(path);
        }
        catch (e : Dynamic) {
            Util.err("Failed to create file: " + path + ": " + e);
            return -1;
        }

        out.writeString("class Statics\n{\n");
        out.writeString("    public static var gStatementCount = 0;\n");
        out.writeString("\n");
        out.writeString("    public static function one()\n");
        out.writeString("    {\n");
        out.writeString("        if (++gStatementCount == " +
                        Options.statementCount + ") {\n");
        out.writeString("            throw \"DONE\";\n");
        out.writeString("        }\n");
        out.writeString("    }\n");
        out.writeString("\n");
        out.writeString("    public static function run()\n");
        out.writeString("    {\n");
        // Create a random class and have it run through a bunch
        // of iterations
        out.writeString("        try {\n");
        out.writeString("            var i = 0;\n");
        out.writeString("            while (true) {\n");
        out.writeString("                var func : (Void -> Void) = null;\n");
        out.writeString("                switch (i) {\n");
        var i = 0;
        while (i < GenClass.gClasses.length) {
            var _class = GenClass.gClasses[i];
            out.writeString("                    case " + i + ":\n");
            out.writeString("                        func = " +
                            _class.fullname + ".runStatements;\n");
            i += 1;
        }
        out.writeString("                }\n");
        out.writeString("                i = i + 1;\n");
        out.writeString("                if (i == " + 
                        GenClass.gClasses.length + ") {\n");
        out.writeString("                    i = 0;\n");
        out.writeString("                }\n");
        out.writeString("                var j = 0;\n");
        out.writeString("                while (j++ < 100) {\n");
        out.writeString("                    func();\n");
        out.writeString("                }\n");
        out.writeString("                trace(gStatementCount);\n");
        out.writeString("            }\n");
        out.writeString("         }\n");
        out.writeString("         catch (e : String) {\n");
        out.writeString("             if (e == \"DONE\") {\n");
        out.writeString("                 return;\n");
        out.writeString("             }\n");
        out.writeString("             throw e;\n");
        out.writeString("         }\n");
        out.writeString("    }\n");
        out.writeString("}\n");
        out.close();

        // Emit the build scripts

        return 0;
    }
}
