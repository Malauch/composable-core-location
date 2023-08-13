import Dependencies
import Foundation

extension DependencyValues {
    public var locationClient: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

extension LocationManager: DependencyKey {
	public static var liveValue: Self { Self.live() }
	public static var previewValue: Self { Self.noop }
	
}
