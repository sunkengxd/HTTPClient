//
//  HTTPMethod.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//


import Foundation

/// Represents standard HTTP methods.
///
/// ## Topics
///
/// ### HTTP Methods
///
/// - ``get``
/// - ``post``
/// - ``put``
/// - ``patch``
/// - ``delete``
/// - ``head``
/// - ``options``
///
/// ## Example
///
/// ```swift
/// let request = HTTPRequest(
///     method: .post,
///     url: url
/// )
/// ```
///
/// - SeeAlso: ``HTTPRequest/method``
public enum HTTPMethod: String, Sendable {
    /// The GET method requests a representation of the specified resource.
    case get = "GET"
    
    /// The POST method submits an entity to the specified resource, often causing
    /// a change in state or side effects on the server.
    case post = "POST"
    
    /// The PUT method replaces all current representations of the target resource
    /// with the request payload.
    case put = "PUT"
    
    /// The PATCH method applies partial modifications to a resource.
    case patch = "PATCH"
    
    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"
    
    /// The HEAD method asks for a response identical to a GET request,
    /// but without the response body.
    case head = "HEAD"
    
    /// The OPTIONS method describes the communication options for the target resource.
    case options = "OPTIONS"
}
