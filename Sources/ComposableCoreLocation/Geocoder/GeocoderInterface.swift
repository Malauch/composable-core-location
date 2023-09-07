import CoreLocation
import Foundation

public struct GeocoderClient {
	public var cancelGeocoding: @Sendable () async -> Void
	
	#if os(visionOS)
	public var geocodeAddressString: @Sendable (String) async throws -> [Placemark]
	#else
	public var geocodeAddressString: @Sendable (String, Region?, Locale?) async throws -> [Placemark]
	#endif
	
#if os(visionOS)
	public func getAddressCoordinates(
		_ addressString: String
	) async throws -> [Placemark] {
		try await self.geocodeAddressString(addressString)
	}
#else
	public func getAddressCoordinates(
		_ addressString: String,
		in region: Region?,
		preferredLocale locale: Locale?
	) async throws -> [Placemark] {
		try await self.geocodeAddressString(addressString, region, locale)
	}
#endif
	
	public var isGeocoding: @Sendable () async -> Bool
	public var reverseGeocodeLocation: @Sendable (Location) async throws -> Placemark
}
