// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "composable-core-location",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
		.tvOS(.v17),
		.watchOS(.v10),
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
