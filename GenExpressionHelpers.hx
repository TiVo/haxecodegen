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

class GenExpressionHelpers
{
    public static function toString(exp : GenExpression) : String
    {
        var out = new haxe.io.BytesOutput();
        emit(exp, out);
        return out.getBytes().toString();
    }

    public static function emit(stmt : GenExpression, out : haxe.io.Output)
    {
        switch (stmt) {
        case Anonymous(names, values):
            out.writeString("{ ");
            var i = 0;
            while (i < names.length) {
                if (i > 0) {
                    out.writeString(", ");
                }
                out.writeString(names[i]);
                out.writeString(" : ");
                emit(values[i++], out);
            }
            out.writeString(" }");
        case Array(elements):
            if (elements.length == 0) {
                out.writeString("[ ]");
            }
            else {
                out.writeString("[ ");
                var i = 0;
                while (i < elements.length) {
                    if (i > 0) {
                        out.writeString(", ");
                    }
                    emit(elements[i++], out);
                }
                out.writeString(" ]");
            }
        case BinaryBoolean(left, op, right):
            out.writeString("(");
            emit(left, out);
            switch (op) {
            case EQ:
                out.writeString(" == ");
            case NE:
                out.writeString(" != ");
            case AND:
                out.writeString(" && ");
            case OR:
                out.writeString(" || ");
            }
            emit(right, out);
            out.writeString(")");
        case BinaryMath(left, op, right):
            out.writeString("(");
            emit(left, out);
            switch (op) {
            case ADD:
                out.writeString(" + ");
            case SUB:
                out.writeString(" - ");
            case MUL:
                out.writeString(" * ");
            case DIV:
                out.writeString(" / ");
            case MOD:
                out.writeString(" % ");
            }
            emit(right, out);
            out.writeString(")");
        case Closure(args, returns, block):
            out.writeString("function (");
            var i = 0;
            while (i < args.length) {
                if (i > 0) {
                    out.writeString(", ");
                }
                out.writeString("closure_arg" + i);
                out.writeString(" : ");
                out.writeString(Util.typeString(args[i++]));
            }
            out.writeString(") : ");
            if (returns == null) {
                out.writeString("Void");
            }
            else {
                out.writeString(Util.typeString(returns));
            }
            out.writeString("\n        {");
            i = 0;
            while (i < block.length) {
                GenStatementHelpers.emit(block[i++], out, 12);
            }
            out.writeString("        }");
        case Constant(c):
            out.writeString(Util.constantToString(c));
        case EnumMember(enm, el, args):
            out.writeString(enm.fullname + "." + el.name);
            if (args.length > 0) {
                out.writeString("(");
                var i = 0;
                while (i < args.length) {
                    if (i > 0) {
                        out.writeString(", ");
                    }
                    emit(args[i++], out);
                }
                out.writeString(")");
            }
        case New(cls):
            out.writeString("new ");
            out.writeString(cls.fullname);
            out.writeString("()");
        case StdInt(exp):
            out.writeString("Std.int(");
            emit(exp, out);
            out.writeString(")");
        case Variable(name):
            out.writeString(name);
        case FunctionCall(f, args):
            out.writeString(f.callAs);
            out.writeString("(");
            var i = 0;
            while (i < args.length) {
                if (i > 0) {
                    out.writeString(", ");
                }
                emit(args[i++], out);
            }
            out.writeString(")");
        }
    }
}
