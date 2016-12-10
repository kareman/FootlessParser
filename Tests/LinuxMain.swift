
import XCTest

@testable import FootlessParserTests

let tests: [XCTestCaseEntry] = [
	testCase(CSV.allTests),
	testCase(Examples.allTests),
	testCase(Pure_Tests.allTests),
	testCase(FlatMap_Tests.allTests),
	testCase(Map_Tests.allTests),
	testCase(Apply_Tests.allTests),
	testCase(Choice_Tests.allTests),
	testCase(Parser_Tests.allTests),
	testCase(PerformanceTests.allTests),
	testCase(StringParser_Tests.allTests),
	]

XCTMain(tests)
