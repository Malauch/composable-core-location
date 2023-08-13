import Combine
import CoreLocation

/// A wrapper around Core Location's `CLLocationManager` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
///
/// To use it, one begins by adding an action to your domain that represents all of the actions the
/// manager can emit via the `CLLocationManagerDelegate` methods:
///
/// ```swift
/// import ComposableCoreLocation
///
/// enum AppAction {
///   case locationManager(LocationManager.Action)
///
///   // Your domain's other actions:
///   ...
/// }
/// ```
///
/// The `LocationManager.Action` enum holds a case for each delegate method of
/// `CLLocationManagerDelegate`, such as `didUpdateLocations`, `didEnterRegion`, `didUpdateHeading`,
/// and more.
///
/// Next we add a `LocationManager`, which is a wrapper around `CLLocationManager` that the library
/// provides, to the application's environment of dependencies:
///
/// ```swift
/// struct AppEnvironment {
///   var locationManager: LocationManager
///
///   // Your domain's other dependencies:
///   ...
/// }
/// ```
///
/// Then, we simultaneously subscribe to delegate actions and request authorization from our
/// application's reducer by returning an effect from an action to kick things off. One good choice
/// for such an action is the `onAppear` of your view.
///
/// ```swift
/// let appReducer = Reducer<AppState, AppAction, AppEnvironment> {
///   state, action, environment in
///
///   switch action {
///   case .onAppear:
///     return .merge(
///       environment.locationManager
///         .delegate()
///         .map(AppAction.locationManager),
///
///       environment.locationManager
///         .requestWhenInUseAuthorization()
///         .fireAndForget()
///     )
///
///   ...
///   }
/// }
/// ```
///
/// With that initial setup we will now get all of `CLLocationManagerDelegate`'s delegate methods
/// delivered to our reducer via actions. To handle a particular delegate action we can destructure
/// it inside the `.locationManager` case we added to our `AppAction`. For example, once we get
/// location authorization from the user we could request their current location:
///
/// ```swift
/// case .locationManager(.didChangeAuthorization(.authorizedAlways)),
///      .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
///
///   return environment.locationManager
///     .requestLocation()
///     .fireAndForget()
/// ```
///
/// If the user denies location access we can show an alert telling them that we need access to be
/// able to do anything in the app:
///
/// ```swift
/// case .locationManager(.didChangeAuthorization(.denied)),
///      .locationManager(.didChangeAuthorization(.restricted)):
///
///   state.alert = """
///     Please give location access so that we can show you some cool stuff.
///     """
///   return .none
/// ```
///
/// Otherwise, we'll be notified of the user's location by handling the `.didUpdateLocations`
/// action:
///
/// ```swift
/// case let .locationManager(.didUpdateLocations(locations)):
///   // Do something cool with user's current location.
///   ...
/// ```
///
/// Once you have handled all the `CLLocationManagerDelegate` actions you care about, you can ignore
/// the rest:
///
/// ```swift
/// case .locationManager:
///   return .none
/// ```
///
/// And finally, when creating the `Store` to power your application you will supply the "live"
/// implementation of the `LocationManager`, which is an instance that holds onto a
/// `CLLocationManager` on the inside and interacts with it directly:
///
/// ```swift
/// let store = Store(
///   initialState: AppState(),
///   reducer: appReducer,
///   environment: AppEnvironment(
///     locationManager: .live,
///     // And your other dependencies...
///   )
/// )
/// ```
///
/// This is enough to implement a basic application that interacts with Core Location.
///
/// The true power of building your application and interfacing with Core Location in this way is
/// the ability to _test_ how your application interacts with Core Location. It starts by creating
/// a `TestStore` whose environment contains a ``failing`` version of the `LocationManager`. Then,
/// you can selectively override whichever endpoints your feature needs to supply deterministic
/// functionality.
///
/// For example, to test the flow of asking for location authorization, being denied, and showing an
/// alert, we need to override the `create` and `requestWhenInUseAuthorization` endpoints. The
/// `create` endpoint needs to return an effect that emits the delegate actions, which we can
/// control via a publish subject. And the `requestWhenInUseAuthorization` endpoint is a
/// fire-and-forget effect, but we can make assertions that it was called how we expect.
///
/// ```swift
/// let store = TestStore(
///   initialState: AppState(),
///   reducer: appReducer,
///   environment: AppEnvironment(
///     locationManager: .failing
///   )
/// )
///
/// var didRequestInUseAuthorization = false
/// let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
///
/// store.environment.locationManager.create = { locationManagerSubject.eraseToEffect() }
/// store.environment.locationManager.requestWhenInUseAuthorization = {
///   .fireAndForget { didRequestInUseAuthorization = true }
/// }
/// ```
///
/// Then we can write an assertion that simulates a sequence of user steps and location manager
/// delegate actions, and we can assert against how state mutates and how effects are received. For
/// example, we can have the user come to the screen, deny the location authorization request, and
/// then assert that an effect was received which caused the alert to show:
///
/// ```swift
/// store.send(.onAppear)
///
/// // Simulate the user denying location access
/// locationManagerSubject.send(.didChangeAuthorization(.denied))
///
/// // We receive the authorization change delegate action from the effect
/// store.receive(.locationManager(.didChangeAuthorization(.denied))) {
///   $0.alert = """
///     Please give location access so that we can show you some cool stuff.
///     """
///
/// // Store assertions require all effects to be completed, so we complete
/// // the subject manually.
/// locationManagerSubject.send(completion: .finished)
/// ```
///
/// And this is only the tip of the iceberg. We can further test what happens when we are granted
/// authorization by the user and the request for their location returns a specific location that we
/// control, and even what happens when the request for their location fails. It is very easy to
/// write these tests, and we can test deep, subtle properties of our application.
///
public struct LocationManager {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
  public enum Action: Equatable {
    case didChangeAuthorization(CLAuthorizationStatus)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didDetermineState(CLRegionState, region: Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didEnterRegion(Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didExitRegion(Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFailRanging(beaconConstraint: CLBeaconIdentityConstraint, error: Error)

    case didFailWithError(Error)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFinishDeferredUpdatesWithError(Error?)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didPauseLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didResumeLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didStartMonitoring(region: Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case didUpdateHeading(newHeading: Heading)

    case didUpdateLocations([Location])

    @available(macCatalyst, deprecated: 13)
    @available(tvOS, unavailable)
    case didUpdateTo(newLocation: Location, oldLocation: Location)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didVisit(Visit)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case monitoringDidFail(region: Region?, error: Error)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didRangeBeacons([Beacon], satisfyingConstraint: CLBeaconIdentityConstraint)
  }

  public struct Error: Swift.Error, Equatable {
    public let error: NSError

    public init(_ error: Swift.Error) {
      self.error = error as NSError
    }
  }
	
	init(
		accuracyAuthorization: @Sendable @escaping () async -> AccuracyAuthorization?,
		authorizationStatus: @Sendable @escaping () async -> CLAuthorizationStatus,
		delegate: @MainActor @Sendable @escaping () async -> AsyncStream<Action>,
		dismissHeadingCalibrationDisplay: @Sendable @escaping () async -> Void,
		heading: @Sendable @escaping () async -> Heading?,
		headingAvailable: @Sendable @escaping () async -> Bool,
		isRangingAvailable: @Sendable @escaping () async -> Bool,
		location: @Sendable @escaping () async -> Location?,
		locationServicesEnabled: @Sendable @escaping () async -> Bool,
		maximumRegionMonitoringDistance: @Sendable @escaping () async -> CLLocationDistance,
		monitoredRegions: @Sendable @escaping () async -> Set<Region>,
		requestAlwaysAuthorization: @Sendable @escaping () async -> Void,
		requestLocation: @Sendable @escaping () async -> Void,
		requestWhenInUseAuthorization: @Sendable @escaping () async -> Void,
		requestTemporaryFullAccuracyAuthorization: @Sendable @escaping (String) async throws -> Void,
		set: @Sendable @escaping (Properties) async -> Void,
		significantLocationChangeMonitoringAvailable: @escaping () async -> Bool,
		startMonitoringForRegion: @Sendable @escaping (Region) async -> Void,
		startMonitoringSignificantLocationChanges: @Sendable @escaping () async -> Void,
		startMonitoringVisits: @Sendable @escaping () async -> Void,
		startUpdatingHeading: @Sendable @escaping () async -> Void,
		startUpdatingLocation: @Sendable @escaping () async -> Void,
		stopMonitoringForRegion: @Sendable @escaping (Region) async -> Void,
		stopMonitoringSignificantLocationChanges: @Sendable @escaping () async -> Void,
		stopMonitoringVisits: @Sendable @escaping () async -> Void,
		stopUpdatingHeading: @Sendable @escaping () async -> Void,
		stopUpdatingLocation: @Sendable @escaping () async -> Void
	) {
		self.accuracyAuthorization = accuracyAuthorization
		self.authorizationStatus = authorizationStatus
		self.delegate = delegate
		self.dismissHeadingCalibrationDisplay = dismissHeadingCalibrationDisplay
		self.heading = heading
		self.headingAvailable = headingAvailable
		self._isRangingAvailable = isRangingAvailable
		self.location = location
		self.locationServicesEnabled = locationServicesEnabled
		self._maximumRegionMonitoringDistance = maximumRegionMonitoringDistance
		self._monitoredRegions = monitoredRegions
		self.requestAlwaysAuthorization = requestAlwaysAuthorization
		self.requestLocation = requestLocation
		self.requestWhenInUseAuthorization = requestWhenInUseAuthorization
		self.requestTemporaryFullAccuracyAuthorization = requestTemporaryFullAccuracyAuthorization
		self.set = set
		self._significantLocationChangeMonitoringAvailable = significantLocationChangeMonitoringAvailable
		self._startMonitoringForRegion = startMonitoringForRegion
		self._startMonitoringSignificantLocationChanges = startMonitoringSignificantLocationChanges
		self._startMonitoringVisits = startMonitoringVisits
		self._startUpdatingHeading = startUpdatingHeading
		self._startUpdatingLocation = startUpdatingLocation
		self._stopMonitoringForRegion = stopMonitoringForRegion
		self._stopMonitoringSignificantLocationChanges = stopMonitoringSignificantLocationChanges
		self._stopMonitoringVisits = stopMonitoringVisits
		self._stopUpdatingHeading = stopUpdatingHeading
		self.stopUpdatingLocation = stopUpdatingLocation
	}

  public var accuracyAuthorization: @Sendable () async -> AccuracyAuthorization?

  public var authorizationStatus: @Sendable () async -> CLAuthorizationStatus
	
	// MARK: - Delegate signature
  public var delegate: @MainActor @Sendable () async -> AsyncStream<Action>

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public var dismissHeadingCalibrationDisplay: @Sendable () async -> Void

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public var heading: @Sendable () async -> Heading?

  @available(tvOS, unavailable)
  public var headingAvailable: @Sendable () async -> Bool

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var isRangingAvailable: @Sendable () async -> Bool {
		get { self._isRangingAvailable }
		set { self._isRangingAvailable = newValue }
	}
	private var _isRangingAvailable: @Sendable () async -> Bool

  public var location: @Sendable () async -> Location?

	// It's async, because otherwise there is purple warning about blocking main thread.
  public var locationServicesEnabled: @Sendable () async -> Bool

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var maximumRegionMonitoringDistance: @Sendable () async -> CLLocationDistance {
		get { self._maximumRegionMonitoringDistance }
		set { self._maximumRegionMonitoringDistance = newValue }
	}
	private var _maximumRegionMonitoringDistance: @Sendable () async -> CLLocationDistance

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var monitoredRegions: @Sendable () async -> Set<Region> {
		get { self._monitoredRegions }
		set { self._monitoredRegions = newValue }
	}
	private var _monitoredRegions: @Sendable () async -> Set<Region>

  @available(tvOS, unavailable)
  public var requestAlwaysAuthorization: @Sendable () async -> Void

  public var requestLocation: @Sendable () async -> Void

  public var requestWhenInUseAuthorization: @Sendable () async -> Void

  public var requestTemporaryFullAccuracyAuthorization: @Sendable (String) async throws -> Void

  public var set: @MainActor @Sendable (Properties) async -> Void

	
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var significantLocationChangeMonitoringAvailable: () async -> Bool {
		get { self._significantLocationChangeMonitoringAvailable }
		set { self._significantLocationChangeMonitoringAvailable = newValue }
	}
	private var _significantLocationChangeMonitoringAvailable: () async -> Bool

	
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var startMonitoringForRegion: @Sendable (Region) async -> Void {
		get { self._startMonitoringForRegion }
		set { self._startMonitoringForRegion = newValue }
	}
	private var _startMonitoringForRegion: @Sendable (Region) async -> Void

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var startMonitoringSignificantLocationChanges: @Sendable () async -> Void {
		get { self._startMonitoringSignificantLocationChanges }
		set { self._startMonitoringSignificantLocationChanges = newValue }
	}
	private var _startMonitoringSignificantLocationChanges: @Sendable () async -> Void

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var startMonitoringVisits: @Sendable () async -> Void {
		get { self._startMonitoringVisits }
		set { self._startMonitoringVisits = newValue }
	}
	private var _startMonitoringVisits: @Sendable () async -> Void

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
	public var startUpdatingHeading: @Sendable () async -> Void {
		get { self._startUpdatingHeading }
		set { self._startUpdatingHeading = newValue }
	}
	private var _startUpdatingHeading: @Sendable () async -> Void

  @available(tvOS, unavailable)
	public var startUpdatingLocation: @Sendable () async -> Void {
		get { self._startUpdatingLocation }
		set { self._startUpdatingLocation = newValue }
	}
	private var _startUpdatingLocation: @Sendable () async -> Void

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var stopMonitoringForRegion: @Sendable (Region) async -> Void {
		get { self._stopMonitoringForRegion }
		set { self._stopMonitoringForRegion = newValue }
	}
	private var _stopMonitoringForRegion: @Sendable (Region) async -> Void

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	public var stopMonitoringSignificantLocationChanges: @Sendable () async -> Void {
		get { self._stopMonitoringSignificantLocationChanges }
		set { self._stopMonitoringSignificantLocationChanges = newValue }
	}
	private var _stopMonitoringSignificantLocationChanges: @Sendable () async -> Void

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
	private var stopMonitoringVisits: @Sendable () async -> Void {
		get { self._stopMonitoringVisits }
		set { self._stopMonitoringVisits = newValue }
	}
	private var _stopMonitoringVisits: @Sendable () async -> Void

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
	public var stopUpdatingHeading: @Sendable () async -> Void {
		get { self._stopUpdatingHeading }
		set { self._stopUpdatingHeading = newValue }
	}
	private var _stopUpdatingHeading: @Sendable () async -> Void

  public var stopUpdatingLocation: @Sendable () async -> Void

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

extension LocationManager {
  public struct Properties: Equatable {
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    var activityType: CLActivityType? = nil

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    var allowsBackgroundLocationUpdates: Bool? = nil

    var desiredAccuracy: CLLocationAccuracy? = nil

    var distanceFilter: CLLocationDistance? = nil

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    var headingFilter: CLLocationDegrees? = nil

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    var headingOrientation: CLDeviceOrientation? = nil

		@available(macOS, unavailable)
		@available(tvOS, unavailable)
		@available(watchOS, unavailable)
		var pausesLocationUpdatesAutomatically: Bool? {
			get { self._pausesLocationUpdatesAutomatically }
			set { self._pausesLocationUpdatesAutomatically = newValue }
		}
		private var _pausesLocationUpdatesAutomatically: Bool? = nil

		@available(macOS, unavailable)
		@available(tvOS, unavailable)
		@available(watchOS, unavailable)
		var showsBackgroundLocationIndicator: Bool? {
			get { self._showsBackgroundLocationIndicator }
			set { self._showsBackgroundLocationIndicator = newValue }
		}
		private var _showsBackgroundLocationIndicator: Bool? = nil

    public static func == (lhs: Self, rhs: Self) -> Bool {
      var isEqual = true
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.activityType == rhs.activityType
          && lhs.allowsBackgroundLocationUpdates == rhs.allowsBackgroundLocationUpdates
      #endif
      isEqual =
        isEqual
        && lhs.desiredAccuracy == rhs.desiredAccuracy
        && lhs.distanceFilter == rhs.distanceFilter
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.headingFilter == rhs.headingFilter
          && lhs.headingOrientation == rhs.headingOrientation
      #endif
      #if os(iOS) || targetEnvironment(macCatalyst)
        isEqual =
          isEqual
          && lhs.pausesLocationUpdatesAutomatically == rhs.pausesLocationUpdatesAutomatically
          && lhs.showsBackgroundLocationIndicator == rhs.showsBackgroundLocationIndicator
      #endif
      return isEqual
    }

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil,
      pausesLocationUpdatesAutomatically: Bool? = nil,
      showsBackgroundLocationIndicator: Bool? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
      self.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
      self.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(watchOS, unavailable)
    public init(
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil
    ) {
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
    }
  }
}
