import Combine
import CoreLocation

/// A wrapper around Core Location's `CLLocationManager` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
public struct LocationManager {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
  public enum Action {
    case didChangeAuthorization(CLAuthorizationStatus)
    case didFailWithError(Error)
    case didUpdateLocations([Location])
  }
	
	init(
		authorizationStatus: @Sendable @escaping () async -> CLAuthorizationStatus,
		delegate: @MainActor @Sendable @escaping () async -> AsyncStream<Action>,
		location: @Sendable @escaping () async -> Location?,
		requestLocation: @Sendable @escaping () async -> Void,
		requestWhenInUseAuthorization: @Sendable @escaping () async -> Void
	) {
		self.authorizationStatus = authorizationStatus
		self.delegate = delegate
		self.location = location
		self.requestLocation = requestLocation
		self.requestWhenInUseAuthorization = requestWhenInUseAuthorization
	}

  public var authorizationStatus: @Sendable () async -> CLAuthorizationStatus
	
	// MARK: - Delegate signature
  public var delegate: @MainActor @Sendable () async -> AsyncStream<Action>

  public var location: @Sendable () async -> Location?

  public var requestLocation: @Sendable () async -> Void

  public var requestWhenInUseAuthorization: @Sendable () async -> Void
}
