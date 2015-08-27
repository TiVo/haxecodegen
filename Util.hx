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

class Util
{
    public static function err(msg : String)
    {
        Sys.stderr().writeString("ERROR: ");
        Sys.stderr().writeString(msg);
        Sys.stderr().writeString("\n");
    }

    public static function indent(out : haxe.io.Output, i : Int)
    {
        while (gIndents.length <= i) {
            gIndents.push(gIndents[gIndents.length - 1] + " ");
        }

        out.writeString(gIndents[i]);
    }

    public static function randomType(templDepth : Int = 2) : GenType
    {
        var mod = (templDepth > 0) ? 8 : 6;

        switch (Random.random() % mod) {
        case 0:
            return GenTypeBool;
        case 1:
            return GenTypeInt;
        case 2:
            return GenTypeFloat;
        case 3:
            return GenTypeString;
        case 4:
            return GenTypeInterface(GenInterface.randomInterface());
        case 5:
            return GenTypeClass(GenClass.randomClass());
        case 6:
            return GenTypeArray(randomType(templDepth - 1));
        case 7:
            return GenTypeMap(randomType(0), randomType(templDepth - 1));
        }

        throw "Internal error - randomType using wrong number of types";
    }

    public static function typeString(gt : GenType) : String
    {
        switch (gt) {
        case GenTypeBool:
            return "Bool";
        case GenTypeInt:
            return "Int";
        case GenTypeFloat:
            return "Float";
        case GenTypeString:
            return "String";
        case GenTypeInterface(ifc):
            return ifc.fullname;
        case GenTypeClass(cls):
            return cls.fullname;
        case GenTypeArray(t):
            return "Array<" + typeString(t) + ">";
        case GenTypeMap(k, v):
            return "Map<" + typeString(k) + ", " + typeString(v) + ">";
        }
    }

    public static function randomConstant(gt : GenType) : Constant
    {
        switch (gt) {
        case GenTypeBool:
            return ConstantBool(Random.chance(50));
        case GenTypeInt:
            return ConstantInt(Random.random());
        case GenTypeFloat:
            return ConstantFloat(((Random.chance(50) ? 1.0 : -1.0) *
                                  Random.random()) / Random.random());
        case GenTypeString:
            return ConstantString(Random.identifier(false));
        case GenTypeInterface(ifc):
            // For now ...
            return ConstantNull;
        case GenTypeClass(cls):
            // For now ...
            return ConstantNull;
        case GenTypeArray(t):
            // For now
            return ConstantNull;
        case GenTypeMap(k, v):
            // For now
            return ConstantNull;
        }
    }

    public static function constantToString(c : Constant) : String
    {
        switch (c) {
        case ConstantNull:
            return "null";
        case ConstantBool(b):
            return Std.string(b);
        case ConstantInt(i):
            return Std.string(i);
        case ConstantFloat(f):
            return Std.string(f);
        case ConstantString(s):
            return "\"" + s + "\"";
        }
    }

    public static function randomAccessor() : Accessor
    {
        switch (Random.random() % 3) {
        case 0:
            return GetSet;
        case 1:
            return GetNull;
        case 2: 
            return NullSet;
        }

        throw "Internal error - randomAccessor uses wrong mod";
    }

    private static var gIndents : Array<String> = [ "" ];
}
