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
public func satisfy <T> (# expect: String, condition: T -> Bool) -> Parser<T, T> {
	return Parser { input in
		return input.read(expect: expect) >>- { next in
			if condition(next.head) {
				return .success(output:next.head, nextinput:next.tail)
			} else {
				return .failure("expected '\(expect)', got '\(next.head)'.")
			}
		}
	}
}

/** Match a single token. */
public func token <T: Equatable> (token: T) -> Parser<T, T> {
	return satisfy(expect: toString(token)) { $0 == token }
}

/** Return whatever the next token is. */
public func any <T> () -> Parser<T, T> {
	return satisfy(expect: "anything") { T in true }
}

/** Try parser, if it fails return 'otherwise' without consuming input. */
public func optional <T,A> (p: Parser<T,A>, # otherwise: A) -> Parser<T,A> {
	return p <|> pure(otherwise)
}
