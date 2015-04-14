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

		assertParseFails(parser, input: [9])
	}
}

func sum (a: Int)(b: Int) -> Int { return a + b }
func product (a: Int)(b: Int) -> Int { return a * b }

class Apply_Tests: XCTestCase {

	func testWith2Parsers () {
		let parser = sum <^> any() <*> any()

		assertParseSucceeds(parser, [1,1], result: 2)
		assertParseSucceeds(parser, [10,3], result: 13)
	}
}

class Choice_Tests: XCTestCase {

	func testParsesOneOrTheOther () {
		let parser = token(1) <|> token(2)

		assertParseSucceeds(parser, [1])
		assertParseSucceeds(parser, [2])
		assertParseFails(parser, input: [3])
	}

	func testWithApplyOperator () {
		let parser = sum <^> token(1) <*> token(2) <|> sum <^> token(3) <*> token(4)

		assertParseSucceeds(parser, [1,2], result: 3)
		assertParseSucceeds(parser, [3,4], result: 7)
		assertParseFails(parser, input: [1,3])
	}

	func testWithApplyAndIdenticalBeginning () {
		let parser = sum <^> token(1) <*> token(2) <|> sum <^> token(1) <*> token(4)

		assertParseSucceeds(parser, [1,2], result: 3)
		assertParseSucceeds(parser, [1,4], result: 5)
		assertParseFails(parser, input: [1,1])
	}

	func test2ChoicesWithApplyAndIdenticalBeginning () {
		let parser =
			sum <^> token(1) <*> token(2)	<|>
			sum <^> token(1) <*> token(3) <|>
			sum <^> token(1) <*> token(4)

		assertParseSucceeds(parser, [1,2], result: 3)
		assertParseSucceeds(parser, [1,3], result: 4)
		assertParseSucceeds(parser, [1,4], result: 5)
		assertParseFails(parser, input: [1,5])
	}

	func testLeftSideIsTriedFirst () {
		let parser = product <^> token(1) <*> token(2) <|> sum <^> token(1) <*> token(2)

		assertParseSucceeds(parser, [1,2], result: 2)
	}
	
}
