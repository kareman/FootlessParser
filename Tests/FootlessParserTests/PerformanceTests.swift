//
//  PerformanceTests.swift
//  FootlessParser
//
//  Created by Bouke Haarsma on 16-05-16.
//
//

import FootlessParser
import XCTest

class PerformanceTests: XCTestCase {
    func testZeroOrMoreGeneric () {
        let parser = zeroOrMore(token(1))
        let input = Array(repeating: 1, count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testZeroOrMoreString () {
        let parser = zeroOrMore(char("a"))
        let input = String(repeating: "a", count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testOneOrMoreGeneric() {
        let parser = oneOrMore(token(1))

        assertParseSucceeds(parser, [1], result: [1], consumed: 1)
        assertParseSucceeds(parser, [1,1,1], result: [1,1,1], consumed: 3)
        assertParseSucceeds(parser, [1,1,1,9], result: [1,1,1], consumed: 3)

        let input = Array(repeating: 1, count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testOneOrMoreString () {
        let parser = oneOrMore(char("a"))

        assertParseSucceeds(parser, "a", result: "a")
        assertParseSucceeds(parser, "aaa", result: "aaa")
        assertParseSucceeds(parser, "aaab", result: "aaa", consumed: 3)

        let input = String(repeating: "a", count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testCount1000Generic () {
        let parser = count(1000, token(1))
        let input = Array(repeating: 1, count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testCount1000String () {
        let parser = count(1000, char("a"))
        let input = String(repeating: "a", count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testRange0To1000Generic () {
        let parser = count(0...1000, token(1))
        let input = Array(repeating: 1, count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testRange0To1000String () {
        let parser = count(0...1000, char("a"))
        let input = String(repeating: "a", count: 1000)
        measure {
            self.assertParseSucceeds(parser, input, consumed: 1000)
        }
    }

    func testBacktrackingLeftString() {
        let parser = string("food") <|> string("foot")
        measure {
            for _ in 0..<1000 {
                self.assertParseSucceeds(parser, "food")
            }
        }
    }

    func testBacktrackingRightString() {
        let parser = string("food") <|> string("foot")
        measure {
            for _ in 0..<1000 {
                self.assertParseSucceeds(parser, "foot")
            }
        }
    }

    func testBacktrackingFailString() {
        let parser = string("food") <|> string("foot")
        measure {
            for _ in 0..<1000 {
                self.assertParseFails(parser, "fool")
            }
        }
    }

    func testCSVRow() {
        measure {
            for _ in 0..<1000 {
                _ = try! parse(row, "Hello,\"Dear World\",\"Hello\",Again\n")
            }
        }
    }
}

extension PerformanceTests {
	public static var allTests = [
		("testZeroOrMoreGeneric", testZeroOrMoreGeneric),
		("testZeroOrMoreString", testZeroOrMoreString),
		("testOneOrMoreGeneric", testOneOrMoreGeneric),
		("testOneOrMoreString", testOneOrMoreString),
		("testCount1000Generic", testCount1000Generic),
		("testCount1000String", testCount1000String),
		("testRange0To1000Generic", testRange0To1000Generic),
		("testRange0To1000String", testRange0To1000String),
		("testBacktrackingLeftString", testBacktrackingLeftString),
		("testBacktrackingRightString", testBacktrackingRightString),
		("testBacktrackingFailString", testBacktrackingFailString),
		("testCSVRow", testCSVRow),
		]
}
