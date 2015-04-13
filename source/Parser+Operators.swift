//
// Parser+Operators.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result
import Runes

/**
	flatMap a function over a parser.

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

/**
	map a function over a parser

	- If the parser fails, the function will not be evaluated and the parser error is returned.
	- If the parser succeeds, the function will be applied to the output.

	:param: f A transformation function from type A to type B
	:param: p A parser of type Parser<T,A>

	:returns: A parser of type Parser<T,B>
*/
public func <^> <T,A,B> (f: A -> B, p: Parser<T,A>) -> Parser<T,B> {
	return Parser { input in
		p.parse(input) >>- { .success(output:f($0.output), nextinput:$0.nextinput) }
	}
}

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

/**
	Wrap a value in a minimal context of Parser. Also known as 'return' in Haskell.

	:param: a A value of type A

	:returns: A parser which ignores the input and returns 'a'.
*/
public func pure <A> (a: A) -> Parser<A,A> {
	return Parser { input in .success(output:a, nextinput: input) }
}


infix operator <|> { associativity right precedence 80 }

/** 
	Choice operator for parsers.

	- If the first parser succeeds, return its results.
	- Else if the 2nd parser succeeds, return its results.
	- If they both fail, return the failure from the last parser.

	Has infinite lookahead. The 2nd parser starts from the same position in the input as the first one.
*/
public func <|> <T,A> (l: Parser<T,A>, r: Parser<T,A>) -> Parser<T,A> {
	return Parser { input in l.parse(input) ?? r.parse(input) }
}
