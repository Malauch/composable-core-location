import CoreLocation
import Foundation

extension GeocoderClient {
	public static let live: Self = GeocoderClient(
		reverseGeocodeLocation: { location in
			let geocoder = CLGeocoder()
			if let placemark = try await geocoder.reverseGeocodeLocation(location.rawValue).first {
				return Placemark(rawValue: placemark)
			} else {
				throw NoPlacemarkFound()
			}
			
		},
		geocodeAddressString: { addressString, region, locale in
			let geocoder = CLGeocoder()
			return try await geocoder.geocodeAddressString(
				addressString,
				in: region,
				preferredLocale: locale
			).map(Placemark.init(rawValue:))
		}
	)
}

extension GeocoderClient {
	public struct NoPlacemarkFound: Error, LocalizedError {
		let errorDescription = "No placemark found"
	}
}
