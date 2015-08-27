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
 * Randomly generated packages
 **/
class GenPackage
{
    public static function get() : String
    {
        // Create package names if necessary
        if (gPackages == null) {
            gPackages = new Array<String>();
            var i = 0;
            // One package per 10 classes
            while (i++ < (Options.classCount / 10)) {
                var pkg = "pkg" + gNextNum++;
                gPackages.push(pkg);
                try {
                    sys.FileSystem.createDirectory
                        (Options.outdir + "/" + pkg);
                }
                catch (e : Dynamic) {
                    Util.err("Failed to create output directory " +
                             Options.outdir + ": " + e);
                }
            }
        }
        
        return gPackages[Random.random() % gPackages.length];
    }

    private static var gPackages : Array<String> = null;
    private static var gNextNum : Int = 0;
}
