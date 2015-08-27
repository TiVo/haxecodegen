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

    public function new()
    {
        this.name = "field" + gNextNumber++;
        this._static = Random.chance(10);
        this.type = Util.randomType();
    }

    public function emit(o : haxe.io.Output)
    {
        mOut = o;

        outi(4, "public " + (this._static ? "static " : "") + "var " +
             this.name + " : " + Util.typeString(this.type) + ";\n");

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
