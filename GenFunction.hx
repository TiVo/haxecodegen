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
class GenFunction
{
    public var name(default, null) : String;
    public var args(default, null) : Array<{ name : String, type : GenType }>;
    public var returns(default, null) : Null<GenType>;
    public var body(default, null) : Null<Array<GenStatement>>;

    public function new()
    {
    }

    public function randomSignature() : GenFunction
    {
        this.name = "func" + gNextNumber++;
        this.args = [ ];
        var argnum = 0;
        while (Random.chance(50)) {
            this.args.push({ name : "arg" + argnum++,
                        type : Util.randomType() });
        }
        if (Random.chance(50)) {
            this.returns = Util.randomType();
        }
        else {
            this.returns = null;
        }
        this.body = null;
        return this;
    }

    public function copySignature(func : GenFunction) : GenFunction
    {
        this.name = func.name;
        this.args = func.args.copy();
        this.returns = func.returns;
        this.body = null;
        return this;
    }

    public function makeBody()
    {
        this.body = [ ];
    }

    public function emit(o : haxe.io.Output)
    {
        mOut = o;

        outi(4, "public function " + this.name + "(");
        var i = 0;
        while (i < this.args.length) {
            if (i > 0) {
                out(", ");
            }
            var a = this.args[i++];
            out(a.name + " : " + Util.typeString(a.type));
        }
        out(")");

#if 0
        if (this.returns != null) {
#else
        if (false) {
#end

            out(" : " + Util.typeString(this.returns));
        }
        else {
            out(" : Void");
        }
        
        if (this.body != null) {
            out("\n");
            outi(4, "{\n");
            outi(4, "}\n\n");
        }
        else {
            out(";\n\n");
        }

        mOut = null;
    }

    private function randomize()
    {
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
