//
// StringParser_Tests.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest

class StringParser_Tests: XCTestCase {

	func testCharParser () {
		let parser = char("a")

		var input = ParserInput("a")

		assertParseFails(parser, input: "b")
		assertParseSucceeds(parser, &input, result: "a")
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testOneOrMoreParserForCharacters () {
		let parser = oneOrMore(char("a"))

		assertParseSucceeds( parser, "a", result: "a" )
		assertParseSucceeds( parser, "aaa", result: "aaa" )
		assertParseSucceeds( parser, "aaab", result: "aaa", consumed: 3 )
	}

	func testZeroOrMoreParserForCharacters () {
		let parser = zeroOrMore(char("a"))

		assertParseSucceeds( parser, "", result: "" )
		assertParseSucceeds( parser, "b", result: "" )
		assertParseSucceeds( parser, "a", result: "a" )
		assertParseSucceeds( parser, "aaa", result: "aaa" )
		assertParseSucceeds( parser, "aaab", result: "aaa", consumed: 3 )
	}
}
