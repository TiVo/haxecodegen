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
    public var variables : Array<{ name : String, type : GenType }>;
    // functions that can be called
    public var functions : Array<GenFunction>;
    public var depth : Int;
    public var returnType : Null<GenType>;
    public var nextLocalNumber : Int;
    // Prevents function call loops
    public var allowFunctionCall : Bool;

    public function new(gc : GenClass, gf : GenFunction)
    {
        this.variables = [ ];
        this.functions = gc.functions;
        for (f in gc.fields) {
            this.variables.push({ name : f.name, type : f.type });
        }
        for (a in gf.args) {
            this.variables.push(a);
        }
        this.depth = 0;
        this.returnType = gf.returns;
        this.nextLocalNumber = 0;
        this.allowFunctionCall = true;
    }

    public function randomVariable(gt : GenType) : Null<{ name : String, 
                                                          type : GenType }>
    {
        if (this.variables.length == 0) {
            return null;
        }
        var index = Random.random() % this.variables.length;
        // index to end
        var i = index;
        while (i < this.variables.length) {
            var v = this.variables[i];
            if (Util.typesEqual(v.type, gt)) {
                return v;
            }
            i += 1;
        }
        // end back to index
        i = 0;
        while (i < index) {
            var v = this.variables[i];
            if (Util.typesEqual(v.type, gt)) {
                return v;
            }
            i += 1;
        }
        return null;
    }
}
