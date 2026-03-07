# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-03-07
- Fixed: Removed redundant HTTPRequest construction in the GET wrappaer.

## [1.0.0] - 2026-03-07

### Added
- Initial release of HTTPClient
- Core `HTTPClient` class with async/await support
- `HTTPRequest` and `HTTPResponse` models
- `HTTPMethod` enum with support for GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, TRACE, CONNECT
- `HTTPError` with `LocalizedError` conformance and convenience properties
- `HTTPInterceptor` protocol for middleware support
- Full `Sendable` conformance for Swift Concurrency safety
- Automatic JSON encoding/decoding with `Codable` support
- Base URL support for relative path resolution
- Query parameter support
- Custom headers support
- Configurable timeout intervals
- Comprehensive test suite using Swift Testing
- Complete documentation and examples
