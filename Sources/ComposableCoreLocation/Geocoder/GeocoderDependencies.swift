import Dependencies

extension GeocoderClient: DependencyKey {
	static public var liveValue: Self = .live
}

extension DependencyValues {
	var geocoder: GeocoderClient {
		get { self[GeocoderClient.self] }
		set { self[GeocoderClient.self] = newValue }
	}
}
