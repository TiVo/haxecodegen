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

class Random
{
    public static function random() : Int
    {
        // What are these values? I don't know -- they were in the sample code
        // from wikipedia.
        var a : Int = 18782;
        var r : Int = 0xfffffffe;
        var t : Int;
        var x : Int;
        
        gRotation = (gRotation + 1) & (RESIDUES - 1);
        t = a * gQ[gRotation] + gC;
        gC = (t >> 32);
        x = t + gC;
        if (x < gC) {
            x++;
            gC++;
        }
        gQ[gRotation] = r - x;

        return (gQ[gRotation] < 0) ? -gQ[gRotation] : gQ[gRotation];
    }
    
    public static function chance(pct : Int) : Bool
    {
        return (random() % 100) < pct;
    }

    // Generates haxe name safe strings that are not haxe keywords
    public static function identifier(capitalize : Bool,
                                      maxlen : Int = 10) : String
    {
        while (true) {
            var buf = new StringBuf();
            
            var i = 0;
            while (i < maxlen) {
                if (i == 0) {
                    // First character must be a letter
                    var index = random() % 26;
                    if (capitalize) {
                        buf.addChar(65 + index); // 65 = 'A'
                    }
                    else {
                        buf.addChar(97 + index); // 97 = 'a'
                    }
                }
                else {
                    var index = random() % (26 + 26 + 10);
                    if (index < 26) {
                        buf.addChar(65 + index); // 65 = 'A'
                    }
                    else if (index < 52) {
                        buf.addChar(71 + index); // 97 + (index - 26)
                    }
                    else {
                        buf.addChar(index - 4); // 48 + (index - 52)
                    }
                }
                i += 1;
            }

            var ret = buf.toString();
            
            if (!gKeywords.exists(ret)) {
                return ret;
            }
        }
    }
    
    public static function seed(seed : Int)
    {
        gC = 362436;

        gQ = new Array<Int>();
        
        gQ.push(seed);
        gQ.push(seed + PHI);
        gQ.push(seed + PHI + PHI);
        
        for (i in 3 ... RESIDUES)
        {
            gQ.push(gQ[i - 3] ^ gQ[i - 2] ^ PHI ^ i);
        }
        
        gRotation = RESIDUES - 1;
    }

    // This is the number of pregenerated starting points that are rotated
    // through
    private static inline var RESIDUES : Int = 4096;

    // I don't know what these next two numbers are. They are from the sample
    // code on Wikipedia. If you want to sort through the formulas there, you
    // can figure it out.
    private static inline var PHI : Int = 0x9e3779b9;

    private static var gC;

    // This is the current index of the pregenerated starting point
    private static var gRotation : Int;
        
    // This is the array of pregenerated starting points.
    private static var gQ : Array<Int>;

    private static var gKeywords : haxe.ds.StringMap<Bool> =
    {
        seed(0);

        var ret = new haxe.ds.StringMap<Bool>();
        
        var keywords =
            [ "break", "callback", "case", "cast", "catch", "class", "continue",
              "default", "do", "dynamic", "else", "if", "enum", "extends",
              "extern", "false", "for", "function", "here", "if", "implements",
              "import", "in", "inline", "interface", "main", "never", "new",
              "null", "override", "package", "private", "public", "return",
              "static", "super", "switch", "this", "throw", "trace", "true",
              "try", "typedef", "untyped", "using", "var", "while" ];

        for (k in keywords) {
            ret.set(k, true);
        }

        ret;
    }
}
