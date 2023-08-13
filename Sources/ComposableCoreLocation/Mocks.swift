import CoreLocation

extension LocationClient {
	static let noop: Self = {
		// NB: CLLocationManager mostly does not work in SwiftUI previews, so we provide a mock
		//     manager that has all authorization allowed and mocks the device's current location
		//     to Brooklyn, NY.
		let (locationManager, locationManagerContinuation) = Self.mockClientWithContinuation()

		return locationManager
	}()
	
	/// Helpers for creating basic mock version of `LocationManager` and exposes `delegateContinuation` for firing delegate actins during tests.
	public static func mockClientWithContinuation() -> (locationClient: Self, delegateContinuation: AsyncStream<LocationClient.Action>.Continuation) {
		let (locationClientStream, delegateContinuation) = AsyncStream<LocationClient.Action>.makeStream()
		
		let locationClient = LocationClient(
			authorizationStatus: { .authorizedWhenInUse },
			delegate: {
				defer {
					delegateContinuation.yield(.didUpdateLocations([.mockBrooklyn]))
				}
				delegateContinuation.onTermination = { [locationClientStream] _ in
					_ = locationClientStream
				}
				return locationClientStream
			},
			location: { .mockBrooklyn },
			locationServicesEnabled: { true },
			requestLocation: {
				delegateContinuation.yield(.didUpdateLocations([.mockBrooklyn]))
			},
			requestWhenInUseAuthorization: { }
		)
		
		return (locationClient: locationClient, delegateContinuation: delegateContinuation)
	}
	
	public static let mock: Self = {
		Self.mockClientWithContinuation().locationClient
	}()
	
	public static let mockFromLive: Self = {
		var locationClient = Self.live()
		let (locationClientStream, delegateContinuation) = AsyncStream<LocationClient.Action>.makeStream()
		
		locationClient.authorizationStatus = { .authorizedWhenInUse }
		locationClient.delegate = {
			delegateContinuation.onTermination = { [locationClientStream] _ in
				_ = locationClientStream
			}
			return locationClientStream
		}
		locationClient.location = { .mockBrooklyn }
		locationClient.locationServicesEnabled = { true }
		locationClient.requestLocation = {
			delegateContinuation.yield(.didUpdateLocations([.mockBrooklyn]))
		}
		locationClient.requestWhenInUseAuthorization = { }
		
		return locationClient
	}()
}
