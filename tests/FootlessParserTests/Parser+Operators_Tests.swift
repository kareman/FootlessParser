//
// Parser+Operators_Tests.swift
// FootlessParser
//
// Created by Kåre Morstøl on 06.04.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import Runes
import XCTest
import Prelude

class FlatMap_Tests: XCTestCase {

	// return a >>= f = f a
	func testLeftIdentityLaw () {
		let leftside = pure(1) >>- token
		let rightside = token(1)

		assertParsesEqually(leftside, rightside, input: [1], shouldSucceed: true)
		assertParsesEqually(leftside, rightside, input: [9], shouldSucceed: false)
	}

	// m >>= return = m
	func testRightIdentityLaw () {
		let leftside = token(1) >>- pure
		let rightside = token(1)

		assertParsesEqually(leftside, rightside, input: [1], shouldSucceed: true)
		assertParsesEqually(leftside, rightside, input: [9], shouldSucceed: false)
	}

	// (m >>= f) >>= g = m >>= (\x -> f x >>= g)
	func testAssociativityLaw () {
		func timesTwo(x: Int) -> Parser<Int,Int> {
			let x2 = x * 2
			return satisfy(expect: "\(x2)") { $0 == x2 }
		}

		let leftside = (any() >>- token) >>- timesTwo
		let rightside = any() >>- { token($0) >>- timesTwo }

		assertParsesEqually(leftside, rightside, input: [1,1,2], shouldSucceed: true)
		assertParsesEqually(leftside, rightside, input: [9,9,9], shouldSucceed: false)

		let noparens = any() >>- token >>- timesTwo
		assertParsesEqually(leftside, noparens, input: [1,1,2], shouldSucceed: true)
		assertParsesEqually(leftside, noparens, input: [9,9,9], shouldSucceed: false)
	}
}

class Map_Tests: XCTestCase {

	// map id = id
	func testTheIdentityLaw () {
		let leftside = id <^> token(1)
		let rightside = token(1)

		assertParsesEqually(leftside, rightside, input: [1], shouldSucceed: true)
		assertParsesEqually(leftside, rightside, input: [9], shouldSucceed: false)
	}

	func testAppliesFunctionToResultOnSuccess () {
		let parser = toString <^> token(1)

		var input = ParserInput([1])

		assertParseSucceeds(parser, &input, result: "1")
		XCTAssert( input.next() == nil, "Input should be empty" )
	}

	func testReturnsErrorOnFailure () {
		let parser = toString <^> token(1)

		var input = ParserInput([9])
		let result = parser.parse(input)

		XCTAssertNotNil(result.error)
		XCTAssertFalse(result.error!.isEmpty, "Should have an error message")
		XCTAssert( input.next() != nil, "Input should _not_ be empty" )
	}
}
