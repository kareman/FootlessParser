// swift-tools-version:4.1

import PackageDescription

let package = Package(
	name: "FootlessParser",
	products: [
		.library(name: "FootlessParser", targets: ["FootlessParser"]),
		],
	targets: [
		.target(name: "FootlessParser"),
		.testTarget(name: "FootlessParserTests", dependencies: ["FootlessParser"]),
		]
)
