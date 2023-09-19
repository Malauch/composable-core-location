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

	public static var live: Self {
		
    return Self(
      authorizationStatus: {
				@Dependency(\.coreLocationManager) var manager
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
						return await manager.value.authorizationStatus
          }
        #endif
				return await manager.value.authorizationStatus
      },
			continuation: { nil },
			// MARK: - Delegate definition
      delegate: {
				@Dependency(\.coreLocationManager) var managerIsolated
				let manager = await managerIsolated.value
				// Probably AsyncChannel is more correct here: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md
				// Or other workaround is needed for situation when there are multiple subscribers.
				return AsyncStream { continuation in
					let delegate = LocationManagerDelegate(continuation: continuation)
					manager.delegate = delegate
					continuation.onTermination = { [delegate] _ in
						_ = delegate
					}
				}
			},
			get: {
				// TODO: Add visionOS checks
				@Dependency(\.coreLocationManager) var manager
				var properties = Properties()
				
					#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
					properties.activityType = await manager.value.activityType
					properties.allowsBackgroundLocationUpdates = await manager.value.allowsBackgroundLocationUpdates
					#endif

					#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
					properties.desiredAccuracy = await manager.value.desiredAccuracy
					properties.distanceFilter =	await manager.value.distanceFilter
					#endif

					#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
					properties.headingFilter = await manager.value.headingFilter
					properties.headingOrientation =	await manager.value.headingOrientation
					
					#endif
					#if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
					properties.pausesLocationUpdatesAutomatically = await manager.value.pausesLocationUpdatesAutomatically
					properties.showsBackgroundLocationIndicator = await manager.value.showsBackgroundLocationIndicator
					
					#endif
				
				return properties
			},
			location: {
				@Dependency(\.coreLocationManager) var manager
				return await manager.value.location.map(Location.init(rawValue:))
			},
			liveUpdates: { configuration in
				return CLLocationUpdate.liveUpdates(configuration)
					.map(LocationUpdate.init(rawValue:))
					.eraseToThrowingStream()
			},
			locationServicesEnabled: { CLLocationManager.locationServicesEnabled() },
      requestLocation: {
				@Dependency(\.coreLocationManager) var manager
				await manager.value.requestLocation()
      },
      requestWhenInUseAuthorization: {
				@Dependency(\.coreLocationManager) var manager
        #if os(iOS) || os(macOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
				await manager.value.requestWhenInUseAuthorization()
        #endif
      },
			set: { properties in
				@Dependency(\.coreLocationManager) var manager
				#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
				if let activityType = properties.activityType {
					await manager.value.activityType = activityType
				}
				if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
					await manager.value.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
				}
				#endif
				#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
				if let desiredAccuracy = properties.desiredAccuracy {
					await manager.value.desiredAccuracy = desiredAccuracy
				}
				if let distanceFilter = properties.distanceFilter {
					await manager.value.distanceFilter = distanceFilter
				}
				#endif
				#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
				if let headingFilter = properties.headingFilter {
					await manager.value.headingFilter = headingFilter
				}
				if let headingOrientation = properties.headingOrientation {
					await manager.value.headingOrientation = headingOrientation
				}
				#endif
				#if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
				if let pausesLocationUpdatesAutomatically = properties
					.pausesLocationUpdatesAutomatically
				{
					await manager.value.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
				}
				if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
					await manager.value.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
				}
				#endif
			}
    )
  }
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

extension CLLocationManager: DependencyKey {
	public static var liveValue: MainActorIsolated<CLLocationManager> = {
		return MainActorIsolated(initialValue: { CLLocationManager() })
	}()
}

fileprivate extension DependencyValues {
	var coreLocationManager: MainActorIsolated<CLLocationManager> {
		get { self[CLLocationManager.self] }
		set { self[CLLocationManager.self] = newValue}
	}
}

@MainActor
public final class MainActorIsolated<Value>: Sendable {
	public lazy var value: Value = initialValue()
	private let initialValue: @MainActor () -> Value
	nonisolated public init(initialValue: @MainActor @escaping () -> Value) {
		self.initialValue = initialValue
	}
}
