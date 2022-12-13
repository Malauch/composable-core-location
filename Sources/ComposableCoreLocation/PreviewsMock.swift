import CoreLocation

extension LocationManager {
	static let noop: Self = {
		// NB: CLLocationManager mostly does not work in SwiftUI previews, so we provide a mock
		//     manager that has all authorization allowed and mocks the device's current location
		//     to Brooklyn, NY.
//		let mockLocation = Location(
//			coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958)
//		)
//		let (locationManagerStream, locationManagerContinuation) = AsyncStream<LocationManager.Action>.streamWithContinuation()
//
//		var locationManager = LocationManager.live
//		locationManager.authorizationStatus = { .authorizedAlways }
//		locationManager.delegate = { locationManagerStream }
//		locationManager.locationServicesEnabled = { true }
//		locationManager.requestLocation = {
//			locationManagerContinuation.yield(.didUpdateLocations([mockLocation]))
//		}
//
//		return locationManager
		
		LocationManager.failing
	}()
}


extension AsyncStream {
	public static func streamWithContinuation(
		_ elementType: Element.Type = Element.self,
		bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
	) -> (stream: Self, continuation: Continuation) {
		var continuation: Continuation!
		return (Self(elementType, bufferingPolicy: limit) { continuation = $0 }, continuation)
	}
}
