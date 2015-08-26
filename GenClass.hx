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
 * Represents a single generated class
 **/
class GenClass
{
    public static var gClasses : Array<GenClass> = new Array<GenClass>();

    public var _package(default, null) : String;
    public var name(default, null) : String;
    public var fullname(default, null) : String;
    public var _super(default, null) : Null<GenClass>;
    public var _implements(default, null) : Array<GenInterface>;
    public var depth(default, null) : Int;

    // Create the classes, with no inheritence hierarchy or other features
    public static function generate()
    {
        for (i in 0 ... Options.classCount) {
            var gc = new GenClass(i);
            gClasses.push(gc);
            gClassMap.set(gc.name, gc);
        }
    }

    public static function byName(name : String)
    {
        return gClassMap.get(name);
    }

    // Define inheritence hierarchy for every class
    public static function createHierarchy()
    {
        if (gClasses.length < 2) {
            return;
        }
        
        for (genclass in gClasses) {
            // 80% chance of inheriting from an existing class
            if (Random.chance(80)) {
                genclass.extendRandom();
            }
            // 20% change of implementing an existing interface
            if (Random.chance(20)) {
                // Implement one
                genclass.implementRandom();
                // Now two more 25% chances to implement others
                if (Random.chance(25)) {
                    genclass.implementRandom();
                }
                if (Random.chance(25)) {
                    genclass.implementRandom();
                }
            }
        }
    }

    public static function emit()
    {
        for (genclass in gClasses) {
            genclass.emitThis();
        }
    }

    public function isOrExtendsClass(c : GenClass) : Bool
    {
        while (true) {
            if (c == null) {
                return false;
            }
            if (c == this) {
                return true;
            }
            c = c._super;
        }
    }

    public function implementsInterface(i : GenInterface) : Bool
    {
        for (implemented in this._implements) {
            if (implemented.isOrExtendsInterface(i)) {
                return true;
            }
        }
        return false;
    }

    public static inline function randomClass() : GenClass
    {
        if (gClasses.length == 0) {
            return null;
        }
        return gClasses[Random.random() % gClasses.length];
    }

    private function new(number : Int)
    {
        if (number == 0) {
            this._package = "";
            this.name = "Main";
            this.fullname = this.name;
        }
        else {
            this._package = GenPackage.get();
            this.name = "Class" + number;
            this.fullname = this._package + "." + this.name;
        }
        this._super = null;
        this.depth = 0;
        this._implements = new Array<GenInterface>();
    }

    // Will fail to extend if it happens to hit this class or a class extending
    // this class
    private function extendRandom()
    {
        var toExtend;
        while (true) {
            toExtend = randomClass();
            if (toExtend == null) {
                return;
            }
            if (toExtend.depth >= (Options.maxExtendsDepth - 1)) {
                continue;
            }
            if (!toExtend.isOrExtendsClass(this)) {
                this._super = toExtend;
                this.depth = toExtend.depth + 1;
            }
            break;
        }
    }

    // Will fail to implement if it happens to hit an already implemented
    // interface
    private function implementRandom()
    {
        var toImplement;
        while (true) {
            toImplement = GenInterface.randomInterface();
            if (toImplement == null) {
                return;
            }
            for (implemented in this._implements) {
                if (implemented == toImplement) {
                    return;
                }
            }
            if (toImplement.depth >= (Options.maxExtendsDepth - 1)) {
                continue;
            }
            this._implements.push(toImplement);
            break;
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

        if (this._package.length > 0) {
            out("package " + this._package + ";\n\n");
        }
        out("class " + this.name);
        if (this._super != null) {
            outi(1, "extends " + this._super.fullname);
        }
        for (implemented in this._implements) {
            outi(1, "implements " + implemented.fullname);
        }

        out("\n{\n");

        // If this is Main, then emit a main function
        if (this.name == "Main") {
            outi(4, "public static function main()\n");
            outi(4, "{\n");
            // Temporary - make an array of every class
            outi(8, "var allClasses : Array<Dynamic> = [ ");
            var needComma = false;
            for (gc in gClasses) {
                if (needComma) {
                    out(", ");
                }
                needComma = true;
                out("new " + gc.fullname + "()");
            }
            out("\n");
            outi(8, "];\n");
            outi(4, "}\n");
        }

        // Temporary - emit empty constructor, which every class has
        out("\n");
        outi(4, "public function new()\n");
        outi(4, "{\n");
        if (this._super != null) {
            outi(8, "super();\n");
        }
        outi(4, "}\n");

        out("}\n");

        mOut.close();
        mOut = null;
    }

    private inline function out(str : String)
    {
        mOut.writeString(str);
    }

    private function outi(indent : Int, str : String)
    {
        Util.indent(mOut, indent);
        this.out(str);
    }

    private var mOut : haxe.io.Output;

    private static var gClassMap : haxe.ds.StringMap<GenClass> = 
        new haxe.ds.StringMap<GenClass>();

}

