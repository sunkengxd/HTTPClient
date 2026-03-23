//
//  HTTPRequest.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//


import Foundation

/// Represents an HTTP request with all necessary information to perform a network call.
///
/// `HTTPRequest` is a value type that encapsulates the HTTP method, URL, headers, body,
/// and timeout configuration for a request. It conforms to `Sendable`, making it safe
/// to pass across actor boundaries in Swift Concurrency.
///
/// ## Topics
///
/// ### Creating a Request
///
/// - ``init(method:url:headers:body:timeoutInterval:)``
///
/// ### Request Properties
///
/// - ``method``
/// - ``url``
/// - ``headers``
/// - ``body``
/// - ``timeoutInterval``
///
/// ## Example
///
/// ```swift
/// let request = HTTPRequest(
///     method: .post,
///     url: URL(string: "https://api.example.com/users")!,
///     headers: ["Authorization": "Bearer token"],
///     body: try JSONEncoder().encode(user),
///     timeoutInterval: 30
/// )
/// ```
///
/// - SeeAlso: ``HTTPClient/send(_:)``
public struct HTTPRequest: Sendable {
    /// The HTTP method for this request.
    ///
    /// - SeeAlso: ``HTTPMethod``
    public var method: HTTPMethod
    
    /// The target URL for this request.
    ///
    /// This can be an absolute URL or a relative path. If the ``HTTPClient`` is configured
    /// with a base URL, relative paths will be resolved against it.
    public var url: URL
    
    /// HTTP headers to include in the request.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var request = HTTPRequest(method: .get, url: url)
    /// request.headers["Authorization"] = "Bearer token"
    /// request.headers["Accept"] = "application/json"
    /// ```
    public var headers: [String: String]
    
    /// The request body data.
    ///
    /// This is typically JSON data encoded from a `Codable` type, but can be any
    /// `Data` representation such as form data, plain text, or binary data.
    public var body: Data?
    
    /// The timeout interval for this request in seconds.
    ///
    /// The request will fail with a timeout error if it takes longer than this duration.
    /// Defaults to 60 seconds.
    public var timeoutInterval: TimeInterval

    public var options: Options

    /// Creates a new HTTP request.
    ///
    /// - Parameters:
    ///   - method: The ``HTTPMethod`` for the request.
    ///   - url: The target URL for the request.
    ///   - headers: HTTP headers to include. Defaults to empty.
    ///   - body: Optional request body data. Defaults to `nil`.
    ///   - timeoutInterval: The timeout interval in seconds. Defaults to 60.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Simple GET request
    /// let getRequest = HTTPRequest(
    ///     method: .get,
    ///     url: URL(string: "https://api.example.com/users")!
    /// )
    ///
    /// // POST request with body and headers
    /// let postRequest = HTTPRequest(
    ///     method: .post,
    ///     url: URL(string: "https://api.example.com/users")!,
    ///     headers: ["Content-Type": "application/json"],
    ///     body: jsonData
    /// )
    /// ```
    public init(
        method: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 60,
        options: Options = []
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.options = options
    }

    public struct Options: OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
    }
}
