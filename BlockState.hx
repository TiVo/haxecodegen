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

// Represents the state associated with the generated statements in a function
// block
class BlockState
{
    // variables is an array of variables available in the current context
    // along with their types
    public var variables : Array<{ name : String, type : GenType,
                                   r : Bool, w : Bool}>;
    // functions that can be called
    public var functions : Array<GenFunction>;
    public var depth : Int;
    public var returnType : Null<GenType>;
    public var nextLocalNumber : Int;
    // Prevents function call loops
    public var allowFunctionCall : Bool;
    public var inStaticFunction : Bool;

    public function new(gc : GenClass, gf : GenFunction)
    {
        this.variables = [ ];
        for (f in gc.fields) {
            if (!gf._static || (gf._static && f._static)) {
                this.variables.push({ name : f.name, type : f.type,
                                      r : f.isReadable(),
                                      w : f.isWriteable() });
            }
        }
        for (a in gf.args) {
            this.variables.push({ name : a.name, type : a.type,
                                  r : true, w : true });
        }
        this.functions = [ ];
        for (f in gc.functions) {
            if (!gf._static || (gf._static && f._static)) {
                this.functions.push(f);
            }
        }
        this.depth = 0;
        this.returnType = gf.returns;
        this.nextLocalNumber = 0;
        this.allowFunctionCall = true;
        this.inStaticFunction = gf._static;
    }

    public function randomReadableVariable(gt : Null<GenType>)
        : Null<{ name : String, type : GenType }>
    {
        return this.randomVariable(gt, true, false);
    }

    public function randomWriteableVariable(gt : Null<GenType>)
        : Null<{ name : String, type : GenType }>
    {
        return this.randomVariable(gt, false, true);
    }

    private function randomVariable(gt : Null<GenType>, r : Bool, w : Bool)
        : Null<{ name : String, type : GenType }>
    {
        if (this.variables.length == 0) {
            return null;
        }
        var index = Random.random() % this.variables.length;
        // index to end
        var i = index;
        while (i < this.variables.length) {
            var v = this.variables[i];
            if ((r && v.r) || (w && v.w) &&
                ((gt == null) || Util.typesEqual(v.type, gt))) {
                return v;
            }
            i += 1;
        }
        // end back to index
        i = 0;
        while (i < index) {
            var v = this.variables[i];
            if ((r && v.r) || (w && v.w) &&
                ((gt == null) || Util.typesEqual(v.type, gt))) {
                return v;
            }
            i += 1;
        }
        return null;
    }
}
