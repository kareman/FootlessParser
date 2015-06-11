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

		assertParseSucceeds(parser, &input, result: 1, consumed: 1)
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testSeveralTokenParsers () {
		var input = ParserInput("abc")

		for character in "abc" {
			let parser = token(character)
			assertParseSucceeds(parser, &input, result: character, consumed: 1)
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

		assertParseSucceeds(parser, &input, result: "a", consumed: 1)
		assertParseSucceeds(parser, &input, result: "b", consumed: 1)
	}

	func testOptionalParser () {
		let parser = optional( char("a"), otherwise: "x" )

		var input = ParserInput("abc")

		assertParseSucceeds(parser, &input, result: "a", consumed: 1)
		assertParseSucceeds(parser, &input, result: "x", consumed: 0)
	}

	func testOneOrMoreParser () {
		let parser = oneOrMore(token(1))

		assertParseSucceeds( parser, [1], result: [1], consumed: 1 )
		assertParseSucceeds( parser, [1,1,1], result: [1,1,1], consumed: 3 )
		assertParseSucceeds( parser, [1,1,1,9], result: [1,1,1], consumed: 3 )
	}

	func testZeroOrMoreParser () {
		let parser = zeroOrMore(token(1))

		assertParseSucceeds( parser, [], result: [] )
		assertParseSucceeds( parser, [9], result: [], consumed: 0 )
		assertParseSucceeds( parser, [1], result: [1] )
		assertParseSucceeds( parser, [1,1,1], result: [1,1,1] )
		assertParseSucceeds( parser, [1,1,1,9], result: [1,1,1], consumed: 3 )
	}

	func testCountParser () {
		let parser = count(3, token(1))

		assertParseSucceeds( parser, [1,1,1,1], result: [1,1,1], consumed: 3 )
		assertParseFails( parser, input: [1, 1])
		assertParseFails( parser, input: [1, 2, 1])
		assertParseFails( parser, input: [])
	}

	func testCount1Parser () {
		let parser = count(1, token(1))

		assertParseSucceeds( parser, [1,1,1,1], result: [1], consumed: 1 )
		assertParseFails( parser, input: [2, 2])
		assertParseFails( parser, input: [])
	}
	
	func testCountParser0TimesWithoutConsumingInput () {
		let parser = count(0, token(1))

		assertParseSucceeds( parser, [1,1,1,1], result: [], consumed: 0 )
		assertParseSucceeds( parser, [2,2,2,2], result: [], consumed: 0 )
		assertParseSucceeds( parser, [], result: [], consumed: 0 )
	}

	func testOneOfParser () {
		let parser = oneOf("abc")

		assertParseSucceeds( parser, "a", result: "a" )
		assertParseSucceeds( parser, "b", result: "b" )
		assertParseSucceeds( parser, "c", result: "c" )
		assertParseFails( parser, input: "d" )

		assertParseSucceeds( parser, "ax", result: "a", consumed: 1 )
	}

	func testNoneOfParser () {
		let parser = noneOf("abc")

		assertParseFails( parser, input: "a" )
		assertParseFails( parser, input: "b" )
		assertParseFails( parser, input: "c" )
		assertParseSucceeds( parser, "d", result: "d" )
		assertParseSucceeds( parser, "da", result: "d", consumed: 1 )
	}

	func testNotParser () {
		let parser = not("a" as Character)

		assertParseSucceeds( parser, "b", result: "b" )
		assertParseSucceeds( parser, "c", result: "c" )
		assertParseFails( parser, input: "a" )
	}

	func testEofParser () {
		let parser = token(1) <* eof()

		assertParseSucceeds( parser, [1], result: 1 )
		assertParseFails( parser, input: [1,2] )
		assertParseSucceeds( token(1), [1,2] )
	}

	func testParsingAString () {
		let parser = zeroOrMore(char("a"))

		XCTAssertEqual( parse(parser, "a").value!, "a" )
		XCTAssertEqual( parse(parser, "aaaa").value!, "aaaa" )
		XCTAssertNotNil( parse(parser, "aaab").error )
	}
}
