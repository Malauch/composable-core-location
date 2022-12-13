import Dependencies
import Foundation

extension DependencyValues {
    public var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

extension LocationManager: DependencyKey {
	public static var liveValue = Self.live
	public static var previewValue = Self.noop
	public static let testValue = Self.failing
}
