//
//  HTTPClient+Methods.swift
//  HTTPClient
//
//  Created by Victor on 07.03.2026.
//

import Foundation

// MARK: - HTTP Method Convenience Extensions

/// Convenience methods that provide a clean, expressive API for making HTTP requests.
///
/// These extensions add method-specific functions (`get()`, `post()`, `put()`, `patch()`, `delete()`)
/// that are more ergonomic than using `send(.method, ...)`. They handle the most common use cases
/// with sensible defaults.
///
/// ## Topics
///
/// ### GET Requests
///
/// - ``get(_:parameters:headers:timeoutInterval:)``
/// - ``get(_:parameters:headers:expecting:timeoutInterval:)``
///
/// ### POST Requests
///
/// - ``post(_:body:parameters:headers:timeoutInterval:)``
/// - ``post(_:body:expecting:parameters:headers:timeoutInterval:)``
///
/// ### PUT Requests
///
/// - ``put(_:body:parameters:headers:timeoutInterval:)``
/// - ``put(_:body:expecting:parameters:headers:timeoutInterval:)``
///
/// ### PATCH Requests
///
/// - ``patch(_:body:parameters:headers:timeoutInterval:)``
/// - ``patch(_:body:expecting:parameters:headers:timeoutInterval:)``
///
/// ### DELETE Requests
///
/// - ``delete(_:parameters:headers:timeoutInterval:)``
/// - ``delete(_:parameters:headers:expecting:timeoutInterval:)``
///
/// ## Usage Examples
///
/// ### GET Request
///
/// ```swift
/// // Simple GET
/// let response = try await client.get("/users")
///
/// // GET with query parameters
/// let response = try await client.get("/users", parameters: ["page": "1"])
///
/// // GET with type inference
/// let users: [User] = try await client.get("/users")
///
/// // GET with explicit type
/// let users = try await client.get("/users", expecting: [User].self)
/// ```
///
/// ### POST Request
///
/// ```swift
/// struct CreateUser: Encodable {
///     let name: String
///     let email: String
/// }
///
/// // POST without response decoding
/// let response = try await client.post("/users", body: newUser)
///
/// // POST with type inference
/// let user: User = try await client.post("/users", body: newUser)
///
/// // POST with explicit type
/// let user = try await client.post("/users", body: newUser, expecting: User.self)
/// ```
///
/// ### PUT Request
///
/// ```swift
/// // Update resource
/// let updated: User = try await client.put("/users/123", body: updatedData)
/// ```
///
/// ### PATCH Request
///
/// ```swift
/// // Partial update
/// let user: User = try await client.patch("/users/123", body: partialUpdate)
/// ```
///
/// ### DELETE Request
///
/// ```swift
/// // Delete without response
/// let response = try await client.delete("/users/123")
///
/// // Delete with confirmation response
/// let result: DeleteResult = try await client.delete("/users/123")
/// ```
///
/// - SeeAlso: ``HTTPClient/send(_:_:parameters:headers:body:timeoutInterval:)-3p6ri``
extension HTTPClient {

    // MARK: - GET

    public func get(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        try await send(
            .get,
            path,
            parameters: parameters,
            headers: headers,
            timeoutInterval: timeoutInterval
        )
    }

    public func get<ResponseBody: Decodable>(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        expecting: ResponseBody.Type,
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .get,
            path,
            parameters: parameters,
            headers: headers,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    public func get<ResponseBody: Decodable>(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .get,
            path,
            parameters: parameters,
            headers: headers,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    // MARK: - POST

    public func post(
        _ path: String,
        body: some Encodable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        try await send(
            .post,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
    }

    public func post<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable,
        expecting: ResponseBody.Type,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .post,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    public func post<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .post,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    // MARK: - PUT

    public func put(
        _ path: String,
        body: some Encodable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        try await send(
            .put,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
    }

    public func put<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable & Sendable,
        expecting: ResponseBody.Type,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .put,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    public func put<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable & Sendable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .put,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    // MARK: - PATCH

    public func patch(
        _ path: String,
        body: some Encodable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        try await send(
            .patch,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
    }

    public func patch<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable,
        expecting: ResponseBody.Type,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .patch,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    public func patch<ResponseBody: Decodable>(
        _ path: String,
        body: some Encodable,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .patch,
            path,
            parameters: parameters,
            headers: headers,
            body: body,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    // MARK: - DELETE

    public func delete(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> HTTPResponse {
        try await send(
            .delete,
            path,
            parameters: parameters,
            headers: headers,
            timeoutInterval: timeoutInterval
        )
    }

    public func delete<ResponseBody: Decodable>(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        expecting: ResponseBody.Type,
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .delete,
            path,
            parameters: parameters,
            headers: headers,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }

    public func delete<ResponseBody: Decodable>(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60
    ) async throws -> ResponseBody {
        try await send(
            .delete,
            path,
            parameters: parameters,
            headers: headers,
            expecting: ResponseBody.self,
            timeoutInterval: timeoutInterval
        )
    }
}
