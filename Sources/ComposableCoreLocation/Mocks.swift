import CoreLocation
import Dependencies

extension LocationClient {
	public static let mock: Self = {
		let (locationClientStream, delegateContinuation) = AsyncStream<LocationClient.Action>.makeStream()
		
		let locationClient = LocationClient(
			authorizationStatus: { .authorizedWhenInUse },
			continuation: { delegateContinuation },
			delegate: {
				delegateContinuation.onTermination = { [locationClientStream] _ in
					_ = locationClientStream
				}
				return locationClientStream
			},
			get: { Properties() },
			location: { .mockFluid() },
			locationServicesEnabled: { true },
			requestLocation: {
				delegateContinuation.yield(.didUpdateLocations([.mockFluid()]))
			},
			requestWhenInUseAuthorization: { },
			set: { _ in }
		)
		
		return locationClient
	}()
	
	/// Mock defined from live value. For now it's mostly useless but later it's just easier to define mock like this, with all the rules and properties for different platfom. For now it's just here to chekc if it's properly working.
	public static let mockFromLive: Self = {
		var locationClient = Self.live
		let continuation = ActorIsolated<AsyncStream<LocationClient.Action>.Continuation?>(nil)
		
		locationClient.authorizationStatus = { .authorizedWhenInUse }
		locationClient.continuation = { await continuation.value }
		locationClient.delegate = {
			let (locationClientStream, delegateContinuation) = AsyncStream<LocationClient.Action>.makeStream()
			await continuation.setValue(delegateContinuation)
			delegateContinuation.onTermination = { [locationClientStream] _ in
				_ = locationClientStream
			}
			return locationClientStream
		}
		locationClient.location = { .mockFluid() }
		locationClient.locationServicesEnabled = { true }
		locationClient.requestLocation = {
			guard let continuation = await continuation.value
			else {
				XCTFail("No continuation exists for mock value of location client")
				return
			}
			continuation.yield(.didUpdateLocations([.mockFluid()]))
		}
		locationClient.requestWhenInUseAuthorization = { }
		
		return locationClient
	}()
}
