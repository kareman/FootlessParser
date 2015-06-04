//
// Parser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result
import Runes

// TODO: Implement ParserError
public typealias ParserError = String

public struct Parser <Token, Output> {
	public let parse: ParserInput<Token> -> Result<(output: Output, nextinput: ParserInput<Token>), ParserError>
}

/** Succeeds iff 'condition' is true. Returns the token it read. */
public func satisfy <T> (# expect: String, condition: T -> Bool) -> Parser<T,T> {
	return Parser { input in
		return input.read(expect: expect) >>- { next in
			if condition(next.head) {
				return .success(output:next.head, nextinput:next.tail)
			} else {
				let quote = contains(expect, "'") ? "" : "'" // avoid double quoting 
				return .failure("expected \(quote + expect + quote), got '\(next.head)'.")
			}
		}
	}
}

/** Match a single token. */
public func token <T: Equatable> (token: T) -> Parser<T,T> {
	return satisfy(expect: toString(token)) { $0 == token }
}

/** Return whatever the next token is. */
public func any <T> () -> Parser<T,T> {
	return satisfy(expect: "anything") { T in true }
}

/** Try parser, if it fails return 'otherwise' without consuming input. */
public func optional <T,A> (p: Parser<T,A>, # otherwise: A) -> Parser<T,A> {
	return p <|> pure(otherwise)
}

/** Return a collection containing x and all elements of xs. Works with strings and arrays. */
func extend <A, C: ExtensibleCollectionType where C.Generator.Element == A> (x: A)(xs: C) -> C {
	// not satisfied with this way of doing it, but ExtensibleCollectionType has only mutable methods.
	var result = C()
	result.append(x)
	result.extend(xs)
	return result
}

/** Delay creation of parser until it is needed. */
func lazy <T,A> (@autoclosure(escaping) f: () -> Parser<T,A>) -> Parser<T,A> {
	return Parser { input in f().parse(input) }
}

/** Apply parser once, then repeat until it fails. Returns an array of the results. */
public func oneOrMore <T,A> (p: Parser<T,A>) -> Parser<T,[A]> {
	return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise: [] )
}

/** Repeat parser until it fails. Returns an array of the results. */
public func zeroOrMore <T,A> (p: Parser<T,A>) -> Parser<T,[A]> {
	return optional( oneOrMore(p), otherwise: [] )
}

/** Succeeds if the next token is in the provided collection. */
public func oneOf <T: Equatable, C: CollectionType where C.Generator.Element == T> (collection: C) -> Parser<T,T> {
	return satisfy(expect: "one of '\(toString(collection))'") { contains(collection, $0) }
}

/** Succeeds if the next token is _not_ in the provided collection. */
public func noneOf <T: Equatable, C: CollectionType where C.Generator.Element == T> (collection: C) -> Parser<T,T> {
	return satisfy(expect: "something not in '\(toString(collection))'") { !contains(collection, $0) }
}

/** Verify that input is empty. */
public func eof <T> () -> Parser<T,()> {
	return Parser { input in
		if let next = input.next() {
			return .failure("expected EOF, got '\(next.head)'.")
		} else {
			return .success(output:(), nextinput:input)
		}
	}
}

/** 
	Parse all of input with parser.

	Failure to consume all of input will result in a ParserError.

	:param: p A parser.
	:param: input A collection with a forward index, like a string or an array.

	:returns: Output from the parser, or a ParserError.
*/
public func parse
	<A,T,C: CollectionType, I: ForwardIndexType where C.Generator.Element == T, C.Index == I>
	(p: Parser<T,A>, input: C) -> Result<A,ParserError> {

	return ( p <* eof() ).parse(ParserInput(input)) >>- { .success($0.output) }
}
