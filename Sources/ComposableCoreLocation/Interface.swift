import CoreLocation
import Dependencies
import DependenciesMacros

/// A wrapper around Core Location's `CLLocationManager` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
@DependencyClient
public struct LocationClient {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
	public enum Action: Equatable {
    case didChangeAuthorization
    case didFailWithError(CLError)
    case didUpdateLocations([Location])
  }
	
	public var authorizationStatus: @Sendable () async -> CLAuthorizationStatus = { .notDetermined }
	
	public var continuation: @Sendable () async -> AsyncStream<Action>.Continuation?
	
	public var delegate: @MainActor @Sendable () async -> AsyncStream<Action> = { .never }
	
	public var get: @Sendable () async -> Properties = { Properties() }

  public var location: @Sendable () async -> Location?
	
	// TODO: Add avaibility flag for iOS 17+ and etc.
	public var liveUpdates: @Sendable (CLLocationUpdate.LiveConfiguration) async ->  AsyncThrowingStream<LocationUpdate, Error> = { _ in .never }
	
	public var locationServicesEnabled: @Sendable () async -> Bool = { false }

	public var requestLocation: @Sendable () async -> Void

  public var requestWhenInUseAuthorization: @Sendable () async -> Void
	
	public var requestAlwaysAuthorization: @Sendable () async -> Void
	
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
	
	@Sendable public func locationUpdates() async -> AsyncThrowingStream<LocationUpdate, Error> {
		await self.liveUpdates(.default)
	}
	
}
