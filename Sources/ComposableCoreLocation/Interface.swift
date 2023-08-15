import Combine
import CoreLocation

/// A wrapper around Core Location's `CLLocationManager` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
public struct LocationClient {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
  public enum Action {
    case didChangeAuthorization(CLAuthorizationStatus)
    case didFailWithError(Error)
    case didUpdateLocations([Location])
  }
	
	public init(
		authorizationStatus: @Sendable @escaping () async -> CLAuthorizationStatus,
		continuation: @Sendable @escaping () async -> AsyncStream<Action>.Continuation?,
		delegate: @MainActor @Sendable @escaping () async -> AsyncStream<Action>,
		get: @Sendable @escaping () -> Properties,
		location: @Sendable @escaping () async -> Location?,
		locationServicesEnabled: @Sendable @escaping () async -> Bool,
		requestLocation: @Sendable @escaping () async -> Void,
		requestWhenInUseAuthorization: @Sendable @escaping () async -> Void,
		set: @Sendable @escaping (Properties) async -> Void
	) {
		self.authorizationStatus = authorizationStatus
		self.continuation = continuation
		self.delegate = delegate
		self.get = get 
		self.location = location
		self.locationServicesEnabled = locationServicesEnabled
		self.requestLocation = requestLocation
		self.requestWhenInUseAuthorization = requestWhenInUseAuthorization
		self.set = set
	}

  public var authorizationStatus: @Sendable () async -> CLAuthorizationStatus
	
	public var continuation: @Sendable () async -> AsyncStream<Action>.Continuation?
	
	// MARK: - Delegate signature
  public var delegate: @MainActor @Sendable () async -> AsyncStream<Action>
	
	public var get: @Sendable () async -> Properties

  public var location: @Sendable () async -> Location?
	public var locationServicesEnabled: @Sendable () async -> Bool

  public var requestLocation: @Sendable () async -> Void

  public var requestWhenInUseAuthorization: @Sendable () async -> Void
	
	public var set: @MainActor @Sendable (Properties) async -> Void
	
	/// Updates the given properties of a uniquely identified `CLLocationManager`.
	@available(macOS, unavailable)
	@available(tvOS, unavailable)
	@available(watchOS, unavailable)
	@Sendable public func set(
		activityType: CLActivityType? = nil,
		allowsBackgroundLocationUpdates: Bool? = nil,
		desiredAccuracy: CLLocationAccuracy? = nil,
		distanceFilter: CLLocationDistance? = nil,
		headingFilter: CLLocationDegrees? = nil,
		headingOrientation: CLDeviceOrientation? = nil,
		pausesLocationUpdatesAutomatically: Bool? = nil,
		showsBackgroundLocationIndicator: Bool? = nil
	) async {
		await self.set(
			Properties(
				activityType: activityType,
				allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates,
				desiredAccuracy: desiredAccuracy,
				distanceFilter: distanceFilter,
				headingFilter: headingFilter,
				headingOrientation: headingOrientation,
				pausesLocationUpdatesAutomatically: pausesLocationUpdatesAutomatically,
				showsBackgroundLocationIndicator: showsBackgroundLocationIndicator
			)
		)
	}
	
	/// Updates the given properties of a uniquely identified `CLLocationManager`.
	@available(iOS, unavailable)
	@available(macOS, unavailable)
	@available(tvOS, unavailable)
	@Sendable public func set(
		activityType: CLActivityType? = nil,
		allowsBackgroundLocationUpdates: Bool? = nil,
		desiredAccuracy: CLLocationAccuracy? = nil,
		distanceFilter: CLLocationDistance? = nil,
		headingFilter: CLLocationDegrees? = nil,
		headingOrientation: CLDeviceOrientation? = nil
	) async {
		await self.set(
			Properties(
				activityType: activityType,
				allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates,
				desiredAccuracy: desiredAccuracy,
				distanceFilter: distanceFilter,
				headingFilter: headingFilter,
				headingOrientation: headingOrientation
			)
		)
	}
}
