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

class Options
{
    // Set to true if -h, -help, or --help was set
    public static var help : Bool = false;
    // Random seed to use
    public static var randomSeed : Int = 
        Std.int((haxe.Timer.stamp() * 1000) % (0xFFFFFFF));
    // Output directory to emit generated classes into
    public static var outdir : String = "gen.out";
    // Number of classes to generate
    public static var classCount : Int = 3000;
    // Number of interfaces to generate
    public static var interfaceCount : Int = 1750;
    // Number of enums to generate
    public static var enumCount : Int = 200;
    // Maximum class/interface hierarchy depth
    public static var maxExtendsDepth : Int = 10;
    // Number of statements for the resulting program to run
    public static var statementCount : Int = 1000000;

    public static var usageString = "Usage: HaxeCodeGenerator " +
        "[-h/-help/--help]\n" +
        "                         [-rs/-randomSeed <seed>]\n" +
        "                         [-o/-outdir <path>]\n" +
        "                         [-cc/-classCount <count>]\n" +
        "                         [-ic/-interfaceCount <count>]\n" +
        "                         [-ec/-enumCount <count>]\n" +
        "                         [-me/-maxExtendsDepth <depth>]\n" +
        "                         [-sc/-statementCount <count>]\n" +
        "\n" +
        "Options:\n" +
        "-randomSeed: Set the random seed to use; defaults to current time\n" +
        "-outdir: Set the output directory; defaults to \"gen.out\"\n" +
        "-classCount: Number of classes to generate; defaults to 3000\n" +
        "-interfaceCount: Number of interfaces to generate; defaults to " +
        "1750\n" +
        "-enumCount: Number of enums to generate; defaults to 200\n" +
        "-maxExtendsDepth: Maximum depth of any class inheritence or\n" +
        "                  interface inheritence hierarchy; defaults to 10\n" +
        "-statementCount: Number of statements for the generated program\n" +
        "                 to run; defaults to 1000000\n";

    /**
     * This method parses the command line options, storing the parsed values
     * in the properties above, and returning true on a successful parse,
     * false on failure.
     *
     * @return true on success, false on failure
     **/
    public static function load() : Bool
    {
        var argv = Sys.args();
        var iter = 0 ... argv.length;
        try {
            for (i in iter) {
                var arg = argv[i];
                switch (argv[i]) {
                case "-h", "-help", "--help":
                    help = true;
                    // Can stop now as no other options will matter
                    return true;
                case "-o", "-outdir":
                    if (i == (argv.length - 1)) {
                        Util.err(argv[i] + " requires an argument");
                        throw false;
                    }
                    outdir = argv[iter.next()];
                case "-rs", "-randomSeed":
                    randomSeed = getIntArgument(argv, i, iter);
                case "-cc", "-classCount":
                    classCount = getIntArgument(argv, i, iter);
                case "-ic", "-interfaceCount":
                    interfaceCount = getIntArgument(argv, i, iter);
                case "-ec", "-enumCount":
                    enumCount = getIntArgument(argv, i, iter);
                case "-me", "-maxExtendsDepth":
                    maxExtendsDepth = getIntArgument(argv, i, iter);
                case "-sc", "-statementCount":
                    statementCount = getIntArgument(argv, i, iter);
                default:
                    Util.err("Unknown command-line argument: " + arg + "\n");
                    return false;
                }
            }
        }
        catch (e : Dynamic)
        {
            return false;
        }

        if (classCount <= 0) {
            Util.err("classCount must be greater than 0");
        }
        
        if (interfaceCount < 0) {
            Util.err("interfaceCount must be positive");
        }

        if (enumCount < 0) {
            Util.err("enumCount must be positive");
        }

        if (maxExtendsDepth < 0) {
            Util.err("maxExtendsDepth must be positive");
        }

        if (statementCount < 0) {
            Util.err("statementCount must be positive");
        }

        return true;
    }

    private static function getIntArgument(argv : Array<String>, i : Int,
                                           iter : Iterator<Int>) : Int
    {
        if (i == (argv.length - 1)) {
            Util.err(argv[i] + " requires an argument");
            throw false;
        }

        return Std.parseInt(argv[iter.next()]);
    }
}
