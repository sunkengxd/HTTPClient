# HTTPClient

A Swift-native HTTP client built with Swift Concurrency (async/await).

## Features

✨ **Modern Swift Concurrency** - Built from the ground up with async/await  
🔗 **Interceptor Chain** - Middleware pattern for request/response modification  
📦 **Type-Safe** - Full `Codable` support with automatic JSON encoding/decoding  
🎯 **Flexible API** - Work with raw Data or typed models  
🔒 **Sendable-Safe** - Full concurrency safety with `Sendable` conformance  
⚙️ **Highly Configurable** - Custom encoders, decoders, sessions, and base URLs  
🪵 **Built-in Interceptors** - Logging, authentication, and retry logic included

## Requirements

- iOS 16.0+ / macOS 13.0+ / watchOS 9.0+ / tvOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunkengxd/HTTPClient.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies...
2. Enter the repository URL
3. Select the version you want to use

## Quick Start

### Three Ways to Make Requests

HTTPClient provides three API styles, from most convenient to most flexible:

#### 1. Method-Specific Extensions (Recommended) ✨

The cleanest, most readable API:

```swift
import HTTPClient

let client = HTTPClient(
    baseURL: URL(string: "https://api.example.com")
)

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// GET with type inference
let users: [User] = try await client.get("/users")

// GET with query parameters
let page1: [User] = try await client.get("/users", parameters: ["page": "1"])

// POST with body
struct CreateUser: Encodable {
    let name: String
    let email: String
}

let newUser = CreateUser(name: "Alice", email: "alice@example.com")
let created: User = try await client.post("/users", body: newUser)

// PUT for updates
let updated: User = try await client.put("/users/123", body: userData)

// PATCH for partial updates
let patched: User = try await client.patch("/users/123", body: partialData)

// DELETE
let response = try await client.delete("/users/123")
```

#### 2. Generic send() Methods

Flexible methods that accept any HTTP method:

```swift
let users = try await client.send(.get, "/users", expecting: [User].self)
let created = try await client.send(.post, "/users", body: newUser, expecting: User.self)
```

#### 3. Core send() with HTTPRequest

Full control with an HTTPRequest object:

```swift
let request = HTTPRequest(
    method: .post,
    url: URL(string: "https://api.example.com/users")!,
    headers: ["Authorization": "Bearer token"]
)
let response = try await client.send(request)
```

### Available Methods

All HTTP methods have multiple overloads for different use cases:

**GET:**
- `get(_:parameters:headers:)` → HTTPResponse
- `get(_:parameters:headers:expecting:)` → T
- `get(_:parameters:headers:)` → T (with type inference)

**POST, PUT, PATCH:**
- `post/put/patch(_:body:parameters:headers:)` → HTTPResponse
- `post/put/patch(_:body:expecting:parameters:headers:)` → T
- `post/put/patch(_:body:parameters:headers:)` → T (with type inference)

**DELETE:**
- `delete(_:parameters:headers:)` → HTTPResponse
- `delete(_:parameters:headers:expecting:)` → T
- `delete(_:parameters:headers:)` → T (with type inference)

## Interceptors

Interceptors allow you to modify requests and responses, add logging, handle authentication, implement retry logic, and more.

### Custom Interceptors

Create your own interceptors by conforming to `HTTPInterceptor`:

```swift
struct CustomHeaderInterceptor: HTTPInterceptor {
    func intercept(
        request: HTTPRequest,
        next: @Sendable (HTTPRequest) async throws -> HTTPResponse
    ) async throws -> HTTPResponse {
        var modifiedRequest = request
        modifiedRequest.headers["X-App-Version"] = "1.0.0"
        modifiedRequest.headers["X-Platform"] = "iOS"
        
        return try await next(modifiedRequest)
    }
}

// Use it
let client = HTTPClient(
    interceptors: [CustomHeaderInterceptor()]
)
```

### Chaining Interceptors

Interceptors are executed in order. The first interceptor in the array runs first:

```swift
let client = HTTPClient(
    baseURL: URL(string: "https://api.example.com"),
    interceptors: [
        LoggingInterceptor(),           // Logs first
        AuthenticationInterceptor(      // Adds auth
            authType: .bearer(token: "token")
        ),
        RetryInterceptor(maxRetries: 3) // Retries if needed
    ]
)
```

## Advanced Usage

### Custom Encoders and Decoders

```swift
let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.dateEncodingStrategy = .iso8601

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let client = HTTPClient(
    encoder: encoder,
    decoder: decoder
)
```

