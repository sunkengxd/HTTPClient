//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//

import Foundation

/// A  HTTP client built with Swift Concurrency that provides a type-safe interface for making HTTP requests.
///
/// `HTTPClient` supports both raw `Data` and `Codable` types, automatic JSON encoding/decoding,
/// and a powerful interceptor chain pattern for implementing cross-cutting concerns.
///
/// ## Three Ways to Make Requests
///
/// ### 1. Method-Specific Extensions (Recommended)
///
/// The most expressive and readable API, with methods like `get()`, `post()`, `put()`, `patch()`, and `delete()`:
///
/// ```swift
/// // GET with type inference
/// let users: [User] = try await client.get("/users")
///
/// // POST with body
/// let created: User = try await client.post("/users", body: newUser)
///
/// // With query parameters
/// let results: [User] = try await client.get("/users", parameters: ["page": "1"])
/// ```
///
/// ### 2. Generic `send()` Methods
///
/// Flexible methods that accept any HTTP method:
///
/// ```swift
/// let users = try await client.send(.get, "/users", expecting: [User].self)
/// let created = try await client.send(.post, "/users", body: newUser, expecting: User.self)
/// ```
///
/// ### 3. Core `send()` with HTTPRequest
///
/// Full control with an ``HTTPRequest`` object:
///
/// ```swift
/// let request = HTTPRequest(method: .get, url: url, headers: headers)
/// let response = try await client.send(request)
/// ```
///
/// ## Configuration
///
/// ```swift
/// let client = HTTPClient(
///     baseURL: URL(string: "https://api.example.com"),
///     interceptors: [MyLoggingInterceptor()],
///     encoder: customEncoder,
///     decoder: customDecoder
/// )
/// ```
///
/// - SeeAlso: ``HTTPRequest``, ``HTTPResponse``, ``HTTPMethod``, ``HTTPInterceptor``
public final class HTTPClient: Sendable {

    private let session: URLSession
    private let baseURL: URL?
    private let interceptors: [HTTPInterceptor]
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        session: URLSession = .shared,
        baseURL: URL? = nil,
        interceptors: [HTTPInterceptor] = [],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.interceptors = interceptors
        self.encoder = encoder
        self.decoder = decoder
    }

    public func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        // Build the chain from inside out. The innermost handler
        // is the actual network call; each interceptor wraps it.
        let transport: @Sendable (HTTPRequest) async throws -> HTTPResponse = {
            [session] req in
            var urlRequest = URLRequest(
                url: req.url,
                timeoutInterval: req.timeoutInterval
            )
            urlRequest.httpMethod = req.method.rawValue
            urlRequest.httpBody = req.body
            req.headers.forEach {
                urlRequest.setValue($1, forHTTPHeaderField: $0)
            }

            let (data, urlResponse) = try await session.data(for: urlRequest)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            return HTTPResponse(
                data: data,
                statusCode: httpResponse.statusCode,
                headers: httpResponse.allHeaderFields as? [String: String]
                    ?? [:],
                request: req
            )
        }

        // Fold interceptors right-to-left so the first interceptor
        // in the array is the outermost (runs first).
        let chain = interceptors.reversed().reduce(transport) { next, interceptor in
            { request in
                try await interceptor.intercept(request: request, next: next)
            }
        }

        var resolved = request
        if let baseURL, resolved.url.host == nil {
            var components = URLComponents(url: resolved.url, resolvingAgainstBaseURL: false)
            let path = resolved.url.relativePath

            var fullURL = baseURL.appendingPathComponent(path)

            if let queryItems = components?.queryItems, !queryItems.isEmpty {
                var fullComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
                fullComponents?.queryItems = queryItems
                if let urlWithQuery = fullComponents?.url {
                    fullURL = urlWithQuery
                }
            }

            resolved.url = fullURL
        }

        return try await chain(resolved)
    }

    public func send<ResponseBody: Decodable>(
        _ request: HTTPRequest,
        expecting type: ResponseBody.Type
    ) async throws -> ResponseBody {
        let response = try await send(request)
        guard response.isSuccess else {
            throw HTTPError(
                statusCode: response.statusCode,
                data: response.data
            )
        }
        return try decoder.decode(ResponseBody.self, from: response.data)
    }
}

extension HTTPClient {

    private func buildRequest(
        _ method: HTTPMethod,
        _ path: String,
        parameters: [String: String],
        headers: [String: String],
        body: Data?,
        timeoutInterval: TimeInterval
    ) throws -> HTTPRequest {
        guard var url = URL(string: path) else {
            throw URLError(.badURL)
        }
        if !parameters.isEmpty {
            url.append(queryItems: parameters.map(URLQueryItem.init))
        }
        return HTTPRequest(
            method: method,
            url: url,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
    }

    public func send(
        _ method: HTTPMethod,
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        let request = try buildRequest(
            method,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
        return try await send(request)
    }

    public func send(
        _ method: HTTPMethod,
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: some Encodable,
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        var request = try buildRequest(
            method,
            path,
            parameters: parameters,
            headers: headers,
            body: encoder.encode(body),
            timeoutInterval: timeoutInterval
        )
        request.headers["Content-Type"] = "application/json"
        return try await send(request)
    }

    // Raw body + decode response
    public func send<ResponseBody: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        expecting: ResponseBody.Type,
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        let request = try buildRequest(
            method,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
        return try await send(request, expecting: ResponseBody.self)
    }

    // Encodable body + decode response
    public func send<ResponseBody: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: some Encodable,
        expecting: ResponseBody.Type,
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        var request = try buildRequest(
            method,
            path,
            parameters: parameters,
            headers: headers,
            body: encoder.encode(body),
            timeoutInterval: timeoutInterval
        )
        request.headers["Content-Type"] = "application/json"
        return try await send(request, expecting: ResponseBody.self)
    }
}
