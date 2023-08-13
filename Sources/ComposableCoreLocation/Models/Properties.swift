import CoreLocation

extension LocationClient {
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
