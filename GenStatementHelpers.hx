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


import GenExpression;

class GenStatementHelpers
{
    public static function randomBlock(bs : BlockState,
                                       out : Array<GenStatement>)
    {
        if (bs.statementCount == 0) {
            return;
        }
        bs.depth += 1;
        var count = (Random.random() % bs.statementCount) + 1;
        // Initial 1 - 5 statements
        while ((bs.statementCount > 0) && (count > 0)) {
            bs.statementCount -= 1;
            count -= 1;
            out.push(randomStatement(bs, out));
        }
        bs.depth -= 1;
    }

    public static function randomStatement(bs : BlockState, 
                                           out : Array<GenStatement>)
        : GenStatement
    {
        if (bs.depth > 3) {
            return randomAssignment(bs, out);
        }

        switch (Random.random() % 10) {
        case 0:
            return randomFor(bs, out);
        case 1, 2, 3:
            if (bs.allowFunctionCall) {
                // Find a function to call at random
                var func = null;
                if ((bs.functions.length > 0) && Random.chance(50)) {
                    // Look in the current class for a random function to call
                    func = bs.functions[Random.random() % bs.functions.length];
                }
                else {
                    func = Util.randomStaticFunction(Util.randomType());
                }
                if (func != null) {
                    var exp = randomFunctionCall(bs, out, func);
                    switch (exp) {
                    case FunctionCall(f, args):
                        return FunctionCall(f, args);
                    default:
                        throw "Internal error - expected function call";
                    }
                }
            }
        case 4, 5, 6:
            return randomIf(bs, out);
        case 7:
            return randomSwitch(bs, out);
        default:
        }

        return randomAssignment(bs, out);
    }

    public static function randomExpressionOfType(bs : BlockState, 
                                                  out : Array<GenStatement>,
                                                  gt : GenType)
        : GenExpression
    {
        // 60% chance of trying to find an existing variable
        if (Random.chance(60)) {
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
            // 40% chance of looking in the current class for a function that
            // returns this type
            if (Random.chance(40)) {
                for (f in bs.functions) {
                    if ((f.returns != null) && Util.typesEqual(f.returns, gt)) {
                        return randomFunctionCall(bs, out, f);
                    }
                }
            }
            
            // 40% chance of looking for a static function that returns this
            // type
            if (Random.chance(40)) {
                var f = Util.randomStaticFunction(gt);
                if (f != null) {
                    return randomFunctionCall(bs, out, f);
                }
            }
        }

        if (bs.expressionDepth < 3) {
            var ret = null;
            bs.expressionDepth += 1;
            // If the expression is of type Bool, 40% chance of random boolean
            // operation
            if ((gt == GenTypeBool) && Random.chance(40)) {
                var subtype : GenType;
                switch (Random.random() % 3) {
                case 0:
                    subtype = GenTypeBool;
                case 1:
                    subtype = GenTypeInt;
                default:
                    subtype = GenTypeFloat;
                }
                ret = BinaryBoolean(randomExpressionOfType(bs, out, subtype),
                                    randomBoolOp(subtype),
                                    randomExpressionOfType(bs, out, subtype));
            }
            
            // If the expression is of type Int or Float, 40% chance of math
            // expression
            if (((gt == GenTypeInt) || (gt == GenTypeFloat)) &&
                Random.chance(40)) {
                var op = randomMathOp();
                ret = BinaryMath(randomExpressionOfType(bs, out, gt),
                                 op,
                                 randomExpressionOfType(bs, out, gt));
                if ((op == DIV) && (gt == GenTypeInt)) {
                    ret = StdInt(ret);
                }
            }

            bs.expressionDepth -= 1;

            if (ret != null) {
                return ret;
            }
        }
        
        switch (gt) {
        case GenTypeDynamic:
            if (Random.chance(10)) {
                return Constant(ConstantNull);
            }
            else {
                return randomExpressionOfType(bs, out, Util.randomType());
            }
        case GenTypeBool:
            return Constant(ConstantBool(Random.chance(50)));
        case GenTypeInt:
            return Constant(ConstantInt(Random.random()));
        case GenTypeFloat:
            return Constant(ConstantFloat(((Random.chance(50) ? 1.0 : -1.0) *
                                           Random.random()) / Random.random()));
        case GenTypeString:
            return Constant(ConstantString(Random.identifier(false)));
        case GenTypeInterface(ifc):
            if (Random.chance(10)) {
                return Constant(ConstantNull);
            }
            // Find a random class implementing that interface, if there is one
            var c = ifc.randomImplementor();
            if (c == null) {
                return Constant(ConstantNull);
            }
            return randomClassInstance(bs, out, c);
        case GenTypeClass(cls):
            return randomClassInstance(bs, out, cls);
        case GenTypeEnum(enm):
            if ((bs.enumDepth > 2) || Random.chance(5)) {
                return Constant(ConstantNull);
            }
            var elem = enm.elements[Random.random() % enm.elements.length];
            var args = new Array<GenExpression>();
            if (elem.parameters != null) {
                bs.enumDepth += 1;
                var i = 0;
                while (i < elem.parameters.length) {
                    args.push(randomExpressionOfType
                              (bs, out, elem.parameters[i++].type));
                }
                bs.enumDepth -= 1;
            }
            return EnumMember(enm, elem, args);
        case GenTypeClosure(c_args, c_returns):
            // Closures bring too many extra complications, don't generate
            // any for now
            return Constant(ConstantNull);
        case GenTypeArray(t):
            if (Random.chance(25)) {
                return Constant(ConstantNull);
            }
            var arr = new Array<GenExpression>();
            var count = Random.random() % 10;
            while (count-- > 0) {
                arr.push(randomExpressionOfType(bs, out, t));
            }
            return Array(arr);
        case GenTypeMap(k, v):
            // Too hard to prevent duplicate keys, so just always use null
            return Constant(ConstantNull);
        case GenTypeAnonymous(names, types):
            if (Random.chance(10)) {
                return Constant(ConstantNull);
            }
            var values = new Array<GenExpression>();
            var i = 0;
            while (i < types.length) {
                values.push(randomExpressionOfType(bs, out, types[i++]));
            }
            return Anonymous(names, values);
        }
    }

