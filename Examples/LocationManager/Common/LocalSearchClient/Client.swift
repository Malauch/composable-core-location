import ComposableArchitecture
import MapKit

public struct LocalSearchClient {
  public var search: @Sendable (MKLocalSearch.Request) async throws-> LocalSearchResponse

  public init(search: @Sendable @escaping (MKLocalSearch.Request) async throws -> LocalSearchResponse) {
    self.search = search
  }

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}
