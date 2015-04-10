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
	Wrap a value in a minimal context of Parser. Also known as 'return' in Haskell.

	:param: a A value of type A

	:returns: A parser which ignores the input and returns 'a'.
*/
public func pure <A> (a: A) -> Parser<A,A> {
	return Parser { input in .success(output:a, nextinput: input) }
}
