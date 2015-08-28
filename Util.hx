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

    public static function randomType() : GenType
    {
        return randomSpecificType(true, 2, true, true);
    }

    public static function typeString(gt : GenType) : String
    {
        switch (gt) {
        case GenTypeDynamic:
            return "Dynamic";
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
        case GenTypeEnum(enm):
            return enm.fullname;
        case GenTypeClosure(args, returns):
            var ret = "(";
            if (args.length == 0) {
                ret += "Void -> ";
            }
            else {
                var i = 0;
                while (i < args.length) {
                    ret += typeString(args[i++]) + " -> ";
                }
            }
            if (returns == null) {
                ret += "Void";
            }
            else {
                ret += typeString(returns);
            }
            return ret + ")";
        case GenTypeArray(t):
            return "Array<" + typeString(t) + ">";
        case GenTypeMap(k, v):
            // hxcpp is currently buggy and the abstract Map type doesn't work
            // well.  Use specific maps.
            switch (k) {
            case GenTypeInt:
                return "haxe.ds.IntMap<" + typeString(v) + ">";
            case GenTypeString:
                return "haxe.ds.StringMap<" + typeString(v) + ">";
            default:
                return ("haxe.ds.ObjectMap<" + typeString(k) + ", " + 
                        typeString(v) + ">");
            }
        case GenTypeAnonymous(names, types):
            var ret = "{ ";
            var i = 0;
            while (i < names.length) {
                if (i > 0) {
                    ret += ", ";
                }
                var name = names[i];
                var type = types[i++];
                ret += name + " : " + typeString(type);
            }
            return ret + " }";
        }
    }

    public static function randomConstant(gt : GenType) : Constant
    {
        switch (gt) {
        case GenTypeDynamic:
            // For now ...
            return ConstantNull;
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
        case GenTypeEnum(enm):
            // For now ...
            return ConstantNull;
        case GenTypeClosure(args, returns):
            // For now ...
            return ConstantNull;
        case GenTypeArray(t):
            // For now
            return ConstantNull;
        case GenTypeMap(k, v):
            // For now
            return ConstantNull;
        case GenTypeAnonymous(names, types):
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

    private static function randomSpecificType(allowClosure : Bool,
                                               arrayDepth : Int,
                                               allowMap : Bool,
                                               allowAnonymous : Bool) : GenType
    {
        while (true) {
            var which = Random.random() % 12;
            switch (which) {
            case 0:
                return GenTypeDynamic;
            case 1:
                return GenTypeBool;
            case 2:
                return GenTypeInt;
            case 3:
                return GenTypeFloat;
            case 4:
                return GenTypeString;
            case 5:
                var ifc = GenInterface.randomInterface();
                if (ifc != null) {
                    return GenTypeInterface(ifc);
                }
            case 6:
                return GenTypeClass(GenClass.randomClass());
            case 7:
                var enm = GenEnum.randomEnum();
                if (enm != null) {
                    return GenTypeEnum(enm);
                }
            case 8:
                if (allowClosure) {
                    var args = new Array<GenType>();
                    var n = Random.random() % 6;
                    while (n > 0) {
                        n -= 1;
                        args.push(randomSpecificType(false, 1, false, false));
                    }
                    return GenTypeClosure
                        (args, Random.chance(50) ? 
                         randomSpecificType(false, 1, false, false) : null);
                }
            case 9:
                if (arrayDepth > 0) {
                    return GenTypeArray(randomSpecificType
                                        (true, arrayDepth - 1, true, true));
                }
            case 10:
                if (allowMap) {
                    // Only allow integer, string, class, and interface keys
                    var keyType = 
                        switch (Random.random() % 4) {
                        case 0:
                            GenTypeInt;
                        case 1:
                            GenTypeString;
                        case 2:
                            GenTypeClass(GenClass.randomClass());
                        default:
                            GenTypeInterface(GenInterface.randomInterface());
                        };
                    return GenTypeMap
                        (keyType, randomSpecificType(true, 2, false, true));
                }
            case 11:
                if (allowAnonymous) {
                    var names = new Array<String>();
                    var types = new Array<GenType>();
                    var n = (Random.random() % 6) + 1;
                    var i = 0;
                    while (i < n) {
                        names.push("elem" + i);
                        types.push(randomSpecificType(true, 1, true, false));
                        i += 1;
                    }
                    return GenTypeAnonymous(names, types);
                }
            }
        }
    }

    private static var gIndents : Array<String> = [ "" ];
}
