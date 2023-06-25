import Foundation
import CoreLocation
import Contacts

public struct Placemark: Sendable, Hashable, Codable {
	let name: String?
	let thoroughfare: String?
	let subThoroughfare: String?
	let locality: String?
	let subLocality: String?
	let administrativeArea: String?
	let subAdministrativeArea: String?
	let postalCode: String?
	let isoCountryCode: String?
	let country: String?
	let inlandWater: String?
	let ocean: String?
	let areasOfInterest: [String]?
	
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

