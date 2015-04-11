//
// Parser_Tests.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest

class Parser_Tests: XCTestCase {

	func testSingleTokenParser () {
		let parser = token(1)

		var input = ParserInput([1])

		assertParseSucceeds(parser, &input, result: 1)
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testSeveralTokenParsers () {
		var input = ParserInput("abc")

		for character in "abc" {
			let parser = token(character)
			assertParseSucceeds(parser, &input, result: character)
		}
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testFailingParserReturnsError () {
		let parser = token(2)

		assertParseFails(parser, input: [1])
	}

	func testAnyParser () {
		let parser: Parser<Character, Character> = any()

		var input = ParserInput("abc")

		assertParseSucceeds(parser, &input, result: "a")
		assertParseSucceeds(parser, &input, result: "b")
	}
}
