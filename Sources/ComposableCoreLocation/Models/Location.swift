import CoreLocation
import Dependencies

/// A value type wrapper for `CLLocation`. This type is necessary so that we can do equality checks
/// and write tests against its values.
@dynamicMemberLookup
public struct Location {
  public let rawValue: CLLocation

  public init(
    altitude: CLLocationDistance = 0,
    coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
    course: CLLocationDirection = 0,
    horizontalAccuracy: CLLocationAccuracy = 0,
    speed: CLLocationSpeed = 0,
    timestamp: Date,
    verticalAccuracy: CLLocationAccuracy = 0
  ) {
    self.rawValue = CLLocation(
      coordinate: coordinate,
      altitude: altitude,
      horizontalAccuracy: horizontalAccuracy,
      verticalAccuracy: verticalAccuracy,
      course: course,
      speed: speed,
      timestamp: timestamp
    )
  }
	
	public init(
		altitude: CLLocationDistance = 0,
		coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
		course: CLLocationDirection = 0,
		horizontalAccuracy: CLLocationAccuracy = 0,
		speed: CLLocationSpeed = 0,
		verticalAccuracy: CLLocationAccuracy = 0
	) {
		@Dependency(\.date) var date
		
		self = .init(
			altitude: altitude,
			coordinate: coordinate,
			course: course,
			horizontalAccuracy: horizontalAccuracy,
			speed: speed,
			timestamp: date(),
			verticalAccuracy: verticalAccuracy
		)
	}
	
	public init(
		altitude: CLLocationDistance = 0,
		coordinate: Coordinate = Coordinate(latitude: 0, longitude: 0),
		course: CLLocationDirection = 0,
		horizontalAccuracy: CLLocationAccuracy = 0,
		speed: CLLocationSpeed = 0,
		timestamp: Date,
		verticalAccuracy: CLLocationAccuracy = 0
	) {
		self.rawValue = CLLocation(
			coordinate: coordinate.rawValue,
			altitude: altitude,
			horizontalAccuracy: horizontalAccuracy,
			verticalAccuracy: verticalAccuracy,
			course: course,
			speed: speed,
			timestamp: timestamp
		)
	}
	
	public init(
		altitude: CLLocationDistance = 0,
		coordinate: Coordinate = Coordinate(latitude: 0, longitude: 0),
		course: CLLocationDirection = 0,
		horizontalAccuracy: CLLocationAccuracy = 0,
		speed: CLLocationSpeed = 0,
		verticalAccuracy: CLLocationAccuracy = 0
	) {
		@Dependency(\.date) var date
		
		self = .init(
			altitude: altitude,
			coordinate: coordinate.rawValue,
			course: course,
			horizontalAccuracy: horizontalAccuracy,
			speed: speed,
			timestamp: date(),
			verticalAccuracy: verticalAccuracy
		)
	}
	
	public init(
		altitude: CLLocationDistance = 0,
		latitude: Double = 0,
		longitude: Double = 0,
		course: CLLocationDirection = 0,
		horizontalAccuracy: CLLocationAccuracy = 0,
		speed: CLLocationSpeed = 0,
		timestamp: Date,
		verticalAccuracy: CLLocationAccuracy = 0
	) {
		self.rawValue = CLLocation(
			coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
			altitude: altitude,
			horizontalAccuracy: horizontalAccuracy,
			verticalAccuracy: verticalAccuracy,
			course: course,
			speed: speed,
			timestamp: timestamp
		)
	}
	
	public init(
		altitude: CLLocationDistance = 0,
		latitude: Double = 0,
		longitude: Double = 0,
		course: CLLocationDirection = 0,
		horizontalAccuracy: CLLocationAccuracy = 0,
		speed: CLLocationSpeed = 0,
		verticalAccuracy: CLLocationAccuracy = 0
	) {
		@Dependency(\.date) var date
		
		self = Self(
			altitude: altitude,
			latitude: latitude,
			longitude: longitude,
			course: course,
			horizontalAccuracy: horizontalAccuracy,
			speed: speed,
			timestamp: date(),
			verticalAccuracy: verticalAccuracy
		)
	}
	

  public init(rawValue: CLLocation) {
    self.rawValue = rawValue
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<CLLocation, T>) -> T {
    self.rawValue[keyPath: keyPath]
  }
	
	public func distance(from location: Self) -> CLLocationDistance{
		self.rawValue.distance(from: location.rawValue)
	}
}

