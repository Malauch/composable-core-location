import ComposableArchitecture
import MapKit

extension LocalSearchClient {
  public static let failing = Self(
    search: { _ in throw Error() }
  )
}
