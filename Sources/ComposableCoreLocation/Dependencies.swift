import Dependencies

extension LocationManager: DependencyKey {
	public static var liveValue = LocationManager.live
	public static var testValue = LocationManager.failing
}

extension DependencyValues {
	public var locationManager: LocationManager {
		get { self[LocationManager.self] }
		set { self[LocationManager.self] = newValue }
	}
}

extension CLLocationManager: DependencyKey {
	public static var liveValue = CLLocationManager()
}

extension DependencyValues {
	var coreLocationManager: CLLocationManager {
		get { self[CLLocationManager.self] }
		set { self[CLLocationManager.self] = newValue}
	}
}