    private static function randomClassInstance(bs : BlockState, 
                                                out : Array<GenStatement>,
                                                cls : GenClass)
        : GenExpression
    {
        // 90% chance of trying to find an existing one
        if (!bs.noSearch && Random.chance(90)) {
            bs.noSearch = true;
            var ret = randomExpressionOfType(bs, out, GenTypeClass(cls));
            bs.noSearch = false;
            return ret;
        }
        
        return New(cls);
    }

    private static function randomMathOp() : MathOp
    {
        switch (Random.random() % 4) {
        case 0:
            return ADD;
        case 1:
            return SUB;
        case 2:
            return MUL;
        default:
            return DIV;
        }
    }

    private static function randomBoolOp(gt : GenType) : BoolOp
    {
        if (gt == GenTypeBool) {
            switch (Random.random() % 4) {
            case 0:
                return EQ;
            case 1:
                return NE;
            case 2:
                return AND;
            default:
                return OR;
            }
        }
        else {
            if (Random.chance(50)) {
                return EQ;
            }
            else {
                return NE;
            }
        }
    }

    public static function randomFor(bs : BlockState,
                                     out : Array<GenStatement>) : GenStatement
    {
        var ivar = "local" + bs.nextLocalNumber++;
        var begin = Random.random() % 10;
        var sub = new Array<GenStatement>();
        bs.statementCount += 1;
        randomBlock(bs, sub);
        return For(ivar, begin, (Random.random() % 100) + begin + 1, sub);
    }

    public static function randomIf(bs : BlockState,
                                    out : Array<GenStatement>) : GenStatement
    {
        var condition = randomExpressionOfType(bs, out, GenTypeBool);
        var ifBlock = new Array<GenStatement>();
        randomBlock(bs, ifBlock);
        var elseBlock : Null<Array<GenStatement>> = null;
        if (Random.chance(33)) {
            elseBlock = new Array<GenStatement>();
            bs.statementCount += 1;
            randomBlock(bs, elseBlock);
        }
        return If(condition, ifBlock, elseBlock);
    }

