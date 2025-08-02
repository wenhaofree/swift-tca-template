import Dependencies
import DependenciesMacros
import Foundation

// MARK: - Network Client Protocol

@DependencyClient
public struct NetworkClient: Sendable {
  public var request: @Sendable (NetworkRequest) async throws -> Data
  public var upload: @Sendable (NetworkRequest, Data) async throws -> Data
  public var download: @Sendable (NetworkRequest) async throws -> URL
}

// MARK: - Network Request

public struct NetworkRequest: Sendable {
  public let url: URL
  public let method: HTTPMethod
  public let headers: [String: String]
  public let body: Data?
  public let timeout: TimeInterval
  
  public init(
    url: URL,
    method: HTTPMethod = .GET,
    headers: [String: String] = [:],
    body: Data? = nil,
    timeout: TimeInterval = 30.0
  ) {
    self.url = url
    self.method = method
    self.headers = headers
    self.body = body
    self.timeout = timeout
  }
}

// MARK: - HTTP Method

public enum HTTPMethod: String, Sendable, CaseIterable {
  case GET = "GET"
  case POST = "POST"
  case PUT = "PUT"
  case DELETE = "DELETE"
  case PATCH = "PATCH"
  case HEAD = "HEAD"
  case OPTIONS = "OPTIONS"
}

// MARK: - Network Error

public enum NetworkError: Error, Equatable, LocalizedError, Sendable {
  case invalidURL(String)
  case noData
  case invalidResponse
  case httpError(statusCode: Int, data: Data?)
  case decodingError(String)
  case encodingError(String)
  case timeout
  case noInternetConnection
  case serverError(String)
  case unknown(String)
  
  public var errorDescription: String? {
    switch self {
    case .invalidURL(let url):
      return "Invalid URL: \(url)"
    case .noData:
      return "No data received from server"
    case .invalidResponse:
      return "Invalid response from server"
    case .httpError(let statusCode, _):
      return "HTTP error with status code: \(statusCode)"
    case .decodingError(let message):
      return "Failed to decode response: \(message)"
    case .encodingError(let message):
      return "Failed to encode request: \(message)"
    case .timeout:
      return "Request timed out"
    case .noInternetConnection:
      return "No internet connection"
    case .serverError(let message):
      return "Server error: \(message)"
    case .unknown(let message):
      return "Unknown error: \(message)"
    }
  }
}

// MARK: - Request Builder

public struct RequestBuilder {
  private var baseURL: URL
  private var path: String = ""
  private var method: HTTPMethod = .GET
  private var headers: [String: String] = [:]
  private var queryItems: [URLQueryItem] = []
  private var body: Data?
  private var timeout: TimeInterval = 30.0
  
  public init(baseURL: URL) {
    self.baseURL = baseURL
  }
  
  public func path(_ path: String) -> Self {
    var builder = self
    builder.path = path
    return builder
  }
  
  public func method(_ method: HTTPMethod) -> Self {
    var builder = self
    builder.method = method
    return builder
  }
  
  public func header(_ key: String, _ value: String) -> Self {
    var builder = self
    builder.headers[key] = value
    return builder
  }
  
  public func headers(_ headers: [String: String]) -> Self {
    var builder = self
    builder.headers.merge(headers) { _, new in new }
    return builder
  }
  
  public func query(_ name: String, _ value: String?) -> Self {
    var builder = self
    if let value = value {
      builder.queryItems.append(URLQueryItem(name: name, value: value))
    }
    return builder
  }
  
  public func body<T: Encodable>(_ object: T) throws -> Self {
    var builder = self
    builder.body = try JSONEncoder().encode(object)
    builder.headers["Content-Type"] = "application/json"
    return builder
  }
  
  public func body(_ data: Data, contentType: String = "application/json") -> Self {
    var builder = self
    builder.body = data
    builder.headers["Content-Type"] = contentType
    return builder
  }
  
  public func timeout(_ timeout: TimeInterval) -> Self {
    var builder = self
    builder.timeout = timeout
    return builder
  }
  
  public func build() throws -> NetworkRequest {
    var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
    
    if !queryItems.isEmpty {
      components?.queryItems = queryItems
    }
    
    guard let url = components?.url else {
      throw NetworkError.invalidURL(baseURL.appendingPathComponent(path).absoluteString)
    }
    
    return NetworkRequest(
      url: url,
      method: method,
      headers: headers,
      body: body,
      timeout: timeout
    )
  }
}

// MARK: - Response Handling

public extension NetworkClient {
  func requestDecodable<T: Decodable>(
    _ request: NetworkRequest,
    as type: T.Type,
    decoder: JSONDecoder = JSONDecoder()
  ) async throws -> T {
    let data = try await self.request(request)
    
    do {
      return try decoder.decode(type, from: data)
    } catch {
      throw NetworkError.decodingError(error.localizedDescription)
    }
  }
  
  func requestString(_ request: NetworkRequest) async throws -> String {
    let data = try await self.request(request)
    
    guard let string = String(data: data, encoding: .utf8) else {
      throw NetworkError.decodingError("Failed to decode data as UTF-8 string")
    }
    
    return string
  }
}

// MARK: - Dependency Registration

extension NetworkClient: TestDependencyKey {
  public static let testValue = Self()
}

extension DependencyValues {
  public var networkClient: NetworkClient {
    get { self[NetworkClient.self] }
    set { self[NetworkClient.self] = newValue }
  }
}

// MARK: - Common Headers

public extension RequestBuilder {
  func bearerToken(_ token: String) -> Self {
    header("Authorization", "Bearer \(token)")
  }
  
  func apiKey(_ key: String, headerName: String = "X-API-Key") -> Self {
    header(headerName, key)
  }
  
  func userAgent(_ userAgent: String) -> Self {
    header("User-Agent", userAgent)
  }
  
  func acceptJSON() -> Self {
    header("Accept", "application/json")
  }
  
  func contentTypeJSON() -> Self {
    header("Content-Type", "application/json")
  }
}
