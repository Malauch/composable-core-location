import Combine
import CoreLocation
import Dependencies

extension LocationManager {
	
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
	public static func live() -> Self {
		@Dependency(\.coreLocationManager) var manager
		
    return Self(
      authorizationStatus: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return manager.authorizationStatus
          }
        #endif
        return manager.authorizationStatus
      },
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
      location: { manager.location.map(Location.init(rawValue:)) },
      requestLocation: {
        manager.requestLocation()
      },
      requestWhenInUseAuthorization: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.requestWhenInUseAuthorization()
        #endif
      }
    )
  }
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  let continuation: AsyncStream<LocationManager.Action>.Continuation

  init(continuation: AsyncStream<LocationManager.Action>.Continuation) {
    self.continuation = continuation
  }
	
	deinit {
		print("LocationManager Deinit")
	}

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    self.continuation.yield(.didChangeAuthorization(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
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
