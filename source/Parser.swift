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

/** Match a single token. */
public func token <T: Equatable> (token: T) -> Parser<T, T> {
	return Parser { input in
		return input.read(expect: toString(token)) >>- { next in
			if next.head == token {
				return .success(output:token, nextinput:next.tail)
			} else {
				return .failure("expected '\(token)', got '\(next.head)'.")
			}
		}
	}
}

/** Return whatever the next token is. */
public func any <T> () -> Parser<T, T> {
	return Parser { input in
		return input.read(expect: "anything") >>- { .success(output:$0.head, nextinput:$0.tail) }
	}
}
