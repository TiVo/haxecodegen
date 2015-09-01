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
 * Represents a single generated enum
 **/
class GenEnum
{
    public var _package(default, null) : String;
    public var name(default, null) : String;
    public var fullname(default, null) : String;
    public var elements(default, null) : Array<GenEnumElement>;

    public static function generate()
    {
        for (i in 0 ... Options.enumCount) {
            var ge = new GenEnum(i);
            gEnums.push(ge);
            gEnumMap.set(ge.name, ge);
        }
    }

    public static inline function randomEnum() : GenEnum
    {
        if (gEnums.length == 0) {
            return null;
        }
        else if (gEnums.length == 1) {
            return gEnums[0];
        }
        else {
            return gEnums[Random.random() % gEnums.length];
        }
    }

    public static function createElements()
    {
        for (genenum in gEnums) {
            genenum.createThisElements();
        }
    }

    public static function emit()
    {
        for (genenum in gEnums) {
            genenum.emitThis();
        }
    }

    private function new(number : Int)
    {
        this._package = GenPackage.get();
        this.name = "Enum" + number;
        this.fullname = this._package + "." + this.name;
        this.elements = [ ];
    }

    private function createThisElements()
    {
        // 40% chance of being just a simple enum
        var simple = Random.chance(40);
        var num = (Random.random() % 20) + 1;
        var i = 0;
        while (i < num) {
            this.elements.push(new GenEnumElement(simple, this.name, i++));
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
        out("enum " + this.name);
        out("\n{\n");
        
        for (e in this.elements) {
            e.emit(mOut);
        }

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

    private static var gEnums : Array<GenEnum> = new Array<GenEnum>();

    private static var gEnumMap : haxe.ds.StringMap<GenEnum> = 
        new haxe.ds.StringMap<GenEnum>();
}