// It's to fixed not describing propertis by customDump in The Composable Architecture Tests.
extension Location: CustomReflectable {
	public var customMirror: Mirror {
		
		#if compiler(>=5.2)
		if #available(iOS 15.0, macCatalyst 15.0, macOS 12, tvOS 15, watchOS 8.0, *) {
			return Mirror(
				self.rawValue,
				children: [
					"coordinate": self.rawValue.coordinate,
					"altitude": self.rawValue.altitude,
					"ellipsoidAltitude": self.rawValue.ellipsoidalAltitude,
					"floor": self.rawValue.floor as Any,
					"timestamp": self.rawValue.timestamp,
					"sourceInformation": self.rawValue.sourceInformation as Any,
					"horizontalAccuraccy": self.rawValue.horizontalAccuracy,
					"verticalAccuracy": self.rawValue.verticalAccuracy,
					"speed": self.rawValue.speed,
					"speedAccuracy": self.rawValue.speedAccuracy,
					"course": self.rawValue.course,
					"courseAccuracy": self.rawValue.courseAccuracy,
				],
				displayStyle: .struct
			)
		} else if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
			return Mirror(
				self.rawValue,
				children: [
					"coordinate": self.rawValue.coordinate,
					"altitude": self.rawValue.altitude,
					"floor": self.rawValue.floor as Any,
					"timestamp": self.rawValue.timestamp,
					"horizontalAccuraccy": self.rawValue.horizontalAccuracy,
					"verticalAccuracy": self.rawValue.verticalAccuracy,
					"speed": self.rawValue.speed,
					"speedAccuracy": self.rawValue.speedAccuracy,
					"course": self.rawValue.course,
					"courseAccuracy": self.rawValue.courseAccuracy,
				],
				displayStyle: .struct
			)
		} else {
			return Mirror(
				self.rawValue,
				children: [
					"coordinate": self.rawValue.coordinate,
					"altitude": self.rawValue.altitude,
					"floor": self.rawValue.floor as Any,
					"timestamp": self.rawValue.timestamp,
					"horizontalAccuraccy": self.rawValue.horizontalAccuracy,
					"verticalAccuracy": self.rawValue.verticalAccuracy,
					"speed": self.rawValue.speed,
					"speedAccuracy": self.rawValue.speedAccuracy,
					"course": self.rawValue.course,
					"courseAccuracy": self.rawValue.courseAccuracy,
				],
				displayStyle: .struct
			)
		}
		#else
		Mirror(
			self.rawValue,
			children: [
				"coordinate": self.rawValue.coordinate,
				"altitude": self.rawValue.altitude,
				"floor": self.rawValue.floor as Any,
				"timestamp": self.rawValue.timestamp,
				"horizontalAccuraccy": self.rawValue.horizontalAccuracy,
				"verticalAccuracy": self.rawValue.verticalAccuracy,
				"speed": self.rawValue.speed,
				"course": self.rawValue.course,
			],
			displayStyle: .struct
		)
		#endif
		
	}
}

extension Location: Hashable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    let courseAccuracyIsEqual: Bool
    let speedAccuracyIsEqual: Bool
    #if compiler(>=5.2)
      if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
        courseAccuracyIsEqual = lhs.courseAccuracy == rhs.courseAccuracy
        speedAccuracyIsEqual = lhs.speedAccuracy == rhs.speedAccuracy
      } else {
        courseAccuracyIsEqual = true
        speedAccuracyIsEqual = true
      }
    #else
      courseAccuracyIsEqual = true
      speedAccuracyIsEqual = true
    #endif

    return lhs.altitude == rhs.altitude
      && lhs.coordinate.latitude == rhs.coordinate.latitude
      && lhs.coordinate.longitude == rhs.coordinate.longitude
      && lhs.course == rhs.course
      && lhs.floor == rhs.floor
      && lhs.horizontalAccuracy == rhs.horizontalAccuracy
      && lhs.speed == rhs.speed
      && lhs.timestamp == rhs.timestamp
      && lhs.verticalAccuracy == rhs.verticalAccuracy
      && speedAccuracyIsEqual
      && courseAccuracyIsEqual
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.altitude)
    hasher.combine(self.coordinate.latitude)
    hasher.combine(self.coordinate.longitude)
    hasher.combine(self.course)
    hasher.combine(self.floor)
    hasher.combine(self.horizontalAccuracy)
    hasher.combine(self.speed)
    hasher.combine(self.timestamp)
    hasher.combine(self.verticalAccuracy)

    #if compiler(>=5.2)
      if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
        hasher.combine(self.speedAccuracy)
        hasher.combine(self.courseAccuracy)
      }
    #endif
  }
}

