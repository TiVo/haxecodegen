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
    public static function emit(stmt : GenExpression, out : haxe.io.Output)
    {
        switch (stmt) {
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
            }
            emit(right, out);
            out.writeString(")");
        case Constant(c):
            out.writeString(Util.constantToString(c));
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
