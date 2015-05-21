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

	func testOneOrMoreParserForCharacters () {
		let parser = oneOrMore(token("a" as Character))

		XCTAssertEqual( parser.parse(ParserInput("a")).value!.output, "a" )
		XCTAssertEqual( parser.parse(ParserInput("aaa")).value!.output, "aaa" )
		XCTAssertEqual( parser.parse(ParserInput("aaab")).value!.output, "aaa" )
	}

	func testZeroOrMoreParserForCharacters () {
		let parser = zeroOrMore(token("a" as Character))

		XCTAssertEqual( parser.parse(ParserInput("a")).value!.output, "a" )
		XCTAssertEqual( parser.parse(ParserInput("aaa")).value!.output, "aaa" )
		XCTAssertEqual( parser.parse(ParserInput("aaab")).value!.output, "aaa" )
	}
}
