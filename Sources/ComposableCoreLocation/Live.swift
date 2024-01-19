import Combine
import CoreLocation
import Dependencies
import OSLog

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
		let manager = MainActorIsolated(initialValue: { CLLocationManager() })
		/// Task which is used as a suspension point for all endpoints which needs configured CLLocationManagerDelegate.
		/// When delegate is configured, then this task is canceled and endpoints, which await it can continue execution.
		///
		/// This behaviour is useful for situation when starting observing delegate action stream and requesting location
		/// is done in the same async effect.
		let delegateIsReadyTask = LockIsolated(Task { try await Task.never() })
		// Subject instead of stream because it support multiple subscribers. Which probably should be still avoided.
		let subject = PassthroughSubject<LocationClient.Action, Never>()
		
    return Self(
      authorizationStatus: {
				return await manager.value.authorizationStatus
      },
			continuation: { nil },
			// MARK: - Delegate definition
      delegate: {
				let delegate = LocationManagerDelegateSubject(subject: subject)
				manager.value.delegate = delegate
				delegateIsReadyTask.value.cancel()
				
				return subject
					.handleEvents(
						receiveCancel: {
							delegateIsReadyTask.setValue(Task { try await Task.never() })
							_ = delegate
							_ = manager
						}
					)
					.values
					.eraseToStream()
			},
			get: {
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
				return await manager.value.location.map(Location.init(rawValue:))
			},
			liveUpdates: { configuration in
				return CLLocationUpdate.liveUpdates(configuration)
					.map(LocationUpdate.init(rawValue:))
					.eraseToThrowingStream()
			},
			locationServicesEnabled: { CLLocationManager.locationServicesEnabled() },
      requestLocation: {
				if !delegateIsReadyTask.value.isCancelled {
					logger.warning("LocationClient.requestLocation called before delegate endpoint. Execution is suspended and will continue when delegate will be configured.")
				}
				try? await delegateIsReadyTask.value.value

				await manager.value.requestLocation()
      },
      requestWhenInUseAuthorization: {
        #if os(iOS) || os(macOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
				await manager.value.requestWhenInUseAuthorization()
        #endif
      },
			requestAlwaysAuthorization: {
				#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
				await manager.value.requestAlwaysAuthorization()
				#endif
			},
			set: { properties in
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

private final class LocationManagerDelegateSubject: NSObject, CLLocationManagerDelegate {
	let subject: PassthroughSubject<LocationClient.Action, Never>
	
	init(subject: PassthroughSubject<LocationClient.Action, Never>) {
		self.subject = subject
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.subject.send(.didChangeAuthorization)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let error = CLError(_nsError: error as NSError)
		self.subject.send(.didFailWithError(error))
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.subject.send(.didUpdateLocations(locations.map(Location.init(rawValue:))))
	}
	
}

@MainActor
final class MainActorIsolated<Value>: Sendable {
	public lazy var value: Value = initialValue()
	private let initialValue: @MainActor () -> Value
	nonisolated public init(initialValue: @MainActor @escaping () -> Value) {
		self.initialValue = initialValue
	}
}

fileprivate let logger = Logger(subsystem: "composable-core-location", category: "Live client")
