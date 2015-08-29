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
 * Represents a single generated function
 **/
class GenField
{
    public var name(default, null) : String;
    public var _static(default, null) : Bool;
    public var type(default, null) : GenType;
    public var accessor(default, null) : Null<Accessor>;

    public function new(gc : GenClass, ofInterface : Bool)
    {
        this.name = "field" + gNextNumber++;
        this._static = ofInterface ? false : Random.chance(10);
        this.type = Util.randomType();
        // Could be a property
        if (ofInterface || Random.chance(10)) {
            this.accessor = Util.randomAccessor();
        }
        else {
            this.accessor = null;
        }
        if (this._static) {
            Util.addStatic(gc, this);
        }
    }

    public function isReadable() : Bool
    {
        return ((this.accessor == null) || (this.accessor == GetSet) ||
                (this.accessor == GetNull));
    }

    public function isWriteable() : Bool
    {
        return ((this.accessor == null) || (this.accessor == GetSet) ||
                (this.accessor == NullSet));
    }

    public function emit(o : haxe.io.Output)
    {
        mOut = o;

        outi(4, "public " + (this._static ? "static " : "") + "var " +
             this.name);

        if (this.accessor != null) {
            out("(");
            switch (this.accessor) {
            case GetSet:
                out("get, set");
            case GetNull:
                out("get, null");
            case NullSet:
                out("null, set");
            }
            out(")");
        }

        out(" : " + Util.typeString(this.type) + ";\n");

        mOut = null;
    }

    public function emitAccessorFunctions(o : haxe.io.Output)
    {
        mOut = o;

        var typeString = Util.typeString(this.type);
        var staticString = this._static ? "static " : "";

        switch (this.accessor) {
        case GetSet, GetNull:
            out("\n");
            outi(4, "private " + staticString + "function get_" + this.name
                 + "() : " + typeString + "\n");
            outi(4, "{\n");
            outi(8, "    return " + 
                 Util.constantToString(Util.randomConstant(this.type)) + ";\n");
            outi(4, "}\n");
        default:
        }

        switch (this.accessor) {
        case GetSet, NullSet:
            out("\n");
            outi(4, "private " + staticString + "function set_" + this.name +
                 "(v : " + typeString + ") : " + typeString + "\n");
            outi(4, "{\n");
            outi(8, "    return v;\n");
            outi(4, "}\n");
        default:
        }            

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

    private static var gNextNumber : Int = 0;
}
