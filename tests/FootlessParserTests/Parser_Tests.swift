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

	func testOptionalParser () {
		let parser = optional( token("a" as Character), otherwise: "x" )

		var input = ParserInput("abc")

		assertParseSucceeds(parser, &input, result: "a")
		assertParseSucceeds(parser, &input, result: "x")
		assertParseSucceeds( token("b" as Character), &input )
	}

	func testOneOrMoreParser () {
		let parser = oneOrMore(token(1))

		XCTAssertEqual( parser.parse(ParserInput([1])).value!.output, [1] )
		XCTAssertEqual( parser.parse(ParserInput([1,1,1])).value!.output, [1,1,1] )
		XCTAssertEqual( parser.parse(ParserInput([1,1,1,9])).value!.output, [1,1,1] )
	}

	func testOneOrMoreParserForCharacters () {
		let parser = oneOrMore(token("a" as Character))

		XCTAssertEqual( parser.parse(ParserInput("a")).value!.output, "a" )
		XCTAssertEqual( parser.parse(ParserInput("aaa")).value!.output, "aaa" )
		XCTAssertEqual( parser.parse(ParserInput("aaab")).value!.output, "aaa" )
	}

	func testZeroOrMoreParser () {
		let parser = zeroOrMore(token(1))

		XCTAssertEqual( parser.parse(ParserInput([9])).value!.output, [] )
		XCTAssertEqual( parser.parse(ParserInput([1])).value!.output, [1] )
		XCTAssertEqual( parser.parse(ParserInput([1,1,1])).value!.output, [1,1,1] )
		XCTAssertEqual( parser.parse(ParserInput([1,1,1,9])).value!.output, [1,1,1] )
	}

	func testZeroOrMoreParserForCharacters () {
		let parser = zeroOrMore(token("a" as Character))

		XCTAssertEqual( parser.parse(ParserInput("a")).value!.output, "a" )
		XCTAssertEqual( parser.parse(ParserInput("aaa")).value!.output, "aaa" )
		XCTAssertEqual( parser.parse(ParserInput("aaab")).value!.output, "aaa" )
	}

	func testEofParser () {
		let parser = token(1) <* eof()

		assertParseSucceeds( parser, [1], result: 1 )
		assertParseFails( parser, input: [1,2] )
		assertParseSucceeds( token(1), [1,2] )
	}
}
