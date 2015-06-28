//
// StringParser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result

/** Match a single character. */
public func char (c: Character) -> Parser<Character, Character> {
	return satisfy(expect: String(c)) { $0 == c }
}

public func extend  (a: String) (b: String) ->  String {
return  a + b
}

public func extend  (a: Character) (b: String) ->  String {
	return  String(a) + b
}


/** Apply character parser once, then repeat until it fails. Returns a string. */
public func oneOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise: "" )
}

/** Repeat character parser until it fails. Returns a string. */
public func zeroOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return optional( oneOrMore(p), otherwise: "" )
}

/** Repeat character parser 'n' times and return as string. If 'n' == 0 it always succeeds and returns "". */
public func count <T> (n: Int, _ p: Parser<T,Character>) -> Parser<T,String> {
	return n == 0 ? pure("") : extend <^> p <*> count(n-1, p)
}

/**
	Repeat parser as many times as possible within the given range.

	count(2...2, p) is identical to count(2, p)

	- parameter r: A positive integer range.
*/
public func count <T> (r: Range<Int>, _ p: Parser<T,Character>) -> Parser<T,String> {
	if r.startIndex < 0 { return fail("count(\(r)): range cannot be negative.") }
	return extend <^> count(r.startIndex, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}
