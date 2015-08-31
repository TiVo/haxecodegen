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

enum GenExpression
{
    BinaryBoolean(left : GenExpression, op : BoolOp, right : GenExpression);
    BinaryMath(left : GenExpression, op : MathOp, right : GenExpression);
    Constant(c : Constant);
    StdInt(exp : GenExpression); // Std.int(exp)
    Variable(name : String);
    FunctionCall(f : GenFunction, args : Array<GenExpression>);
}


enum BoolOp
{
    EQ;  // ==
    NE;  // !=
    AND; // &&
    OR;  // ||
}


enum MathOp
{
    ADD; // +
    SUB; // -
    MUL; // *
    DIV; // /
}
