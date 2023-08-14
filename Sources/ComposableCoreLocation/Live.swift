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
	public static func live() -> Self {
		@Dependency(\.coreLocationManager) var manager
		@Dependency(\.locationManagerDelegate) var managerDelegate
		
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
					managerDelegate.continuation = continuation
					manager.delegate = managerDelegate
					continuation.onTermination = { [managerDelegate] _ in
						_ = managerDelegate
					}
				}
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
      }
    )
  }
}

public class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	public typealias Continuation = AsyncStream<LocationClient.Action>.Continuation
	
  public var continuation: Continuation?
	public var didChangeAuthorization: (Continuation?, CLAuthorizationStatus) -> Void
	public var didFailWithError: (Continuation?, Error) -> Void
	public var didUpdateLocation: (Continuation?, [CLLocation]) -> Void
	
	init(
		continuation: AsyncStream<LocationClient.Action>.Continuation? = nil,
		didChangeAuthorization: @escaping (Continuation?, CLAuthorizationStatus) -> Void,
		didFailWithError: @escaping (Continuation?, Error) -> Void,
		didUpdateLocation: @escaping (Continuation?, [CLLocation]) -> Void
	) {
		self.continuation = nil
		self.didChangeAuthorization = didChangeAuthorization
		self.didFailWithError = didFailWithError
		self.didUpdateLocation = didUpdateLocation
	}

	public func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
		self.didChangeAuthorization(self.continuation, status)
  }

	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.didFailWithError(self.continuation, error)
  }

	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.didUpdateLocation(self.continuation, locations)
  }
}

extension LocationManagerDelegate: DependencyKey {
	public static var liveValue: LocationManagerDelegate {
		LocationManagerDelegate(
			continuation: nil,
			didChangeAuthorization: { continuation, authStatus in
				guard let continuation else {
					XCTFail("Delegate continuation is nil")
					return
				}
				continuation.yield(.didChangeAuthorization(authStatus))
			},
			didFailWithError: { continuation, error in
				guard let continuation else {
					XCTFail("Delegate continuation is nil")
					return
				}
				continuation.yield(.didFailWithError(error))
			},
			didUpdateLocation: { continuation, location in
				guard let continuation else {
					XCTFail("Delegate continuation is nil")
					return
				}
				continuation.yield(.didUpdateLocations(location.map(Location.init(rawValue:))))
			}
		)
	}
}

extension DependencyValues {
	public var locationManagerDelegate: LocationManagerDelegate {
		get { self[LocationManagerDelegate.self] }
		set { self[LocationManagerDelegate.self] = newValue }
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
