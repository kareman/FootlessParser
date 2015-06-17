//
// Parser+Operators.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result

infix operator >>- { associativity left precedence 100 }

/**
	FlatMap a function over a parser.

	- If the parser fails, the function will not be evaluated and the error is returned.
	- If the parser succeeds, the function will be applied to the output, and the resulting parser is run with the remaining input.

	:param: p A parser of type Parser<T,A>
	:param: f A transformation function from type A to Parser<T,B>

	:returns: A parser of type Parser<T,B>
*/
public func >>- <T,A,B> (p: Parser<T,A>, f: A -> Parser<T,B>) -> Parser<T,B> {
	return Parser { input in
		p.parse(input) >>- { f($0.output).parse($0.nextinput) }
	}
}

infix operator <^> { associativity left precedence 130 }

/**
	Map a function over a parser

	- If the parser fails, the function will not be evaluated and the parser error is returned.
	- If the parser succeeds, the function will be applied to the output.

	:param: f A function from type A to type B
	:param: p A parser of type Parser<T,A>

	:returns: A parser of type Parser<T,B>
*/
public func <^> <T,A,B> (f: A -> B, p: Parser<T,A>) -> Parser<T,B> {
	return Parser { input in
		p.parse(input) >>- { .success(output:f($0.output), nextinput:$0.nextinput) }
	}
}

infix operator <*> { associativity left precedence 130 }

/**
	Apply a parser returning a function to another parser.

	- If the first parser fails, its error will be returned.
	- If it succeeds, the resulting function will be applied to the 2nd parser.

	:param: fp A parser with a function A->B as output
	:param: p A parser of type Parser<T,A>

	:returns: A parser of type Parser<T,B>
*/
public func <*> <T,A,B> (fp: Parser<T,A->B>, p: Parser<T,A>) -> Parser<T,B> {
	return fp >>- { $0 <^> p }
}

infix operator <* { associativity left precedence 130 }

/**
	Apply both parsers, but only return the output from the first one.

	- If the first parser fails, its error will be returned.
	- If the 2nd parser fails, its error will be returned.

	:returns: A parser of the same type as the first parser.
*/
public func <* <T,A,B> (p1: Parser<T,A>, p2: Parser<T,B>) -> Parser<T,A> {
	return { x in { _ in x } } <^> p1 <*> p2
}

infix operator *> { associativity left precedence 130 }

/**
	Apply both parsers, but only return the output from the 2nd one.

	- If the first parser fails, its error will be returned.
	- If the 2nd parser fails, its error will be returned.

	:returns: A parser of the same type as the 2nd parser.
*/
public func *> <T,A,B> (p1: Parser<T,A>, p2: Parser<T,B>) -> Parser<T,B> {
	return { _ in { x in x } } <^> p1 <*> p2
}


/**
	Create a parser which ignores input and returns this parameter.

	:param: a A value of type A
*/
public func pure <T,A> (a: A) -> Parser<T,A> {
	return Parser { input in .success(output:a, nextinput: input) }
}


infix operator <|> { associativity right precedence 80 }

/**
	Apply one of 2 parsers.

	- If the first parser succeeds, return its results.
	- Else if the 2nd parser succeeds, return its results.
	- If they both fail, return the failure from the last parser.

	Has infinite lookahead. The 2nd parser starts from the same position in the input as the first one.
*/
public func <|> <T,A> (l: Parser<T,A>, r: Parser<T,A>) -> Parser<T,A> {
	return Parser { input in l.parse(input) ?? r.parse(input) }
}
