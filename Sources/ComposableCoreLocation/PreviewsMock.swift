import CoreLocation

extension LocationManager {
	static let noop: Self = {
		// NB: CLLocationManager mostly does not work in SwiftUI previews, so we provide a mock
		//     manager that has all authorization allowed and mocks the device's current location
		//     to Brooklyn, NY.
		let (locationManager, locationManagerContinuation) = Self.mock()

		return locationManager
	}()
	
	/// Helpers for creating basic mock version of `LocationManager` and exposes `delegateContinuation` for firing delegate actins during tests.
	public static func mock() -> (locationManager: Self, delegateContinuation: AsyncStream<LocationManager.Action>.Continuation) {
		let (locationManagerStream, locationManagerContinuation) = AsyncStream<LocationManager.Action>.streamWithContinuation()
		
		var locationManager = LocationManager.live
		locationManager.authorizationStatus = { .authorizedAlways }
		locationManager.delegate = { locationManagerStream }
		locationManager.locationServicesEnabled = { true }
		locationManager.requestLocation = {
			locationManagerContinuation.yield(.didUpdateLocations([.mockLocation]))
		}
		
		return (locationManager: locationManager, delegateContinuation: locationManagerContinuation)
	}
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
