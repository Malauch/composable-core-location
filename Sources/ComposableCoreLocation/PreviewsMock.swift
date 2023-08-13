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
		let (locationManagerStream, locationManagerContinuation) = AsyncStream<LocationManager.Action>.makeStream()
		
		let locationManager = LocationManager(
			authorizationStatus: { .authorizedWhenInUse },
			delegate: {
				locationManagerContinuation.onTermination = { [locationManagerStream] _ in
					_ = locationManagerStream
				}
				return locationManagerStream
			},
			location: { .mockLocation },
			requestLocation: {
				locationManagerContinuation.yield(.didUpdateLocations([.mockLocation]))
			},
			requestWhenInUseAuthorization: { }
		)
		
		return (locationManager: locationManager, delegateContinuation: locationManagerContinuation)
	}
}