### Custom URLSession

```swift
let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30
configuration.waitsForConnectivity = true

let session = URLSession(configuration: configuration)
let client = HTTPClient(session: session)
```

### Working with HTTPRequest Directly

```swift
var request = HTTPRequest(
    method: .post,
    url: URL(string: "https://api.example.com/users")!
)
request.headers["Content-Type"] = "application/json"
request.body = try JSONEncoder().encode(newUser)

let response = try await client.send(request)
```

### Handling Errors

```swift
do {
    let user: User = try await client.get("/users/123")
    print("User: \(user.name)")
} catch let error as HTTPError {
    print("HTTP Error \(error.statusCode): \(error.message ?? "")")
    
    if error.isUnauthorized {
        // Handle 401 - authentication required
    } else if error.isNotFound {
        // Handle 404 - resource not found
    } else if error.isServerError {
        // Handle 5xx - server error
    }
} catch {
    print("Network error: \(error)")
}
```

### Response Inspection

```swift
// When not using type decoding
let response = try await client.get("/health")

if response.isSuccess {
    print("API is healthy")
}

// Get text content
if let text = response.text {
    print(text)
}

// Decode JSON manually if needed
let user = try response.decode(User.self)
```

## Architecture

### Core Components

- **HTTPClient** - Main client class that manages requests and interceptors
- **HTTPRequest** - Represents an HTTP request with method, URL, headers, body, and timeout
- **HTTPResponse** - Contains response data, status code, headers, and convenience properties
- **HTTPMethod** - Enum of supported HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, TRACE, CONNECT)
- **HTTPError** - Error type for failed HTTP requests with status code and response data
- **HTTPInterceptor** - Protocol for implementing middleware

### Interceptor Pattern

The client uses an interceptor chain pattern where each interceptor can:
1. Modify the request before it's sent
2. Observe or modify the response
3. Handle errors
4. Short-circuit the chain (e.g., return cached responses)

Interceptors wrap each other, forming a chain where the innermost handler performs the actual network request.

## Examples

### Complete Example: Building a REST API Client

```swift
import HTTPClient

class APIClient {
    private let client: HTTPClient
    
    init() {
        self.client = HTTPClient(
            baseURL: URL(string: "https://api.example.com")
        )
    }
    
    // List users with pagination
    func getUsers(page: Int = 1, limit: Int = 20) async throws -> [User] {
        try await client.get(
            "/users",
            parameters: [
                "page": "\(page)",
                "limit": "\(limit)"
            ]
        )
    }
    
    // Get single user
    func getUser(id: Int) async throws -> User {
        try await client.get("/users/\(id)")
    }
    
    // Create user
    func createUser(name: String, email: String) async throws -> User {
        struct CreateUser: Encodable {
            let name: String
            let email: String
        }
        
        return try await client.post(
            "/users",
            body: CreateUser(name: name, email: email)
        )
    }
    
    // Update user
    func updateUser(id: Int, name: String) async throws -> User {
        struct UpdateUser: Encodable {
            let name: String
        }
        
        return try await client.patch(
            "/users/\(id)",
            body: UpdateUser(name: name)
        )
    }
    
    // Delete user
    func deleteUser(id: Int) async throws {
        _ = try await client.delete("/users/\(id)")
    }
}

// Usage
let api = APIClient()

// List users
let users = try await api.getUsers(page: 1)

// Create user
let newUser = try await api.createUser(name: "Alice", email: "alice@example.com")

// Update user
let updated = try await api.updateUser(id: newUser.id, name: "Alice Smith")

// Delete user
try await api.deleteUser(id: newUser.id)
```

### Testing with Custom URLSession

```swift
import Testing
import HTTPClient

@Test func testAPIRequest() async throws {
    // Create a mock session for testing
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: configuration)
    
    let client = HTTPClient(session: session)
    
    // Perform test...
}
```

## Best Practices

1. **Use method-specific extensions** - They're more readable than `send(.method, ...)`
2. **Leverage type inference** - Write `let user: User = try await client.get("/users/1")`
3. **Reuse HTTPClient instances** - Create one client per API and reuse it
4. **Use base URLs** - Set a base URL to avoid repeating the same domain
5. **Configure encoders/decoders once** - Set date and key strategies during initialization
6. **Order interceptors thoughtfully** - Logging → Auth → Retry is usually a good order
7. **Handle errors appropriately** - Check for `HTTPError` to get status codes and response data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Victor Guștiuc - Created on March 7, 2026
