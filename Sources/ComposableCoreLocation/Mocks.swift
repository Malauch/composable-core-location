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
			location: { .mockFluid() },
			locationServicesEnabled: { true },
			requestLocation: {
				delegateContinuation.yield(.didUpdateLocations([.mockFluid()]))
			},
			requestWhenInUseAuthorization: { }
		)
		
		return locationClient
	}()
	
	/// Mock defined from live value. For now it's mostly useless but later it's just easier to define mock like this, with all the rules and properties for different platfom. For now it's just here to chekc if it's properly working.
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
		locationClient.location = { .mockFluid() }
		locationClient.locationServicesEnabled = { true }
		locationClient.requestLocation = {
			delegateContinuation.yield(.didUpdateLocations([.mockFluid()]))
		}
		locationClient.requestWhenInUseAuthorization = { }
		
		return locationClient
	}()
}
