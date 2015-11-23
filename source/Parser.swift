//
// Parser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result

// TODO: Implement ParserError
public struct ParserError : ErrorType {
	public let message: String

	public init (_ message: String) {
		self.message = message
	}
}

extension ParserError: CustomStringConvertible, Equatable {
	public var description: String {
		return message
	}
}

public func == (e1: ParserError, e2: ParserError) -> Bool {
	return e1.message == e2.message
}

public struct Parser <Token, Output> {
	public let parse: ParserInput<Token> -> Result<(output: Output, nextinput: ParserInput<Token>), ParserError>
}

/** Succeeds iff 'condition' is true. Returns the token it read. */
public func satisfy <T> (expect expect: String, condition: T -> Bool) -> Parser<T,T> {
	return Parser { input in
		return input.read(expect: expect) >>- { next in
			if condition(next.head) {
				return .Success(output:next.head, nextinput:next.tail)
			} else {
				let quote = expect.characters.contains("'") ? "" : "'" // avoid double quoting
				return .Failure(ParserError("expected \(quote + expect + quote), got '\(next.head)'."))
			}
		}
	}
}

/** Match a single token. */
public func token <T: Equatable> (token: T) -> Parser<T,T> {
	return satisfy(expect: String(token)) { $0 == token }
}

/** Match several tokens in a row, like e.g. a string. */
public func tokens <T: Equatable, C: CollectionType where C.Generator.Element == T> (xs: C) -> Parser<T,C> {
	let length = xs.count as! Int
	return count(0...length, any()) >>- { parsedtokens in
		return parsedtokens.elementsEqual(xs) ? pure(xs) : fail("Expected '\(xs)', got '\(parsedtokens)'")
	}
}

/** Return whatever the next token is. */
public func any <T> () -> Parser<T,T> {
	return satisfy(expect: "anything") { T in true }
}

/** Try parser, if it fails return 'otherwise' without consuming input. */
public func optional <T,A> (p: Parser<T,A>, otherwise: A) -> Parser<T,A> {
	return p <|> pure(otherwise)
}

/** Delay creation of parser until it is needed. */
public func lazy <T,A> (@autoclosure(escaping) f: () -> Parser<T,A>) -> Parser<T,A> {
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

/** Repeat parser 'n' times. If 'n' == 0 it always succeeds and returns []. */
public func count <T,A> (n: Int, _ p: Parser<T,A>) -> Parser<T,[A]> {
	return n == 0 ? pure([]) : extend <^> p <*> count(n-1, p)
}

/**
Repeat parser as many times as possible within the given range.

count(2...2, p) is identical to count(2, p)

- parameter r: A positive integer range.
*/
public func count <T,A> (r: Range<Int>, _ p: Parser<T,A>) -> Parser<T,[A]> {
	guard r.startIndex >= 0 else { return fail("count(\(r)): range cannot be negative.") }
	return extend <^> count(r.startIndex, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/** Succeed if the next token is in the provided collection. */
public func oneOf <T: Equatable, C: CollectionType where C.Generator.Element == T> (collection: C) -> Parser<T,T> {
	return satisfy(expect: "one of '\(String(collection))'") { collection.contains($0) }
}

/** Succeed if the next token is _not_ in the provided collection. */
public func noneOf <T: Equatable, C: CollectionType where C.Generator.Element == T> (collection: C) -> Parser<T,T> {
	return satisfy(expect: "something not in '\(String(collection))'") { !collection.contains($0) }
}

/** Match anything but this. */
public func not <T: Equatable> (token: T) -> Parser<T,T> {
	return satisfy(expect: "anything but '\(token)'") { $0 != token }
}

/** Verify that input is empty. */
public func eof <T> () -> Parser<T,()> {
	return Parser { input in
		if let next = input.next() {
			return .Failure(ParserError("expected EOF, got '\(next.head)'."))
		} else {
			return .Success(output:(), nextinput:input)
		}
	}
}

/** Fail with the given error message. Ignores input. */
public func fail <T,A> (message: String) -> Parser<T,A> {
	return Parser { _ in .Failure(ParserError(message)) }
}

/**
Parse all of input with parser.

Failure to consume all of input will result in a ParserError.

- parameter p: A parser.
- parameter input: A collection, like a string or an array.

- returns: Output from the parser.
- throws: ParserError.
*/
public func parse
	<A,T,C: CollectionType where C.Generator.Element == T>
	(p: Parser<T,A>, _ c: C) throws -> A {

	return try (( p <* eof() ).parse(ParserInput(c)) >>- { .Success($0.output) }).dematerialize()
}
