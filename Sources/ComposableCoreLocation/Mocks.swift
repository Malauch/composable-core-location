import CoreLocation
import Dependencies

extension LocationClient {
	public static let mock: Self = {
		let (locationClientStream, delegateContinuation) = AsyncStream<LocationClient.Action>.makeStream()
		
		let locationClient = LocationClient(
			authorizationStatus: { .authorizedWhenInUse },
			continuation: { delegateContinuation },
			delegate: {
				defer {
					delegateContinuation.yield(.didChangeAuthorization(.authorizedWhenInUse))
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
		
		return locationClient
	}()
	
	public static let mockUsingDelegate: Self = {
		@Dependency(\.locationManagerDelegate) var delegate
		
		return Self(
			authorizationStatus: { .authorizedWhenInUse },
			delegate:  {
				AsyncStream { continuation in
					delegate.continuation = continuation
				}
			},
			location: { .mockFluid() },
			locationServicesEnabled: { true },
			requestLocation: { delegate.locationManager(.init(), didUpdateLocations: [Location.mockFluid().rawValue]) },
			requestWhenInUseAuthorization: { }
		)
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
