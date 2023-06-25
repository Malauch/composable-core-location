import CoreLocation
import Foundation

extension GeocoderClient {
	public static let live: Self = GeocoderClient(
		reverseGeocodeLocation: { location in
			let geocoder = CLGeocoder()
			if let placemark = try await geocoder.reverseGeocodeLocation(location.rawValue).first {
				return Placemark(rawValue: placemark)
			} else {
				return nil
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
