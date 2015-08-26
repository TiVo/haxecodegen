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
    public static var gInterfaces : Array<GenInterface> =
        new Array<GenInterface>();

    public var _package(default, null) : String;
    public var name(default, null) : String;
    public var fullname(default, null) : String;
    public var _extends(default, null) : Array<GenInterface>;
    public var depth(default, null) : Int;

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

    public static inline function randomInterface() : GenInterface
    {
        if (gInterfaces.length == 0) {
            return null;
        }
        return gInterfaces[Random.random() % gInterfaces.length];
    }

    private function new(number : Int)
    {
        this._package = GenPackage.get();
        this.name = "Interface" + number;
        this.fullname = this._package + "." + this.name;
        this._extends = new Array<GenInterface>();
        this.depth = 0;
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
            if (toExtend.depth >= (Options.maxExtendsDepth - 1)) {
                continue;
            }
            this._extends.push(toExtend);
            this.depth = toExtend.depth + 1;
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

        mOut.writeString("package " + this._package + ";\n\n");
        mOut.writeString("interface " + this.name);
        for (extended in this._extends) {
            mOut.writeString(" extends " + extended.fullname);
        }

        mOut.writeString("\n{\n");

        mOut.writeString("}\n");

        mOut.close();
        mOut = null;
    }

    private var mOut : haxe.io.Output;
}
