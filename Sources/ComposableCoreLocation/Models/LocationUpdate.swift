import CoreLocation

public struct LocationUpdate: Equatable, Codable {
	public let location: Location?
	public let isStationary: Bool
	
	public init(location: Location?, isStationary: Bool) {
		self.location = location
		self.isStationary = isStationary
	}
	
	public init(rawValue: CLLocationUpdate) {
		if let location = rawValue.location {
			self.location = Location(rawValue: location)
		} else {
			self.location = nil
		}
		self.isStationary = rawValue.isStationary
	}
}
