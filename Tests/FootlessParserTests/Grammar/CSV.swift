//
// CSV.swift
// FootlessParser
//
// Created by Kåre Morstøl on 05.06.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest
import Foundation

let delimiter = "," as Character
let quote = "\"" as Character
let newline = "\n" as Character

let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote)
			<|> zeroOrMore(noneOf([delimiter, newline]))

let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)


class CSV: XCTestCase {

	func testCell () {
		assertParseSucceeds(cell, "row", result: "row")
		assertParseSucceeds(cell, "\"quoted row\"", result: "quoted row")
	}

	func testRow () {
		assertParseSucceeds(row, "alpha,bravo,\"charlie\",delta\n", result: ["alpha", "bravo", "charlie", "delta"])
	}

	func testParseCSVQuotesReturningArray () {
          let filepath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("CSV-quotes.csv").path
          let movieratings = try! String(contentsOfFile: filepath, encoding: .utf8)

		measure {
			do {
				let result = try parse(zeroOrMore(row), movieratings)
				XCTAssertEqual(result.count, 101)
			} catch {
				XCTFail(String(describing: error))
			}
		}
	}

	func testParseLargeCSVQuotesReturningArray () {
          let filepath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("CSV-quotes-large.csv").path
          let movieratings = try! String(contentsOfFile: filepath, encoding: .utf8)

		measure {
			do {
				let result = try parse(zeroOrMore(row), movieratings)
				XCTAssertEqual(result.count, 1715)
			} catch {
				XCTFail(String(describing: error))
			}
		}
	}
}

extension CSV {
	public static var allTests = [
		("testCell", testCell),
		("testRow", testRow),
		("testParseCSVQuotesReturningArray", testParseCSVQuotesReturningArray),
		("testParseLargeCSVQuotesReturningArray", testParseLargeCSVQuotesReturningArray),
		]
}
