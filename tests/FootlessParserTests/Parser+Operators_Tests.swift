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
import Result

public func == <T:Equatable, U:Equatable> (lhs: (output:T, nextinput:U), rhs: (output:T, nextinput:U)) -> Bool {
	return lhs.output == rhs.output && lhs.nextinput == rhs.nextinput
}

public func == <T:Equatable, U:Equatable, E:Equatable> (lhs: Result<(output:T, nextinput:U), E>, rhs: Result<(output:T, nextinput:U), E>) -> Bool {
	if let leftvalue = lhs.value, rightvalue = rhs.value where leftvalue == rightvalue {
		return true
	} else if let lefterror = lhs.error, righterror = rhs.error where lefterror == righterror {
		return true
	}
	return false
}


class FlatMap_Tests: XCTestCase {

	// return a >>= f = f a
	func testLeftIdentityLaw () {
		let leftside =	pure(1) >>- token
		let rightside = token(1)

		let correctinput = ParserInput([1])
		XCTAssert(leftside.parse(correctinput) == rightside.parse(correctinput))
		let wronginput = ParserInput([9])
		XCTAssert(leftside.parse(wronginput) == rightside.parse(wronginput))
	}

	// m >>= return = m
	func testRightIdentityLaw () {
		let leftside =	token(1) >>- pure
		let rightside = token(1)

		let correctinput = ParserInput([1])
		XCTAssert(leftside.parse(correctinput) == rightside.parse(correctinput))
		let wronginput = ParserInput([9])
		XCTAssert(leftside.parse(wronginput) == rightside.parse(wronginput))
	}
}
