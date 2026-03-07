import Testing
import Foundation

@testable import HTTPClient

struct AppendHeaderInterceptor: HTTPInterceptor {
    let key: String
    let value: String

    func intercept(
        request: HTTPRequest,
        next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    ) async throws -> HTTPResponse {
        var req = request
        req.headers[key] = value
        return try await next(req)
    }
}

@Test func interceptorsRunInOrder() async throws {
    let client = HTTPClient(
        session: .shared,
        baseURL: nil,
        interceptors: [
            AppendHeaderInterceptor(key: "First", value: "1"),
            AppendHeaderInterceptor(key: "Second", value: "2"),
        ],
        encoder: .init(),
        decoder: .init()
    )
}

@Test func invalidURLThrows() async {
    let client = HTTPClient(
        session: .shared,
        baseURL: nil,
        interceptors: [],
        encoder: .init(),
        decoder: .init()
    )
    
    await #expect(throws: URLError.self) {
        try await client.get("")
    }
}
