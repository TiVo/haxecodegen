
// Encore:
// - 2782 classes
// - 1603 interfaces
// - 191 enums
// - ~15 anonymous types

class Options
{
    // Set to true if -h, -help, or --help was set
    public static var help : Bool;
    // Number of classes to generate
    public static var classCount : Int; // default 3000
    // Number of interfaces to generate
    public static var interfaceCount : Int; // default 1750
    // Number of enums to generate
    public static var enumCount : Int; // default 200
    // Number of anonymous classes to generate
    public static var anonymousClassCount : Int; // default 15

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
        classCount = 3000;
        interfaceCount = 1750;
        enumCount = 200;
        anonymousClassCount = 15;

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
                case "-cc", "-classCount":
                    classCount = getIntArgument(argv, i, iter);
                case "-ic", "-interfaceCount":
                    interfaceCount = getIntArgument(argv, i, iter);
                case "-ec", "-enumCount":
                    enumCount = getIntArgument(argv, i, iter);
                case "-ac", "-anonymousClassCount":
                    anonymousClassCount = getIntArgument(argv, i, iter);
                default:
                    err("Unknown command-line argument: " + arg + "\n");
                    return false;
                }
            }
        }
        catch (e : Dynamic)
        {
            return false;
        }

        if (classCount <= 0) {
            err("classCount must be greater than 0");
        }
        
        if (interfaceCount < 0) {
            err("interfaceCount must be greater than 0");
        }

        if (enumCount < 0) {
            err("enumCount must be greater than 0");
        }

        if (anonymousClassCount < 0) {
            err("anonymousClassCount must be greater than 0");
        }

        return true;
    }

    private static function getIntArgument(argv : Array<String>, i : Int,
                                           iter : Iterator<Int>) : Int
    {
        if (i == (argv.length - 1)) {
            err(argv[i] + " requires an argument");
            throw false;
        }

        return Std.parseInt(argv[iter.next()]);
    }

    private static function err(msg : String)
    {
        Sys.stderr().writeString("ERROR: ");
        Sys.stderr().writeString(msg);
        Sys.stderr().writeString("\n");
    }
}
