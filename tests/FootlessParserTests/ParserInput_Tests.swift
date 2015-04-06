//
// ParserInput_Tests.swift
// FootlessParserTests
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest

class ParserInput_Tests: XCTestCase {

	func testFromString () {
		let sut = ParserInput("abc")

		var (head, tail) = sut.next()!
		XCTAssertEqual(head, "a" as Character)
		(head, tail) = tail.next()!
		XCTAssertEqual(head, "b" as Character)
		(head, tail) = tail.next()!
		XCTAssertEqual(head, "c" as Character)
		XCTAssert(tail.next() == nil, "Input should be empty")
	}

	func testFromArray () {
		var sut = ParserInput([1,2,3])

		var (head, tail) = sut.next()!
		XCTAssertEqual(head, 1)
		(head, tail) = tail.next()!
		XCTAssertEqual(head, 2)
		(head, tail) = tail.next()!
		XCTAssertEqual(head, 3)
		XCTAssert(tail.next() == nil, "Input should be empty")
	}

	func testPosition () {
		var sut = ParserInput("abcde")

		XCTAssertEqual(sut.position(), 0)
		(_, sut) = sut.next()!
		XCTAssertEqual(sut.position(), 1)
		(_, sut) = sut.next()!
		(_, sut) = sut.next()!
		XCTAssertEqual(sut.position(), 3)
	}
}
