//
//  HTTPError.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//


import Foundation

/// An error thrown when an HTTP request fails due to an unsuccessful status code.
///
/// `HTTPError` contains the HTTP status code and response data from a failed request.
/// It conforms to `LocalizedError` to provide user-friendly error descriptions.
///
/// ## Topics
///
/// ### Error Properties
///
/// - ``statusCode``
/// - ``data``
/// - ``message``
/// - ``errorDescription``
///
/// ### Status Code Checks
///
/// - ``isClientError``
/// - ``isServerError``
///
/// ## Example
///
/// ```swift
/// do {
///     let user = try await client.send(.get, "/users/999", expecting: User.self)
/// } catch let error as HTTPError {
///     if error.isNotFound {
///         print("User not found")
///     } else if error.isUnauthorized {
///         print("Authentication required")
///     } else {
///         print("HTTP Error \(error.statusCode): \(error.message ?? "")")
///     }
/// }
/// ```
///
/// - SeeAlso: ``HTTPResponse``, ``HTTPClient/send(_:expecting:)``
public struct HTTPError: Error, LocalizedError, Sendable {
    /// The HTTP status code that caused the error.
    public let statusCode: Int
    
    /// The response body data from the failed request.
    ///
    /// This often contains error details from the server, which can be decoded
    /// into a custom error response type or converted to a string using ``message``.
    public let data: Data
    
    /// The response body as a UTF-8 encoded string, if available.
    ///
    /// Returns `nil` if the data cannot be decoded as UTF-8.
    ///
    /// ## Example
    ///
    /// ```swift
    /// catch let error as HTTPError {
    ///     if let message = error.message {
    ///         print("Server error message: \(message)")
    ///     }
    /// }
    /// ```
    public var message: String? { 
        String(data: data, encoding: .utf8) 
    }
    
    /// A localized description of the error suitable for displaying to users.
    ///
    /// This property is part of the `LocalizedError` protocol and is used by
    /// the system when presenting error alerts or messages.
    public var errorDescription: String? {
        "HTTP Error \(statusCode): \(message ?? "No message")"
    }
    
    /// Returns `true` if the status code is in the 4xx range (client error).
    ///
    /// Client errors indicate that the request contains bad syntax or cannot
    /// be fulfilled by the server.
    ///
    /// - SeeAlso: ``HTTPResponse/isClientError``
    public var isClientError: Bool { 400..<500 ~= statusCode }
    
    /// Returns `true` if the status code is in the 5xx range (server error).
    ///
    /// Server errors indicate that the server failed to fulfill a valid request.
    ///
    /// - SeeAlso: ``HTTPResponse/isServerError``
    public var isServerError: Bool { 500..<600 ~= statusCode }
}
