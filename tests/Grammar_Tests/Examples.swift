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
}
