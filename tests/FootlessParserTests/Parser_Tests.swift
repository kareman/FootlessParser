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

	func testSeveralTokenParsers () {
		var input = ParserInput("abc")

		for character in "abc" {
			let parser = token(character)
			let result = parser.parse(input)
			if result.isSuccess {
				input = result.value!.nextinput
				XCTAssert(result.value!.output == character)
			} else {
				XCTFail("Parser failed with error message: " + result.error!)
				return
			}
		}
		XCTAssert( input.next() == nil, "Input should be empty" )
	}
}