#if compiler(>=5.2)
  extension Location {
    public init(
      altitude: CLLocationDistance = 0,
      coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
      course: CLLocationDirection = 0,
      courseAccuracy: Double = 0,
      horizontalAccuracy: CLLocationAccuracy = 0,
      speed: CLLocationSpeed = 0,
      speedAccuracy: Double = 0,
      timestamp: Date = Date(),
      verticalAccuracy: CLLocationAccuracy = 0
    ) {
      if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
        self.rawValue = CLLocation(
          coordinate: coordinate,
          altitude: altitude,
          horizontalAccuracy: horizontalAccuracy,
          verticalAccuracy: verticalAccuracy,
          course: course,
          courseAccuracy: courseAccuracy,
          speed: speed,
          speedAccuracy: speedAccuracy,
          timestamp: timestamp
        )
      } else {
        self.rawValue = CLLocation(
          coordinate: coordinate,
          altitude: altitude,
          horizontalAccuracy: horizontalAccuracy,
          verticalAccuracy: verticalAccuracy,
          course: course,
          speed: speed,
          timestamp: timestamp
        )
      }
    }
  }
#endif

extension Location: Codable {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let altitude = try values.decode(CLLocationDistance.self, forKey: .altitude)
    let latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
    let longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
    let course = try values.decode(CLLocationDirection.self, forKey: .course)
    let horizontalAccuracy = try values.decode(Double.self, forKey: .horizontalAccuracy)
    let speed = try values.decode(CLLocationSpeed.self, forKey: .speed)
    let timestamp = try values.decode(Date.self, forKey: .timestamp)
    let verticalAccuracy = try values.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)

    #if compiler(>=5.2)
      if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
        let courseAccuracy = try values.decode(Double.self, forKey: .courseAccuracy)
        let speedAccuracy = try values.decode(Double.self, forKey: .speedAccuracy)

        self.init(
          altitude: altitude,
          coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
          course: course,
          courseAccuracy: courseAccuracy,
          horizontalAccuracy: horizontalAccuracy,
          speed: speed,
          speedAccuracy: speedAccuracy,
          timestamp: timestamp,
          verticalAccuracy: verticalAccuracy
        )
      } else {
        self.init(
          altitude: altitude,
          coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
          course: course,
          horizontalAccuracy: horizontalAccuracy,
          speed: speed,
          timestamp: timestamp,
          verticalAccuracy: verticalAccuracy
        )
      }
    #else
      self.init(
        altitude: altitude,
        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        course: course,
        horizontalAccuracy: horizontalAccuracy,
        speed: speed,
        timestamp: timestamp,
        verticalAccuracy: verticalAccuracy
      )
    #endif
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rawValue.altitude, forKey: .altitude)
    try container.encode(rawValue.coordinate.latitude, forKey: .latitude)
    try container.encode(rawValue.coordinate.longitude, forKey: .longitude)
    try container.encode(rawValue.course, forKey: .course)
    try container.encode(rawValue.horizontalAccuracy, forKey: .horizontalAccuracy)
    try container.encode(rawValue.speed, forKey: .speed)
    try container.encode(rawValue.timestamp, forKey: .timestamp)
    try container.encode(rawValue.verticalAccuracy, forKey: .verticalAccuracy)

    #if compiler(>=5.2)
      if #available(iOS 13.4, macCatalyst 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
        try container.encode(rawValue.courseAccuracy, forKey: .courseAccuracy)
      }
      try container.encode(rawValue.speedAccuracy, forKey: .speedAccuracy)
    #endif
  }

  private enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
    case altitude
    case course
    case courseAccuracy
    case horizontalAccuracy
    case speed
    case speedAccuracy
    case timestamp
    case verticalAccuracy
  }
}

extension Location {
	public static let mockBrooklyn = Location(
		coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958)
	)
	
	public static func mockFluid() -> Self {
		let latitude = Double(Int.random(in: 51_213_000...51_214_000))/1_000_000
		let longitude = Double(Int.random(in: 15_744_000...15_745_000))/1_000_000
		
		return Location(latitude: latitude, longitude: longitude)
	}
}
