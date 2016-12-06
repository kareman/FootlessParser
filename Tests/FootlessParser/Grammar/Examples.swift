//
// Examples.swift
// FootlessParser
//
// Created by Kåre Morstøl on 17.06.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import FootlessParser
import XCTest

class Examples: XCTestCase {

	func testXMLTagParser () {

		let opentag = char("<") *> oneOrMore(not(">")) <* char(">")
		let closetag = { (tagname: String) in char("<") *> tokens(tagname) <* tokens("/>") }

		let tag = tuple <^> opentag <*> oneOrMore(not("<")) >>- { (name, content) in
			return { _ in (name, content) } <^> closetag(name)
		}

		let (name, content) = try! parse(tag, "<a>content<a/>")
		
		XCTAssertEqual(name, "a")
		XCTAssertEqual(content, "content")

		assertParseFails(tag, "<a>content<b/>")
		assertParseFails(tag, "a content<a/>")
		assertParseFails(tag, "<a><a/>")
	}

	func testRecursiveExpressionParser () {
        func add (a:Int) -> (Int) -> Int { return { b in a + b } }
        func multiply (a:Int) -> (Int) -> Int { return { b in a * b } }

		let nr = {Int($0)!} <^> oneOrMore(oneOf("0123456789"))

		var expression: Parser<Character, Int>!

		let factor = nr <|> lazy( char("(") *> expression <* char(")") )

		var term: Parser<Character, Int>!
		term = lazy( multiply <^> factor <* char("*") <*> term <|> factor )

		expression = lazy( add <^> term <* char("+") <*> expression <|> term )

		assertParseSucceeds(expression, "12", result: 12)
		assertParseSucceeds(expression, "1+2+3", result: 6)
		assertParseSucceeds(expression, "(1+2)", result: 3)
		assertParseSucceeds(expression, "(1+(2+4))+3", result: 10)
		assertParseSucceeds(expression, "12*(3+1)", result: 48)
		assertParseSucceeds(expression, "12*3+1", result: 37)
	}
}
