//
//  HTTPResponse.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//


import Foundation

/// Represents an HTTP response received from a server.
///
/// `HTTPResponse` is a value type that encapsulates the response data, status code,
/// headers, and a reference to the original request. It provides convenience properties
/// for checking status codes and working with response data.
///
/// ## Topics
///
/// ### Response Properties
///
/// - ``data``
/// - ``statusCode``
/// - ``headers``
/// - ``request``
///
/// ### Status Code Checks
///
/// - ``isSuccess``
/// - ``isRedirect``
/// - ``isClientError``
/// - ``isServerError``
///
/// ### Decoding Response Data
///
/// - ``decode(_:decoder:)``
/// - ``text``
///
/// ## Example
///
/// ```swift
/// let response = try await client.send(request)
///
/// if response.isSuccess {
///     let user = try response.decode(User.self)
///     print("User: \(user.name)")
/// } else if response.isClientError {
///     print("Client error: \(response.statusCode)")
/// }
/// ```
///
/// - SeeAlso: ``HTTPClient/send(_:)``, ``HTTPError``
public struct HTTPResponse: Sendable {
    /// The response body data.
    ///
    /// This is the raw data returned by the server, which can be decoded into
    /// a specific type using ``decode(_:decoder:)`` or converted to text using ``text``.
    public let data: Data
    
    /// The HTTP status code of the response.
    ///
    /// Use convenience properties like ``isSuccess``, ``isClientError``, and ``isServerError``
    /// to check status code ranges.
    public let statusCode: Int
    
    /// The HTTP headers returned by the server.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let contentType = response.headers["Content-Type"] {
    ///     print("Content-Type: \(contentType)")
    /// }
    /// ```
    public let headers: [String: String]
    
    /// The original request that generated this response.
    ///
    /// - SeeAlso: ``HTTPRequest``
    public let request: HTTPRequest

    /// Returns `true` if the status code is in the 2xx range (success).
    ///
    /// Status codes in the 2xx range indicate that the request was successfully received,
    /// understood, and accepted.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if response.isSuccess {
    ///     print("Request succeeded with status \(response.statusCode)")
    /// }
    /// ```
    public var isSuccess: Bool { 200..<300 ~= statusCode }
    
    /// Returns `true` if the status code is in the 4xx range (client error).
    ///
    /// Status codes in the 4xx range indicate that the request contains bad syntax
    /// or cannot be fulfilled.
    ///
    /// - SeeAlso: ``HTTPError/isClientError``
    public var isClientError: Bool { 400..<500 ~= statusCode }
    
    /// Returns `true` if the status code is in the 5xx range (server error).
    ///
    /// Status codes in the 5xx range indicate that the server failed to fulfill
    /// a valid request.
    ///
    /// - SeeAlso: ``HTTPError/isServerError``
    public var isServerError: Bool { 500..<600 ~= statusCode }
    
    /// Attempts to decode the response data as JSON into the specified type.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode into.
    ///   - decoder: The `JSONDecoder` to use. Defaults to a new instance.
    /// - Returns: An instance of the specified type decoded from ``data``.
    /// - Throws: `DecodingError` if the data cannot be decoded into the specified type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct User: Codable {
    ///     let id: Int
    ///     let name: String
    /// }
    ///
    /// let response = try await client.send(request)
    /// let user = try response.decode(User.self)
    /// print(user.name)
    /// ```
    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    /// Returns the response data as a UTF-8 encoded string.
    ///
    /// Returns `nil` if the data cannot be decoded as UTF-8.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let response = try await client.send(request)
    /// if let text = response.text {
    ///     print("Response: \(text)")
    /// }
    /// ```
    public var text: String? {
        String(data: data, encoding: .utf8)
    }
}
