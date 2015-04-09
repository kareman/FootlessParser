//
// TestHelpers.swift
// FootlessParser
//
// Created by Kåre Morstøl on 09.04.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import Result
import XCTest

public func == <T:Equatable, U:Equatable> (lhs: (output:T, nextinput:U), rhs: (output:T, nextinput:U)) -> Bool {
	return lhs.output == rhs.output && lhs.nextinput == rhs.nextinput
}

public func == <R:Equatable, I:Equatable, E:Equatable> (lhs: Result<(output:R, nextinput:I), E>, rhs: Result<(output:R, nextinput:I), E>) -> Bool {
	if let leftvalue = lhs.value, rightvalue = rhs.value where leftvalue == rightvalue {
		return true
	} else if let lefterror = lhs.error, righterror = rhs.error where lefterror == righterror {
		return true
	}
	return false
}

public func != <R:Equatable, I:Equatable, E:Equatable> (lhs: Result<(output:R, nextinput:I), E>, rhs: Result<(output:R, nextinput:I), E>) -> Bool {
	return !(lhs == rhs)
}

extension XCTestCase {
	
	/**
	Verifies that 2 parsers return the same given the same input, whether it be success or failure.

	:param: shouldSucceed? Optionally verifies success or failure.
	*/
	func assertParsesEqually<T, R: Equatable>( # input: [T], _ p1: Parser<T,R>, _ p2: Parser<T,R>, shouldSucceed: Bool? = nil, file: String = __FILE__, line: UInt = __LINE__) {
		let i = ParserInput(input)
		let (r1, r2) = (p1.parse(i), p2.parse(i))
		if r1 != r2 {
			XCTFail("with input '\(input)': '\(r1)' != '\(r2)", file: file, line: line)
		}
		if let shouldSucceed = shouldSucceed {
			if shouldSucceed && (r1.value == nil) {
				XCTFail("parsing of '\(input)' failed, shoud have succeeded", file: file, line: line)
			}
			if !shouldSucceed && (r1.error == nil) {
				XCTFail("parsing of '\(input)' succeeded, shoud have failed", file: file, line: line)
			}
		}
	}
}
