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
		let input = ParserInput([1])
		let parser = token(1)

		let result = parser.parse(input)
		let (output, nextinput) = result.value!

		XCTAssertEqual(output, 1)
		XCTAssert( nextinput.next() == nil, "Input should be empty" )
	}

	func testSeveralTokenParsers () {
		var input = ParserInput("abc")

		for character in "abc" {
			let parser = token(character)
			let result = parser.parse(input)
			if let (output, nextinput) = result.value {
				input = nextinput
				XCTAssertEqual(output, character)
			} else {
				XCTFail("Parser failed with error message: " + result.error!)
				return
			}
		}
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testFailingParserReturnsError () {
		let input = ParserInput([1])
		let parser = token(2)

		let result = parser.parse(input)

		XCTAssertFalse(result.isSuccess)
		XCTAssertFalse(result.error!.isEmpty, "Should have an error message")
	}
}
