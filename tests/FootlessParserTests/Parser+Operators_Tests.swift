//
//  Parser+Operators_Tests.swift
//  FootlessParser
//
//  Created by Kåre Morstøl on 06.04.15.
//  Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import Runes
import XCTest
import LlamaKit

public func == <T:Equatable,U:Equatable>(lhs:  (output:T, nextinput:U), rhs:  (output:T, nextinput:U)) -> Bool {
	let (l0,l1) = lhs
	let (r0,r1) = rhs
	return l0 == r0 && l1 == r1
}


public func  == <T:Equatable, U:Equatable, E:Equatable> (lhs: Result< (output:T, nextinput:U), E>, rhs: Result< (output:T, nextinput:U), E>) -> Bool {
	switch (lhs, rhs) {
	case let (.Success(l), .Success(r)): return l.unbox == r.unbox
	case let (.Failure(l), .Failure(r)): return l.unbox == r.unbox
	default: return false
	}
}


class Parser_Operators_Tests: XCTestCase {

	func  testPure () {
/* 		XCTAssert((  output: 1, 1)  ==  (1, 1))
		let left = success( (  1, 1)) as Result < (Int, Int), Int>
		let right = success( ( 1, 1)) as Result < (Int, Int), Int>

		 print( left  ==  right )
		XCTAssert(left  ==  right)
*/	}

	// pure a >>= f  =  f a
	func   testFlatMapObeysTheLeftIdentityLaw  () {
		let input = ParserInput([11])

		let leftside = pure(1)  >>-  token
		let rightside  = token(1)

		XCTAssert(leftside.parse (input)  == rightside.parse (input))
	}
}

