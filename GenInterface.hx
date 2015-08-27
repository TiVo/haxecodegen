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
 * Represents a single generated interface
 **/
class GenInterface
{
    public var _package(default, null) : String;
    public var name(default, null) : String;
    public var fullname(default, null) : String;
    public var _extends(default, null) : Array<GenInterface>;
    public var maxdepth(default, null) : Int;
    public var functions(default, null) : Array<GenFunction>;

    public static function generate()
    {
        for (i in 0 ... Options.interfaceCount) {
            gInterfaces.push(new GenInterface(i));
        }
    }

    // Define inheritence hierarchy for every interface
    public static function createHierarchy()
    {
        if (gInterfaces.length < 2) {
            return;
        }
        
        for (geninterface in gInterfaces) {
            // 30% chance of inheriting from an existing class
            if (!Random.chance(30)) {
                continue;
            }
            // Extend one
            geninterface.extendRandom();
            // Now two more 25% chances to extend others
            if (Random.chance(25)) {
                geninterface.extendRandom();
            }
            if (Random.chance(25)) {
                geninterface.extendRandom();
            }
        }
    }

    // Define functions in the interface
    public static function createFunctions()
    {
        for (geninterface in gInterfaces) {
            geninterface.createThisFunctions();
        }
    }

    public static function emit()
    {
        for (geninterface in gInterfaces) {
            geninterface.emitThis();
        }
    }

    public function isOrExtendsInterface(i : GenInterface) : Bool
    {
        if (i == this) {
            return true;
        }
        for (extended in this._extends) {
            if (i.isOrExtendsInterface(extended)) {
                return true;
            }
        }
        return false;
    }

    public static inline function randomInterface() : Null<GenInterface>
    {
        if (gInterfaces.length == 0) {
            return null;
        }
        else if (gInterfaces.length == 1) {
            return gInterfaces[0];
        }
        else {
            return gInterfaces[Random.random() % gInterfaces.length];
        }
    }

    // Random interface implemented by this interface, or null if there
    // are no interfaces implemented by this interface
    public function randomImplementedInterface() : Null<GenInterface>
    {
        if (this.maxdepth == 0) {
            return null;
        }

        // Get a depth that can be used in this interface
        var d = (Random.random() % this.maxdepth) + 1;
        var c = this;
        while (d > 0) {
            // Pick one of the interfaces to get an implemented interface from
            c = c._extends[Random.random() % c._extends.length];
            if (c.maxdepth > 0) {
                d = (d - 1) % c.maxdepth;
            }
            else {
                d = 0;
            }
        }

        return c;
    }

    public function randomFunction() : Null<GenFunction>
    {
        if (this.functions.length == 0) {
            return null;
        }
        else if (this.functions.length == 1) {
            return this.functions[0];
        }
        else {
            return this.functions[Random.random() % this.functions.length];
        }
    }

    private function new(number : Int)
    {
        this._package = GenPackage.get();
        this.name = "Interface" + number;
        this.fullname = this._package + "." + this.name;
        this._extends = [ ];
        this.maxdepth = 0;
        this.functions = [ ];
        mFunctionMap = new haxe.ds.StringMap<GenFunction>();
    }

    // May fail to extend if it happens to hit something already extended
    private function extendRandom()
    {
        var toExtend;
        while (true) {
            toExtend = randomInterface();
            if (toExtend == null) {
                return;
            }
            if (toExtend.isOrExtendsInterface(this)) {
                return;
            }
            if (toExtend.maxdepth >= (Options.maxExtendsDepth - 1)) {
                continue;
            }
            this._extends.push(toExtend);
            if (toExtend.maxdepth >= this.maxdepth) {
                this.maxdepth = toExtend.maxdepth + 1;
            }
            break;
        }
    }

    private function createThisFunctions()
    {
        // Start with a 95% chance of creating a function.  Each time a
        // function is created, reduce the chance by 1/3 and repeat, until
        // a function is not created
        var pct = 95;
        while (true) {
            if (!Random.chance(pct)) {
                break;
            }
            pct = Std.int((pct * 2) / 3);
            // Create a function.  10% chance of re-declaring one of its
            // functions.
            if (Random.chance(10)) {
                // Pick a random interface to reimplement a function from
                var ifc = this.randomImplementedInterface();
                if (ifc != null) {
                    // Now pick a random function from ifc to redeclare, if it
                    // has any (otherwise give up)
                    var toRedeclare = ifc.randomFunction();
                    if ((toRedeclare != null) &&
                        !mFunctionMap.exists(toRedeclare.name)) {
                        // Redeclare it in this interface
                        var newf = new GenFunction().copySignature(toRedeclare);
                        this.functions.push(newf);
                        mFunctionMap.set(newf.name, newf);
                        // Continue the outer while loop
                        continue;
                    }
                }
            }
            
            // Generate a new function
            var newf =new GenFunction().randomSignature(false);
            this.functions.push(newf);
            mFunctionMap.set(newf.name, newf);
        }
    }

    private function emitThis()
    {
        var path = (Options.outdir + "/" + this._package + "/" +
                    this.name + ".hx");

        try {
            this.mOut = sys.io.File.write(path);
        }
        catch (e : Dynamic) {
            Util.err("failed to write output file " + path + ": " + e);
            return;
        }

        mOut.writeString("package " + this._package + ";\n\n");
        mOut.writeString("interface " + this.name);
        for (extended in this._extends) {
            mOut.writeString(" extends " + extended.fullname);
        }

        mOut.writeString("\n{\n");

        for (f in this.functions) {
            f.emit(mOut);
        }

        mOut.writeString("}\n");

        mOut.close();
        mOut = null;
    }

    private var mOut : haxe.io.Output;

    private var mFunctionMap : haxe.ds.StringMap<GenFunction>;

    private static var gInterfaces : Array<GenInterface> =
        new Array<GenInterface>();
}
