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

class GenEnumElement
{
    public var name : String;
    public var parameters : Null<Array<{ name : String, type : GenType }>>;

    public function new(simple : Bool, enumName : String, index : Int)
    {
        this.name = enumName + "_Val" + index;
        if (simple || Random.chance(50)) {
            this.parameters = null;
        }
        else {
            this.parameters = [ ];
            var n = (Random.random() % 6) + 1;
            var i = 0;
            while (i < n) {
                var type = Util.randomType();
                if (type == GenTypeDynamic) {
                    type = GenTypeInt;
                }
                parameters.push({ name : "param" + i, type : type });
                i += 1;
            }
        }
    }

    public function emit(out : haxe.io.Output)
    {
        out.writeString("    " + this.name);
        if (this.parameters == null) {
            out.writeString(";\n");
        }
        else {
            out.writeString("(");
            var i = 0;
            while (i < this.parameters.length) {
                if (i > 0) {
                    out.writeString(", ");
                }
                var p = this.parameters[i++];
                out.writeString(p.name + " : " + Util.typeString(p.type));
            }
            out.writeString(");\n");
        }
    }
}
