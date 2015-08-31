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
    public var _static(default, null) : Bool;
    public var args(default, null) : Array<{ name : String, type : GenType }>;
    public var returns(default, null) : Null<GenType>;
    public var body(default, null) : Null<Array<GenStatement>>;
    // String to use when calling, includes static class name if necessary
    public var callAs(default, null) : String;

    public function new()
    {
    }

    public function randomSignature(allowStatic : Bool) : GenFunction
    {
        this.name = "func" + gNextNumber++;
        if (allowStatic) {
            this._static = Random.chance(10);
        }
        else {
            this._static = false;
        }
        this.args = [ ];
        var argnum = 0;
        // Start with a 80% chance of an argument, and then reduce chance by
        // 10% each argument, to a maximum of 10 arguments
        var pct = 80;
        while ((this.args.length < 10) && Random.chance(pct)) {
            pct = Std.int((pct * 9) / 10);
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
        this._static = func._static;
        this.args = func.args.copy();
        this.returns = func.returns;
        this.body = null;
        return this;
    }

    // gc is the class containing the function
    public function makeBody(gc : GenClass)
    {
        if (this._static) {
            this.callAs = gc.fullname + "." + this.name;
        }
        else {
            this.callAs = this.name;
        }
        this.body = [ ];
        var bs = new BlockState(gc, this);
        // 2% chance of no statements in block
        if (Random.chance(98)) {
            // 50% chance of 1 - 5 statements
            if (Random.chance(50)) {
                bs.statementCount = (Random.random() % 5) + 1;
            }
            // 40% chance of 6 - 15 statements
            else if (Random.chance(80)) {
                bs.statementCount = (Random.random() % (15 - 6)) + 6;
            }
            // 10% chance of 16 - 80 statements
            else {
                bs.statementCount = (Random.random() % (80 - 16)) + 16;
            }
            while (bs.statementCount > 0) {
                GenStatementHelpers.randomBlock(bs, this.body);
            }
        }
        // Make a default return if necessary, in case the function didn't
        // otherwise return
        if (this.returns != null) {
            this.body.push(Return(Constant(Util.randomConstant(this.returns))));
        }
    }

    public function emit(o : haxe.io.Output)
    {
        mOut = o;

        outi(4, (this._static ? "static " : "") + "public function " +
             this.name + "(");
        var i = 0;
        while (i < this.args.length) {
            if (i > 0) {
                out(", ");
            }
            var a = this.args[i++];
            out(a.name + " : " + Util.typeString(a.type));
        }
        out(")");

        if (this.returns != null) {
            out(" : " + Util.typeString(this.returns));
        }
        else {
            out(" : Void");
        }
        
        if (this.body != null) {
            out("\n");
            outi(4, "{\n");
            for (s in this.body) {
                GenStatementHelpers.emit(s, mOut, 8);
            }
            outi(4, "}\n");
        }
        else {
            out(";\n");
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
