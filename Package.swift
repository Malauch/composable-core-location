// swift-tools-version:5.6

import PackageDescription

let package = Package(
	name: "composable-core-location",
	platforms: [
		.iOS(.v14),
		.macOS(.v11),
		.tvOS(.v14),
		.watchOS(.v7),
	],
	products: [
		.library(
			name: "ComposableCoreLocation",
			targets: ["ComposableCoreLocation"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.0")
	],
	targets: [
		.target(
			name: "ComposableCoreLocation",
			dependencies: [
				.product(name: "Dependencies", package: "swift-dependencies"),
			]
		),
		.testTarget(
			name: "ComposableCoreLocationTests",
			dependencies: ["ComposableCoreLocation"]
		),
	]
)
