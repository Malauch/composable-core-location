import Combine
import ComposableArchitecture
import MapKit

extension LocalSearchClient {
  public static let live = LocalSearchClient(
		search: { request in
			try await LocalSearchResponse(
				response: MKLocalSearch(request: request).start()
			)
		}
	)
}
