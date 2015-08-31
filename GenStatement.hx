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

enum GenStatement
{
    Var(name : String, type : GenType, initialValue : GenExpression);
    Assignment(path : String, expression : GenExpression);
    For(ivar : String, begin : Int, end : Int, block : Array<GenStatement>);
    If(condition : GenExpression, ifBlock : Array<GenStatement>,
       elseBlock : Null<Array<GenStatement>>);
    Return(expression : GenExpression);
}
