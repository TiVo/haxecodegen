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
    public static var help : Bool;
    // Random seed to use
    public static var randomSeed : Int;
    // Output directory to emit generated classes into
    public static var outdir : String;
    // Number of classes to generate
    public static var classCount : Int; // default 3000
    // Number of interfaces to generate
    public static var interfaceCount : Int; // default 1750
    // Number of enums to generate
    public static var enumCount : Int; // default 200
    // Number of anonymous classes to generate
    public static var anonymousClassCount : Int; // default 15
    // Maximum class/interface hierarchy depth
    public static var maxExtendsDepth : Int; // default 10

    public static var usageString = "Usage: ";

    /**
     * This method parses the command line options, storing the parsed values
     * in the properties above, and returning true on a successful parse,
     * false on failure.
     *
     * @return true on success, false on failure
     **/
    public static function load() : Bool
    {
        // Initialize defaults
        help = false;
        randomSeed = Std.int((haxe.Timer.stamp() * 1000) % (0xFFFFFFF));
        outdir = "gen.out";
        classCount = 3000;
        interfaceCount = 1750;
        enumCount = 200;
        anonymousClassCount = 15;
        maxExtendsDepth = 10;

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
                case "-rs", "-randomSeed":
                    randomSeed = getIntArgument(argv, i, iter);
                case "-cc", "-classCount":
                    classCount = getIntArgument(argv, i, iter);
                case "-ic", "-interfaceCount":
                    interfaceCount = getIntArgument(argv, i, iter);
                case "-ec", "-enumCount":
                    enumCount = getIntArgument(argv, i, iter);
                case "-ac", "-anonymousClassCount":
                    anonymousClassCount = getIntArgument(argv, i, iter);
                case "-me", "-maxExtendsDepth":
                    maxExtendsDepth = getIntArgument(argv, i, iter);
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

        if (anonymousClassCount < 0) {
            Util.err("anonymousClassCount must be positive");
        }

        if (maxExtendsDepth < 0) {
            Util.err("maxExtendsDepth must be positive");
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
