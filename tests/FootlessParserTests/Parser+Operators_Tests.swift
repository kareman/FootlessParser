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

class FlatMap_Tests: XCTestCase {

	// return a >>= f = f a
	func testLeftIdentityLaw () {
		let leftside = pure(1) >>- token
		let rightside = token(1)

		assertParsesEqually(input: [1], leftside, rightside, shouldSucceed: true)
		assertParsesEqually(input: [9], leftside, rightside, shouldSucceed: false)
	}

	// m >>= return = m
	func testRightIdentityLaw () {
		let leftside = token(1) >>- pure
		let rightside = token(1)

		assertParsesEqually(input: [1], leftside, rightside, shouldSucceed: true)
		assertParsesEqually(input: [9], leftside, rightside, shouldSucceed: false)
	}

	// (m >>= f) >>= g = m >>= (\x -> f x >>= g)
	func testAssociativityLaw () {
		func timesTwo(x: Int) -> Parser<Int,Int> {
			let x2 = x * 2
			return satisfy(expect: "\(x2)") { $0 == x2 }
		}

		let leftside = (any() >>- token) >>- timesTwo
		let rightside = any() >>- { token($0) >>- timesTwo }

		assertParsesEqually(input: [1,1,2], leftside, rightside, shouldSucceed: true)
		assertParsesEqually(input: [9,9,9], leftside, rightside, shouldSucceed: false)

		let noparens = any() >>- token >>- timesTwo
		assertParsesEqually(input: [1,1,2], leftside, noparens, shouldSucceed: true)
		assertParsesEqually(input: [9,9,9], leftside, noparens, shouldSucceed: false)
	}
}
