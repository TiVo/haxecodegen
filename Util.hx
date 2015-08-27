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
        switch (Random.random() % 6) {
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
        }
    }

    private static var gIndents : Array<String> = [ "" ];
}
