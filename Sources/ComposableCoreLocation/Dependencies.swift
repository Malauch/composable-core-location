import Dependencies
import Foundation

extension DependencyValues {
    public var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

extension LocationClient: DependencyKey {
	public static var liveValue: Self { Self.live() }
	public static var previewValue: Self { Self.noop }
	public static var testValue: Self { Self.unimplemented }
	
}
