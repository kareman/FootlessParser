//
// CSV.swift
// FootlessParser
//
// Created by Kåre Morstøl on 05.06.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest

let delimiter = "," as Character
let quote = "\"" as Character
let newline = "\n" as Character

let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote)
			<|> zeroOrMore(noneOf([delimiter, newline]))

let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)


class CSV: XCTestCase {

	func testCell () {
		assertParseSucceeds (cell, "row", result: "row")
		assertParseSucceeds (cell, "\"quoted row\"", result: "quoted row")
	}

	func testRow () {
		XCTAssertEqual(parse (row, "alpha,bravo,\"charlie\",delta\n").value! , ["alpha", "bravo", "charlie", "delta"])
	}
}
