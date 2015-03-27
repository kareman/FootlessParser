//
// ParserInput.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import LlamaKit

/** Provide parser with tokens from the input. */
public struct ParserInput <Token> {

	/** Return the next token and the rest of the input. */
	public let next: () -> (head: Token, tail: ParserInput<Token>)?

	init <C: CollectionType, I: ForwardIndexType where C.Generator.Element == Token, C.Index == I> (_ source: C, position: I) {
		next = {
			return position == source.endIndex
				? nil
				: ( source[position], ParserInput(source, position: position.successor()) )
		}
	}

	/** Use a collection as input to a parser. */
	public init <C: CollectionType where C.Generator.Element == Token> (_ source: C) {
		self.init(source, position: source.startIndex)
	}
}

extension ParserInput {

	/** Return the next token and the rest of the input, or an error message if the end has been reached. */
	func read (# expect: String) -> Result<(head: Token, tail: ParserInput<Token>), ParserError> {
		if let next = self.next() {
			return success(next)
		} else {
			return failure("expected '\(expect)', got EOF.")
		}
	}
}
