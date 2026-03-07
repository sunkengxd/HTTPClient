//
//  HTTPInterceptor.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//


/// A protocol for implementing middleware that can intercept and modify HTTP requests and responses.
///
/// Interceptors enable cross-cutting concerns like logging, authentication, retry logic,
/// caching, and request/response transformation. They are executed in the order they are
/// provided to ``HTTPClient`` during initialization.
///
/// ## Topics
///
/// ### Intercepting Requests
///
/// - ``intercept(request:next:)``
///
/// ## Interceptor Chain
///
/// Interceptors form a chain where each interceptor can:
/// - Inspect or modify the request before passing it to the next interceptor
/// - Call `next` to continue the chain and perform the network request
/// - Inspect or modify the response before returning it
/// - Handle errors and potentially retry or transform them
/// - Short-circuit the chain by returning a cached response or throwing an error
///
/// ## Example
///
/// ```swift
/// struct CustomHeaderInterceptor: HTTPInterceptor {
///     func intercept(
///         request: HTTPRequest,
///         next: @Sendable (HTTPRequest) async throws -> HTTPResponse
///     ) async throws -> HTTPResponse {
///         var modifiedRequest = request
///         modifiedRequest.headers["X-Custom-Header"] = "value"
///         modifiedRequest.headers["X-Request-Time"] = "\(Date().timeIntervalSince1970)"
///         
///         // Call next to continue the chain
///         let response = try await next(modifiedRequest)
///         
///         // Optionally process the response
///         print("Received status code: \(response.statusCode)")
///         
///         return response
///     }
/// }
/// ```
///
/// - SeeAlso: ``HTTPClient/init(session:baseURL:interceptors:encoder:decoder:)``
public protocol HTTPInterceptor: Sendable {
    /// Intercepts an HTTP request, allowing modification before it's sent and inspection after the response.
    ///
    /// This method receives the request and a `next` closure. Call `next` with the (potentially modified)
    /// request to continue the interceptor chain. The final interceptor in the chain will perform the
    /// actual network request.
    ///
    /// - Parameters:
    ///   - request: The ``HTTPRequest`` to intercept. Create a modified copy if you need to change it.
    ///   - next: A closure that continues the interceptor chain. Call this with your request to proceed.
    /// - Returns: An ``HTTPResponse`` from the network request or a subsequent interceptor.
    /// - Throws: Any error that occurs during the request or in the interceptor chain.
    ///
    /// ## Example: Adding Headers
    ///
    /// ```swift
    /// func intercept(
    ///     request: HTTPRequest,
    ///     next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    /// ) async throws -> HTTPResponse {
    ///     var modifiedRequest = request
    ///     modifiedRequest.headers["User-Agent"] = "MyApp/1.0"
    ///     return try await next(modifiedRequest)
    /// }
    /// ```
    ///
    /// ## Example: Timing and Logging
    ///
    /// ```swift
    /// func intercept(
    ///     request: HTTPRequest,
    ///     next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    /// ) async throws -> HTTPResponse {
    ///     let startTime = Date()
    ///     let response = try await next(request)
    ///     let duration = Date().timeIntervalSince(startTime)
    ///     print("Request took \(duration)s")
    ///     return response
    /// }
    /// ```
    ///
    /// ## Example: Retry Logic
    ///
    /// ```swift
    /// func intercept(
    ///     request: HTTPRequest,
    ///     next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    /// ) async throws -> HTTPResponse {
    ///     for attempt in 0..<3 {
    ///         do {
    ///             return try await next(request)
    ///         } catch {
    ///             if attempt == 2 { throw error }
    ///             try await Task.sleep(nanoseconds: 1_000_000_000)
    ///         }
    ///     }
    ///     fatalError("Unreachable")
    /// }
    /// ```
    func intercept(
        request: HTTPRequest,
        next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    ) async throws -> HTTPResponse
}
