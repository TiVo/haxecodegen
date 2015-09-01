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
    public var _package(default, null) : String;
    public var name(default, null) : String;
    public var fullname(default, null) : String;
    public var _super(default, null) : Null<GenClass>;
    public var _implements(default, null) : Array<GenInterface>;
    public var depth(default, null) : Int;
    public var functions(default, null) : Array<GenFunction>;
    public var fields(default, null) : Array<GenField>;

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
        // Can't have any hierarchy if there aren't at least 2 classes to
        // participate
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

    public static function createFunctions()
    {
        for (genclass in gClasses) {
            genclass.createThisFunctions();
        }
    }

    public static function createFields()
    {
        for (genclass in gClasses) {
            genclass.createThisFields();
        }
    }

    public static function fillFunctions()
    {
        for (genclass in gClasses) {
            genclass.fillThisFunctions();
        }
    }

    public static function collectRelationships()
    {
        for (genclass in gClasses) {
            genclass.collectThisRelationships();
        }
    }

    public function isOrExtendsClass(c : GenClass) : Bool
    {
        var t = this;

        while (true) {
            if (t == null) {
                return false;
            }
            if (c == t) {
                return true;
            }
            t = t._super;
        }
    }

    public function implementsInterface(i : GenInterface) : Bool
    {
        for (implemented in this._implements) {
            if (implemented.isOrExtendsInterface(i)) {
                return true;
            }
        }
        if (this._super == null) {
            return false;
        }
        return this._super.implementsInterface(i);
    }

    public function findFunction(name : String) : Null<GenFunction>
    {
        var found = mFunctionMap.get(name);

        if (found != null) {
            return found;
        }

        if (this._super == null) {
            return null;
        }

        return this._super.findFunction(name);
    }

    public static inline function randomClass() : GenClass
    {
        if (gClasses.length == 0) {
            return null;
        }
        else if (gClasses.length == 1) {
            return gClasses[0];
        }
        else {
            return gClasses[Random.random() % gClasses.length];
        }
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

    public static function emit()
    {
        for (genclass in gClasses) {
            genclass.emitThis();
        }
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
        this._implements = new Array<GenInterface>();
        this.depth = 0;
        this.functions = [ ];
        this.fields = [ ];
        mFunctionMap = new haxe.ds.StringMap<GenFunction>();
    }

    // Will fail to extend if it happens to hit this class or a class extending
    // this class or one that can't be extended
    private function extendRandom()
    {
        var toExtend;
        while (true) {
            toExtend = randomClass();
            if (toExtend == null) {
                return;
            }
            if (toExtend.depth >= (Options.maxExtendsDepth - 1)) {
                return;
            }
            if (!toExtend.isOrExtendsClass(this)) {
                this._super = toExtend;
                this.depth = toExtend.depth + 1;
            }
            break;
        }
    }

    // Will fail to implement if it happens to hit an already implemented
    // interface or one that can't be extended
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
            if (toImplement.maxdepth >= (Options.maxExtendsDepth - 1)) {
                return;
            }
            this._implements.push(toImplement);
            break;
        }
    }

    private function createThisFunctions()
    {
        // First, create any functions that need to be implemented from
        // implemented interfaces
        for (i in this._implements) {
            this.createThisInterfaceFunctions(i);
        }

        // Now create some additional number of class-specific functions.
        // Some should override functions in parent classes
        var pct = 95;
        while (true) {
            if (!Random.chance(pct)) {
                break;
            }
            pct = Std.int((pct * 9) / 10);
            // Create a function.  33% chance of re-declaring one of its
            // functions.
            if ((this.depth > 0) && Random.chance(33)) {
                // Pick a random superclass reimplement a function from
                var w = (Random.random() % this.depth) + 1;
                var c = this;
                while (w > 0) {
                    c = c._super;
                    w -= 1;
                }
                // Now pick a random function from ifc to redeclare, if it has
                // any (otherwise give up)
                var toRedeclare = c.randomFunction();
                if ((toRedeclare != null) && !toRedeclare._inline &&
                    !mFunctionMap.exists(toRedeclare.name)) {
                    // Redeclare it in this class
                    var newf = new GenFunction().copySignature(toRedeclare);
                    newf.makeBody(this);
                    this.functions.push(newf);
                    mFunctionMap.set(newf.name, newf);
                    // Continue the outer while loop
                    continue;
                }
            }
            
            // Generate a new function
            var newf = new GenFunction().randomSignature(this);
            this.functions.push(newf);
            mFunctionMap.set(newf.name, newf);
        }
    }

    private function createThisInterfaceFunctions(i : GenInterface)
    {
        for (isuper in i._extends) {
            this.createThisInterfaceFunctions(isuper);
        }

        for (f in i.functions) {
            if (mFunctionMap.exists(f.name)) {
                continue;
            }
            var thisf = new GenFunction().copySignature(f);
            this.functions.push(thisf);
            mFunctionMap.set(thisf.name, thisf);
        }
    }

    private function createThisFields()
    {
        var pct = 95;
        while (Random.chance(pct)) {
            pct = Std.int((pct * 9) / 10);
            this.fields.push(new GenField(this, false));
        }
    }

    private function fillThisFunctions()
    {
        for (f in this.functions) {
            f.makeBody(this);
        }
    }

    private function collectThisRelationships()
    {
        this.collectImplementedBy(this._implements);
    }

    private function collectImplementedBy(ifcs : Array<GenInterface>)
    {
        var i = 0;
        while (i < ifcs.length) {
            ifcs[i].implementedBy(this);
            collectImplementedBy(ifcs[i]._extends);
            i += 1;
        }
    }

    private function emitThis()
    {
        var path = (Options.outdir + "/" + this._package + "/" +
                    this.name + ".hx");

        try {
            mOut = sys.io.File.write(path);
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

        // Collect properties to implement
        var props = new Array<GenField>();
        this.collectPropertiesToImplement(this._implements, props);

        // Now emit all interface property definitions as needed
        for (p in props) {
            p.emit(mOut);
        }

        if (props.length > 0) {
            out("\n");
        }

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
            outi(4, "}\n\n");
        }

        // Temporary - emit empty constructor, which every class has
        outi(4, "public function new()\n");
        outi(4, "{\n");
        if (this._super != null) {
            outi(8, "super();\n");
        }
        outi(4, "}\n");

        for (f in this.functions) {
            out("\n");
            // If the function is nonstatic and in a super class, then emit
            // "override " as a prefix to the function
            if (!f._static &&
                (this._super != null) && 
                (this._super.findFunction(f.name) != null)) {
                out("    override");
            }
            f.emit(mOut);
        }

        if (this.fields.length > 0) {
            out("\n");
        }

        for (f in this.fields) {
            f.emit(mOut);
        }

        // Now emit all property functions as needed
        for (p in props) {
            p.emitAccessorFunctions(mOut);
        }
        for (f in this.fields) {
            if (f.accessor != null) {
                f.emitAccessorFunctions(mOut);
            }
        }

        out("}\n");

        mOut.close();
        mOut = null;
    }

    private function collectPropertiesToImplement
        (implemented : Array<GenInterface>, out : Array<GenField>)
    {
        for (i in implemented) {
            // If there is not a superclass implementing this interface, then
            // emit its properties
            if ((this._super == null) ||
                !this._super.implementsInterface(i)) {
                for (p in i.properties) {
                    out.push(p);
                }
            }
            this.collectPropertiesToImplement(i._extends, out);
        }
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

    private var mFunctionMap : haxe.ds.StringMap<GenFunction>;

    private static var gClasses : Array<GenClass> = new Array<GenClass>();

    private static var gClassMap : haxe.ds.StringMap<GenClass> = 
        new haxe.ds.StringMap<GenClass>();
}

