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
        return randomTypeOfDepth(2, true);
    }

    public static inline function typesEqual(gt1 : GenType,
                                             gt2 : GenType) : Bool
    {
        return std.Type.enumEq(gt1, gt2);
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
            return ConstantNull;
        case GenTypeBool:
            return ConstantBool(Random.chance(50));
        case GenTypeInt:
            return ConstantInt((Random.chance(50) ? 1 : -1) *
                               (Random.random() % 2147483647));
        case GenTypeFloat:
            return ConstantFloat(((Random.chance(50) ? 1.0 : -1.0) *
                                  Random.random()) / Random.random());
        case GenTypeString:
            return ConstantString(Random.identifier(false));
        case GenTypeInterface(ifc):
            return ConstantNull;
        case GenTypeClass(cls):
            return ConstantNull;
        case GenTypeEnum(enm):
            return ConstantNull;
        case GenTypeClosure(args, returns):
            return ConstantNull;
        case GenTypeArray(t):
            return ConstantNull;
        case GenTypeMap(k, v):
            return ConstantNull;
        case GenTypeAnonymous(names, types):
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

    // Static variable tracking
    public static function addStatic(gc : GenClass, field : GenField)
    {
        // Hash type to array of statics of that type
        var typeString = typeString(field.type);
        var arr = gStatics.get(typeString);
        if (arr == null) {
            arr = [ ];
            gStatics.set(typeString, arr);
            gStaticsArray.push(arr);
        }
        arr.push({ gc : gc, field : field });
    }

    // Get a random static of the given type, if one exists
    public static function randomStatic(type : Null<GenType>)
        : Null<{ gc : GenClass, field : GenField }>
    {
        if (type == null) {
            if (gStaticsArray.length == 0) {
                return null;
            }
            var arr = gStaticsArray[Random.random() % gStaticsArray.length];
            return arr[Random.random() % arr.length];
        }
        else {
            var arr = gStatics.get(typeString(type));
            if (arr == null) {
                return null;
            }
            return arr[Random.random() % arr.length];
        }
    }

    // Static function tracking
    public static function addStaticFunction(f : GenFunction)
    {
        if (f.returns == null) {
            gStaticFunctionsNoReturn.push(f);
        }
        else {
            var typeString = typeString(f.returns);
            var arr = gStaticFunctions.get(typeString);
            if (arr == null) {
                arr = [ ];
                gStaticFunctions.set(typeString, arr);
            }
            arr.push(f);
        }
    }

    public static function randomStaticFunction(returnType : Null<GenType>)
        : Null<GenFunction>
    {
        if (returnType == null) {
            if (gStaticFunctionsNoReturn.length == 0) {
                return null;
            }
            return gStaticFunctionsNoReturn
                [Random.random() % gStaticFunctionsNoReturn.length];
        }
        else {
            var arr = gStaticFunctions.get(typeString(returnType));
            if (arr == null) {
                return null;
            }
            return arr[Random.random() % arr.length];
        }
    }

    private static function randomTypeOfDepth(depth : Int,
                                              allowDynamic : Bool) : GenType
    {
        if (depth == 0) {
            switch (Random.random() % 5) {
            case 0:
                return allowDynamic ? GenTypeDynamic : GenTypeInt;
            case 1:
                return GenTypeBool;
            case 2:
                return GenTypeInt;
            case 3:
                return GenTypeFloat;
            default:
                return GenTypeString;
            }
        }

        while (true) {
            switch (Random.random() % 12) {
            case 0:
                return allowDynamic ? GenTypeDynamic : GenTypeInt;
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
                var args = new Array<GenType>();
                var n = Random.random() % 6;
                while (n > 0) {
                    n -= 1;
                    args.push(randomTypeOfDepth(depth - 1, false));
                }
                var ret = (Random.chance(50) ?
                           randomTypeOfDepth(depth - 1, false) : null);
                return GenTypeClosure(args, ret);
            case 9:
                return GenTypeArray(randomTypeOfDepth(depth - 1, false));
            case 10:
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
                return GenTypeMap(keyType, randomTypeOfDepth(depth - 1, false));
            case 11:
                var names = new Array<String>();
                var types = new Array<GenType>();
                var n = (Random.random() % 6) + 1;
                var i = 0;
                while (i < n) {
                    names.push("elem" + i);
                    types.push(randomTypeOfDepth(depth - 1, false));
                    i += 1;
                }
                return GenTypeAnonymous(names, types);
            }
        }
    }

    private static var gIndents : Array<String> = [ "" ];
    private static var gStatics = new
        haxe.ds.StringMap<Array<{ gc : GenClass, field : GenField }>>();
    private static var gStaticsArray = new Array<Array<{ gc : GenClass,
                                                         field : GenField }>>();
    private static var gStaticFunctionsNoReturn = new Array<GenFunction>();
    private static var gStaticFunctions =
        new haxe.ds.StringMap<Array<GenFunction>>();
}
