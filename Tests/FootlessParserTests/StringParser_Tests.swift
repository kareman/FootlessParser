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

		var input = Array("a".characters)

		assertParseFails(parser, "b")
		assertParseSucceeds(parser, &input, result: "a")
		XCTAssert(input == [], "Input should be empty")
	}

	func testOneOrMoreParserForCharacters () {
		let parser = oneOrMore(char("a"))

		assertParseSucceeds(parser, "a", result: "a")
		assertParseSucceeds(parser, "aaa", result: "aaa")
		assertParseSucceeds(parser, "aaab", result: "aaa", consumed: 3)
	}

	func testZeroOrMoreParserForCharacters () {
		let parser = zeroOrMore(char("a"))

		assertParseSucceeds(parser, "", result: "")
		assertParseSucceeds(parser, "b", result: "")
		assertParseSucceeds(parser, "a", result: "a")
		assertParseSucceeds(parser, "aaa", result: "aaa")
		assertParseSucceeds(parser, "aaab", result: "aaa", consumed: 3)
	}

	func testStringCountParser () {
		let parser = count(3, char("a"))

		assertParseSucceeds(parser, "aaaa", result: "aaa", consumed: 3)
		assertParseFails(parser, "aa")
		assertParseFails(parser, "axa")
		assertParseFails(parser, "")
	}

	func testStringCountRangeParser () {
		let parser = count(2...4, char("a"))

		assertParseFails(parser, "")
		assertParseFails(parser, "ab")
		assertParseSucceeds(parser, "aab", result: "aa", consumed: 2)
		assertParseSucceeds(parser, "aaaaa", result: "aaaa", consumed: 4)
	}

    func testNoneOfStrings() {
        let parser = zeroOrMore(noneOf(["foo", "bar"]))

        assertParseSucceeds(parser, "", result: "")
        assertParseSucceeds(parser, "a foo", result: "a ")
        assertParseSucceeds(parser, "a bar", result: "a ")
        assertParseSucceeds(parser, "bar foo", result: "")
    }

    func testString() {
        let parser = string("foo")
        assertParseSucceeds(parser, "foo", result: "foo")
        assertParseSucceeds(parser, "foobar", result: "foo")
        assertParseFails(parser, "barf")
        assertParseFails(parser, "bar")
        assertParseFails(parser, "ba")
        assertParseFails(parser, "b")
        assertParseFails(parser, "")
    }
}

extension StringParser_Tests {
	public static var allTests = [
		("testCharParser", testCharParser),
		("testOneOrMoreParserForCharacters", testOneOrMoreParserForCharacters),
		("testZeroOrMoreParserForCharacters", testZeroOrMoreParserForCharacters),
		("testStringCountParser", testStringCountParser),
		("testStringCountRangeParser", testStringCountRangeParser),
		("testNoneOfStrings", testNoneOfStrings),
		("testString", testString),
		]
}
