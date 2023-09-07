import Dependencies
import Foundation

extension DependencyValues {
    public var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

extension LocationClient: DependencyKey {
	public static var liveValue: Self { .live }
	public static var previewValue: Self { .mock }
	public static var testValue: Self { .unimplemented }
	
}
