import CoreLocation
import Foundation

extension GeocoderClient {
	public static var live: Self {
		let geocoder = CLGeocoder()

		let reverseGeocodeLocation: @Sendable (Location) async throws -> Placemark = { location in
			if let placemark = try await geocoder.reverseGeocodeLocation(location.rawValue).first {
				return Placemark(rawValue: placemark)
			} else {
				throw NoPlacemarkFound()
			}
			
		}
		
		#if os(visionOS)
		let geocodeAddressString: @Sendable (String) async throws -> [Placemark] = { addressString in
			return try await geocoder.geocodeAddressString(
				addressString
			)
			.map(Placemark.init(rawValue:))
		}
		#else
		let geocodeAddressString: @Sendable (String, Region?, Locale?) async throws -> [Placemark] = { addressString, region, locale in
			return try await geocoder.geocodeAddressString(
				addressString,
				in: region?.rawValue,
				preferredLocale: locale
			).map(Placemark.init(rawValue:))
		}
		#endif
		
		return Self(
			cancelGeocoding: { geocoder.cancelGeocode() },
			geocodeAddressString: geocodeAddressString,
			isGeocoding: { geocoder.isGeocoding },
			reverseGeocodeLocation: reverseGeocodeLocation
		)
	}
}

extension GeocoderClient {
	public struct NoPlacemarkFound: Error, LocalizedError {
		let errorDescription = "No placemark found"
	}
}
