import CoreLocation
import Foundation

public struct GeocoderClient {
	public var reverseGeocodeLocation: @Sendable (Location) async throws -> Placemark
	public var geocodeAddressString: @Sendable (String, CLRegion?, Locale?) async throws -> [Placemark]
	
	public func getAddressCoordinates(
		_ addressString: String,
		in region: CLRegion?,
		preferredLocale locale: Locale?
	) async throws -> [Placemark] {
		try await self.geocodeAddressString(addressString, region, locale)
	}
}
