import Foundation
import CoreLocation
import Contacts

public struct Placemark: Sendable, Hashable, Codable {
	public let name: String?
	public let thoroughfare: String?
	public let subThoroughfare: String?
	public let locality: String?
	public let subLocality: String?
	public let administrativeArea: String?
	public let subAdministrativeArea: String?
	public let postalCode: String?
	public let isoCountryCode: String?
	public let country: String?
	public let inlandWater: String?
	public let ocean: String?
	public let areasOfInterest: [String]?
	
	public init(
		name: String? = nil,
		thoroughfare: String? = nil,
		subThoroughfare: String? = nil,
		locality: String? = nil,
		subLocality: String? = nil,
		administrativeArea: String? = nil,
		subAdministrativeArea: String? = nil,
		postalCode: String? = nil,
		isoCountryCode: String? = nil,
		country: String? = nil,
		inlandWater: String? = nil,
		ocean: String? = nil,
		areasOfInterest: [String]? = nil
	) {
		self.name = name
		self.thoroughfare = thoroughfare
		self.subThoroughfare = subThoroughfare
		self.locality = locality
		self.subLocality = subLocality
		self.administrativeArea = administrativeArea
		self.subAdministrativeArea = subAdministrativeArea
		self.postalCode = postalCode
		self.isoCountryCode = isoCountryCode
		self.country = country
		self.inlandWater = inlandWater
		self.ocean = ocean
		self.areasOfInterest = areasOfInterest
	}
	
	public init(rawValue: CLPlacemark) {
		self.name = rawValue.name
		self.thoroughfare = rawValue.thoroughfare
		self.subThoroughfare = rawValue.subThoroughfare
		self.locality = rawValue.locality
		self.subLocality = rawValue.subLocality
		self.administrativeArea = rawValue.administrativeArea
		self.subAdministrativeArea = rawValue.subAdministrativeArea
		self.postalCode = rawValue.postalCode
		self.isoCountryCode = rawValue.isoCountryCode
		self.country = rawValue.country
		self.inlandWater = rawValue.inlandWater
		self.ocean = rawValue.ocean
		self.areasOfInterest = rawValue.areasOfInterest
	}
}

