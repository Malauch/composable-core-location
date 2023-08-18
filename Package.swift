// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "composable-core-location",
	platforms: [
		.iOS(.v14),
		.macOS(.v11),
		.tvOS(.v14),
		.watchOS(.v7),
		.visionOS(.v1)
	],
	products: [
		.library(
			name: "ComposableCoreLocation",
			targets: ["ComposableCoreLocation"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
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
