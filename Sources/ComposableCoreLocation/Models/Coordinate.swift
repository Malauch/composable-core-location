import CoreLocation

/// Controllable wrapper to `CLLocationCoordinate2D`.
public struct Coordinate: Codable, Equatable, Hashable {
	public let latitude: Double
	public let longitude: Double
	
	public var rawValue: CLLocationCoordinate2D {
		.init(latitude: self.latitude, longitude: self.longitude)
	}
	
	public init(rawValue: CLLocationCoordinate2D) {
		self.latitude = rawValue.latitude
		self.longitude = rawValue.longitude
	}
	
	public init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
}

extension Coordinate {
	public static let mock: Self = .init(rawValue: .mock)
}

extension CLLocationCoordinate2D {
	public static let mock = Self(latitude: 51.123456, longitude: 15.123456)
}
