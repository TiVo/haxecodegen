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
    public var statementCount : Int;
    public var nextVarNumber : Int;
    public var expressionDepth : Int;
    public var noSearch : Bool;
    public var enumDepth : Int;
    public var captures : Array<Array<{ name : String, type : GenType,
                                        r : Bool, w : Bool }>>;

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
        this.nextVarNumber = 0;
        this.expressionDepth = 0;
        this.noSearch = false;
        this.enumDepth = 0;
        this.captures = [ ];
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
        : Null<{ name : String, type : GenType, r : Bool, w : Bool }>
    {
        var i = this.captures.length;
        while (i-- > 0) {
            var captures = this.captures[i];
            var idx = ((captures.length == 0) ?
                       0 : (Random.random() % captures.length));
            var j = idx;
            do {
                j = j + 1;
                if (j == captures.length) {
                    j = 0;
                }
                var v = captures[j];
                if ((gt == null) || Util.typesEqual(v.type, gt)) {
                    return v;
                }
            } while (j != idx);
        }
        if (this.variables.length == 0) {
            return null;
        }
        var index = ((this.variables.length == 0) ?
                     0 : (Random.random() % this.variables.length));
        var i = index;
        do {
            i = i + 1;
            if (i == this.variables.length) {
                i = 0;
            }
            var v = this.variables[i];
            if (r && !v.r) {
                continue;
            }
            if (w && !v.w) {
                continue;
            }
            if ((gt == null) || Util.typesEqual(v.type, gt)) {
                return v;
            }
        } while (i != index);
        return null;
    }
}
