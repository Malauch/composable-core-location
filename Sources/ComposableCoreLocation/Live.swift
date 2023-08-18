import Combine
import CoreLocation
import Dependencies

extension LocationClient {
	
  /// The live implementation of the `LocationManager` interface. This implementation is capable of
  /// creating real `CLLocationManager` instances, listening to its delegate methods, and invoking
  /// its methods. You will typically use this when building for the simulator or device:
  ///
  /// ```swift
  /// let store = Store(
  ///   initialState: AppState(),
  ///   reducer: appReducer,
  ///   environment: AppEnvironment(
  ///     locationManager: LocationManager.live
  ///   )
  /// )
  /// ```

	public static let live: Self = {
		let manager = CLLocationManager()
		
    return Self(
      authorizationStatus: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return manager.authorizationStatus
          }
        #endif
        return manager.authorizationStatus
      },
			continuation: { nil },
			// MARK: - Delegate definition
      delegate: { @MainActor in
				AsyncStream { continuation in
					let delegate = LocationManagerDelegate(continuation: continuation)
					manager.delegate = delegate
					continuation.onTermination = { [delegate] _ in
						_ = delegate
					}
				}
			},
			get: {
				var properties = Properties()
				
					#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
					properties.activityType = manager.activityType
					properties.allowsBackgroundLocationUpdates = manager.allowsBackgroundLocationUpdates
					#endif

					#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
					properties.desiredAccuracy = manager.desiredAccuracy
					properties.distanceFilter =	manager.distanceFilter
					#endif

					#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
					properties.headingFilter = manager.headingFilter
					properties.headingOrientation =	manager.headingOrientation
					
					#endif
					#if os(iOS) || targetEnvironment(macCatalyst)
					properties.pausesLocationUpdatesAutomatically = manager.pausesLocationUpdatesAutomatically
					properties.showsBackgroundLocationIndicator = manager.showsBackgroundLocationIndicator
					
					#endif
				
				return properties
			},
      location: { manager.location.map(Location.init(rawValue:)) },
			locationServicesEnabled: { CLLocationManager.locationServicesEnabled() },
      requestLocation: {
        manager.requestLocation()
      },
      requestWhenInUseAuthorization: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.requestWhenInUseAuthorization()
        #endif
      },
			set: { properties in
				#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
				if let activityType = properties.activityType {
					manager.activityType = activityType
				}
				if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
					manager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
				}
				#endif
				#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
				if let desiredAccuracy = properties.desiredAccuracy {
					manager.desiredAccuracy = desiredAccuracy
				}
				if let distanceFilter = properties.distanceFilter {
					manager.distanceFilter = distanceFilter
				}
				#endif
				#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
				if let headingFilter = properties.headingFilter {
					manager.headingFilter = headingFilter
				}
				if let headingOrientation = properties.headingOrientation {
					manager.headingOrientation = headingOrientation
				}
				#endif
				#if os(iOS) || targetEnvironment(macCatalyst)
				if let pausesLocationUpdatesAutomatically = properties
					.pausesLocationUpdatesAutomatically
				{
					manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
				}
				if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
					manager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
				}
				#endif
			}
    )
  }()
}

private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	let continuation: AsyncStream<LocationClient.Action>.Continuation
	
	init(continuation: AsyncStream<LocationClient.Action>.Continuation) {
		self.continuation = continuation
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.continuation.yield(.didChangeAuthorization)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let error = CLError(_nsError: error as NSError)
		self.continuation.yield(.didFailWithError(error))
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.continuation.yield(.didUpdateLocations(locations.map(Location.init(rawValue:))))
	}
	
}

// Fileprivate `CLLocationManager` instance as a dependency to workaround the bug mentioned in line #20.
extension CLLocationManager: DependencyKey {
	public static var liveValue = CLLocationManager()
}

fileprivate extension DependencyValues {
	var coreLocationManager: CLLocationManager {
		get { self[CLLocationManager.self] }
		set { self[CLLocationManager.self] = newValue}
	}
}
