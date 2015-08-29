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

class GenStatementHelpers
{
    public static function randomBlock(bs : BlockState,
                                       out : Array<GenStatement>)
    {
        // 2% chance of no statements
        if (Random.chance(2)) {
            return;
        }
        // Initial 1 - 5 statements
        var count = (Random.random() % 5) + 1;
        // Add in additional statements
        if (bs.depth < 4) {
            count += Random.random() % (10 - (2 * bs.depth));
        }
        while (count > 0) {
            count -= 1;
            out.push(randomStatement(bs, out));
        }
    }

    public static function randomStatement(bs : BlockState, 
                                           out : Array<GenStatement>)
        : GenStatement
    {
        // If there is a return type, then a 2% chance of a return statement
        if (bs.returnType != null) {
            if (Random.chance(2)) {
                return Return(randomExpressionOfType(bs, out, bs.returnType));
            }
        }

        // Generate an assignment
        return randomAssignment(bs, out);
    }

    public static function randomExpressionOfType(bs : BlockState, 
                                                  out : Array<GenStatement>,
                                                  gt : GenType)
        : GenExpression
    {
        // 90% chance of trying to find an existing variable
        if (Random.chance(90)) {
            var v = bs.randomReadableVariable(gt);
            if (v == null) {
                // Find a class somewhere with a static variable of the given
                // type
                var s = Util.randomStatic(gt);
                if ((s != null) && s.field.isReadable()) {
                    return Variable(s.gc.fullname + "." + s.field.name);
                }
            }
        }

        if (bs.allowFunctionCall) {
            // 50% chance of looking in the current class for a function that
            // returns this type
            if (Random.chance(50)) {
                for (f in bs.functions) {
                    if ((f.returns != null) && Util.typesEqual(f.returns, gt)) {
                        return randomFunctionCall(bs, out, f);
                    }
                }
            }
            
            // 50% chance of looking for a static function that returns this
            // type
            if (Random.chance(50)) {
                var f = Util.randomStaticFunction(gt);
                if (f != null) {
                    return randomFunctionCall(bs, out, f);
                }
            }
        }
        
        // Return a constant
        return Constant(Util.randomConstant(gt));
    }

    public static function randomAssignment(bs : BlockState, 
                                            out : Array<GenStatement>)
        : GenStatement
    {
        // 90% chance of using existing
        if (Random.chance(90)) {
            // Find a variable to assign to
            var v = bs.randomWriteableVariable(null);
            if (v == null) {
                var s = Util.randomStatic(null);
                if ((s != null) && s.field.isWriteable()) {
                    return Assignment(s.gc.fullname + "." + s.field.name,
                                      randomExpressionOfType
                                      (bs, out, s.field.type));
                }
            }
            else {
                return Assignment(v.name, 
                                  randomExpressionOfType(bs, out, v.type));
            }
        }

        // Create a new variable to satisfy the assignment
        var name = "local" + bs.nextLocalNumber++;
        var type = Util.randomType();

        return Var(name, type, Constant(Util.randomConstant(type)));
    }

    public static function randomFunctionCall(bs : BlockState,
                                              out : Array<GenStatement>,
                                              gf : GenFunction)
        : GenExpression
    {
        bs.allowFunctionCall = false;
        // Make args
        var args = new Array<GenExpression>();
        var i = 0;
        while (i < gf.args.length) {
            args.push(randomExpressionOfType(bs, out, gf.args[i++].type));
        }
        bs.allowFunctionCall = true;
        return FunctionCall(gf, args);
    }

    public static function emit(stmt : GenStatement, out : haxe.io.Output,
                                indent : Int)
    {
        Util.indent(out, indent);
        switch (stmt) {
        case Var(name, type, initialValue):
            out.writeString("var ");
            out.writeString(name);
            out.writeString(" : ");
            out.writeString(Util.typeString(type));
            out.writeString(" = ");
            GenExpressionHelpers.emit(initialValue, out);
            out.writeString(";\n");
        case Assignment(path, expression):
            out.writeString(path);
            out.writeString(" = ");
            GenExpressionHelpers.emit(expression, out);
            out.writeString(";\n");
        case Return(exp):
            out.writeString("return (");
            GenExpressionHelpers.emit(exp, out);
            out.writeString(");\n");
        }
    }
}
