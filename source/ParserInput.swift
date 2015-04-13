//
// ParserInput.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result
import Foundation

/** Provide parser with tokens from the input. */
public struct ParserInput <Token> {

	/** Return the next token and the rest of the input. */
	public let next: () -> (head: Token, tail: ParserInput<Token>)?

	/** 
	The number of tokens that have been read so far.
	
	Warning! Will be slow on long strings.
	*/
	public let position: () -> Int

	/** Unique ID for every manually created ParserInput. Those returned from other ParserInputs inherit their IDs. */
	private let id: Int

	private init <C: CollectionType, I: ForwardIndexType where C.Generator.Element == Token, C.Index == I> (_ source: C, index: I, id: Int) {
		next = {
			return index == source.endIndex
				? nil
				: ( source[index], ParserInput(source, index: index.successor(), id: id) )
		}
		// Heartbreakingly inefficient on long strings. Will have to be replaced if it is going to be called frequently.
		position = { distance(source.startIndex, index) as! Int }
		self.id = id
	}

	/** Use a collection as input to a parser. */
	public init <C: CollectionType where C.Generator.Element == Token> (_ source: C) {
		self.init(source, index: source.startIndex, id: NSUUID().hashValue)
	}
}

extension ParserInput {

	/** Return the next token and the rest of the input, or an error message if the end has been reached. */
	public func read (# expect: String) -> Result<(head: Token, tail: ParserInput<Token>), ParserError> {
		if let next = self.next() {
			return .success(next)
		} else {
			return .failure("expected '\(expect)', got EOF.")
		}
	}
}


extension ParserInput: Equatable {}

/** True iff 2 versions of the same ParserInput are at the same position. Does not check if they are using the same source. */
public func == <T> (lhs: ParserInput<T>, rhs: ParserInput<T>) -> Bool {
	return lhs.id == rhs.id && lhs.position() == rhs.position()
}

extension ParserInput: DebugPrintable {
	public var debugDescription: String { return "ID: \(id), position:\(position())" }
}
