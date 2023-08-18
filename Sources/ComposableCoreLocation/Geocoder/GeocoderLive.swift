import CoreLocation
import Foundation

extension GeocoderClient {
	public static let live: Self = {
		let reverseGeocodeLocation: @Sendable (Location) async throws -> Placemark = { location in
			let geocoder = CLGeocoder()
			if let placemark = try await geocoder.reverseGeocodeLocation(location.rawValue).first {
				return Placemark(rawValue: placemark)
			} else {
				throw NoPlacemarkFound()
			}
			
		}
		
		#if os(visionOS)
		let geocodeAddressString: @Sendable (String) async throws -> [Placemark] = { addressString in
			let geocoder = CLGeocoder()
			return try await geocoder.geocodeAddressString(
				addressString
			)
			.map(Placemark.init(rawValue:))
		}
		#else
		let geocodeAddressString: @Sendable (String, Region?, Locale?) async throws -> [Placemark] = { addressString, region, locale in
			let geocoder = CLGeocoder()
			return try await geocoder.geocodeAddressString(
				addressString,
				in: region?.rawValue,
				preferredLocale: locale
			).map(Placemark.init(rawValue:))
		}
		#endif
		
		return Self(
			reverseGeocodeLocation: reverseGeocodeLocation,
			geocodeAddressString: geocodeAddressString
		)
	}()
}

extension GeocoderClient {
	public struct NoPlacemarkFound: Error, LocalizedError {
		let errorDescription = "No placemark found"
	}
}