    public static function randomSwitch(bs : BlockState, 
                                        out : Array<GenStatement>)
        : GenStatement
    {
        var enm : GenEnum = Random.chance(50) ? GenEnum.randomEnum() : null;

        var exp = null;
        var cases = new Array<GenExpression>();
        var blocks = new Array<Array<GenStatement>>();
        var caseCount = (Random.random() % 10) + 1;
        var defaultBlock = new Array<GenStatement>();

        if (enm == null) {
            // Use integers
            exp = BinaryMath(randomExpressionOfType(bs, out, GenTypeInt),
                             MOD, Constant(ConstantInt(100)));
            var alreadyCases = new haxe.ds.IntMap<Bool>();
            while (caseCount-- > 0) {
                var i = 0;
                while (true) {
                    i = Random.random() % 100;
                    if (!alreadyCases.exists(i)) {
                        alreadyCases.set(i, true);
                        break;
                    }
                }
                cases.push(Constant(ConstantInt(i)));
                var block = new Array<GenStatement>();
                bs.statementCount += 1;
                randomBlock(bs, block);
                blocks.push(block);
            }
        }
        else {
            exp = randomExpressionOfType(bs, out, GenTypeEnum(enm));
            var alreadyCases = new haxe.ds.StringMap<Bool>();
            while (caseCount-- > 0) {
                var captures = new Array<{ name : String, type : GenType,
                                           r : Bool, w : Bool }>();
                var enum_exp = randomEnumCase(bs, out, enm, captures);
                var s = GenExpressionHelpers.toString(enum_exp);
                if (!alreadyCases.exists(s)) {
                    alreadyCases.set(s, true);
                    cases.push(enum_exp);
                    var block = new Array<GenStatement>();
                    if (captures.length > 0) {
                        bs.captures.push(captures);
                    }
                    bs.statementCount += 1;
                    randomBlock(bs, block);
                    blocks.push(block);
                    if (captures.length > 0) {
                        bs.captures.pop();
                    }
                }
            }
        }
        
        bs.statementCount += (Random.random() % 4) + 1;
        randomBlock(bs, defaultBlock);
        return Switch(exp, cases, blocks, defaultBlock);
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
                    // If it's dynamic, do a dynamic property set
                    if (s.field.type == GenTypeDynamic) {
                        return Assignment(s.gc.fullname + "." + s.field.name +
                                          "." + Random.identifier(false),
                                          randomExpressionOfType
                                          (bs, out, Util.randomType()));
                    }
                    else {
                        return Assignment(s.gc.fullname + "." + s.field.name,
                                          randomExpressionOfType
                                          (bs, out, s.field.type));
                    }
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

        return Var(name, type, randomExpressionOfType(bs, out, type));
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
        case For(ivar, begin, end, block):
            out.writeString("for (");
            out.writeString(ivar);
            out.writeString(" in " + begin + " ... " + end + ") {\n");
            for (s in block) {
                GenStatementHelpers.emit(s, out, indent + 4);
            }
            Util.indent(out, indent);
            out.writeString("}\n");
        case FunctionCall(f, args):
            out.writeString(f.callAs);
            out.writeString("(");
            var i = 0;
            while (i < args.length) {
                if (i > 0) {
                    out.writeString(", ");
                }
                GenExpressionHelpers.emit(args[i++], out);
            }
            out.writeString(");\n");
        case If(condition, ifBlock, elseBlock):
            out.writeString("if (");
            GenExpressionHelpers.emit(condition, out);
            out.writeString(") {\n");
            for (s in ifBlock) {
                GenStatementHelpers.emit(s, out, indent + 4);
            }
            Util.indent(out, indent);
            out.writeString("}\n");
            if (elseBlock != null) {
                Util.indent(out, indent);
                out.writeString("else {\n");
                for (s in elseBlock) {
                    GenStatementHelpers.emit(s, out, indent + 4);
                }
                Util.indent(out, indent);
                out.writeString("}\n");
            }
        case Return(exp):
            out.writeString("return (");
            GenExpressionHelpers.emit(exp, out);
            out.writeString(");\n");
        case Switch(exp, cases, blocks, defaultBlock):
            out.writeString("switch (");
            GenExpressionHelpers.emit(exp, out);
            out.writeString(") {\n");
            var i = 0;
            while (i < cases.length) {
                Util.indent(out, indent);
                out.writeString("case ");
                GenExpressionHelpers.emit(cases[i], out);
                out.writeString(":\n");
                var block = blocks[i++];
                var j = 0;
                while (j < block.length) {
                    emit(block[j++], out, indent + 4);
                }
            }
            Util.indent(out, indent);
            out.writeString("default:\n");
            var j = 0;
            while (j < defaultBlock.length) {
                emit(defaultBlock[j++], out, indent + 4);
            }
            Util.indent(out, indent);
            out.writeString("}\n");
        }
        Util.indent(out, indent);
        out.writeString("Statics.one();\n");
    }

    private static function randomEnumCase
        (bs : BlockState, out : Array<GenStatement>, enm : GenEnum,
         captures : 
         Array<{ name : String, type : GenType, r : Bool, w : Bool }>)
            : GenExpression
    {
        var elem = enm.elements[Random.random() % enm.elements.length];
        var args = new Array<GenExpression>();
        if (elem.parameters != null) {
            var i = 0;
            while (i < elem.parameters.length) {
                var name = "capture" + i;
                // For now, just use a capture variable for everything
                args.push(Variable(name));
                captures.push({ name : name, type : elem.parameters[i].type,
                                r : true, w : true });
                i += 1;
            }
        }
        return EnumMember(enm, elem, args);
    }
}
