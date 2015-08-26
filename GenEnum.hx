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
 * Represents a single generated enum
 **/
class GenEnum
{
    public static var gEnums : Array<GenEnum> = new Array<GenEnum>();

    public var _package(default, null) : String;
    public var name(default, null) : String;

    public static function generate()
    {
        for (i in 0 ... Options.enumCount) {
            gEnums.push(new GenEnum(i));
        }
    }

    private function new(number : Int)
    {
        this._package = GenPackage.get();
        this.name = "Enum" + number;
    }
}
