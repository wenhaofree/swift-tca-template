import Dependencies
import Foundation
import NetworkClient

// MARK: - Live Network Client Implementation

extension NetworkClient: DependencyKey {
  public static let liveValue = Self(
    request: { request in
      try await performRequest(request)
    },
    upload: { request, data in
      try await performUpload(request, data: data)
    },
    download: { request in
      try await performDownload(request)
    }
  )
}

// MARK: - Private Implementation

private func performRequest(_ request: NetworkRequest) async throws -> Data {
  let urlRequest = try createURLRequest(from: request)
  
  do {
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    try validateResponse(response, data: data)
    return data
  } catch let error as NetworkError {
    throw error
  } catch {
    throw mapURLSessionError(error)
  }
}

private func performUpload(_ request: NetworkRequest, data: Data) async throws -> Data {
  var urlRequest = try createURLRequest(from: request)
  urlRequest.httpBody = data
  
  do {
    let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
    try validateResponse(response, data: responseData)
    return responseData
  } catch let error as NetworkError {
    throw error
  } catch {
    throw mapURLSessionError(error)
  }
}

private func performDownload(_ request: NetworkRequest) async throws -> URL {
  let urlRequest = try createURLRequest(from: request)
  
  do {
    let (url, response) = try await URLSession.shared.download(for: urlRequest)
    try validateResponse(response, data: nil)
    return url
  } catch let error as NetworkError {
    throw error
  } catch {
    throw mapURLSessionError(error)
  }
}

private func createURLRequest(from request: NetworkRequest) throws -> URLRequest {
  var urlRequest = URLRequest(url: request.url)
  urlRequest.httpMethod = request.method.rawValue
  urlRequest.timeoutInterval = request.timeout
  
  // Set headers
  for (key, value) in request.headers {
    urlRequest.setValue(value, forHTTPHeaderField: key)
  }
  
  // Set body
  if let body = request.body {
    urlRequest.httpBody = body
  }
  
  return urlRequest
}

private func validateResponse(_ response: URLResponse?, data: Data?) throws {
  guard let httpResponse = response as? HTTPURLResponse else {
    throw NetworkError.invalidResponse
  }
  
  let statusCode = httpResponse.statusCode
  
  switch statusCode {
  case 200...299:
    // Success - do nothing
    break
  case 400...499:
    // Client error
    throw NetworkError.httpError(statusCode: statusCode, data: data)
  case 500...599:
    // Server error
    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Server error"
    throw NetworkError.serverError(errorMessage)
  default:
    throw NetworkError.httpError(statusCode: statusCode, data: data)
  }
}

private func mapURLSessionError(_ error: Error) -> NetworkError {
  if let urlError = error as? URLError {
    switch urlError.code {
    case .notConnectedToInternet, .networkConnectionLost:
      return .noInternetConnection
    case .timedOut:
      return .timeout
    case .badURL:
      return .invalidURL(urlError.localizedDescription)
    default:
      return .unknown(urlError.localizedDescription)
    }
  }
  
  return .unknown(error.localizedDescription)
}

// MARK: - Configuration

public struct NetworkConfiguration: Sendable {
  public let baseURL: URL
  public let defaultHeaders: [String: String]
  public let timeout: TimeInterval
  
  public init(
    baseURL: URL,
    defaultHeaders: [String: String] = [:],
    timeout: TimeInterval = 30.0
  ) {
    self.baseURL = baseURL
    self.defaultHeaders = defaultHeaders
    self.timeout = timeout
  }
}

// MARK: - Convenience Methods

public extension NetworkClient {
  static func configured(with configuration: NetworkConfiguration) -> Self {
    Self(
      request: { request in
        var modifiedRequest = request
        
        // Apply default headers if not already set
        var headers = configuration.defaultHeaders
        headers.merge(request.headers) { _, new in new }
        
        modifiedRequest = NetworkRequest(
          url: request.url,
          method: request.method,
          headers: headers,
          body: request.body,
          timeout: request.timeout == 30.0 ? configuration.timeout : request.timeout
        )
        
        return try await performRequest(modifiedRequest)
      },
      upload: { request, data in
        var modifiedRequest = request
        
        // Apply default headers if not already set
        var headers = configuration.defaultHeaders
        headers.merge(request.headers) { _, new in new }
        
        modifiedRequest = NetworkRequest(
          url: request.url,
          method: request.method,
          headers: headers,
          body: request.body,
          timeout: request.timeout == 30.0 ? configuration.timeout : request.timeout
        )
        
        return try await performUpload(modifiedRequest, data: data)
      },
      download: { request in
        var modifiedRequest = request
        
        // Apply default headers if not already set
        var headers = configuration.defaultHeaders
        headers.merge(request.headers) { _, new in new }
        
        modifiedRequest = NetworkRequest(
          url: request.url,
          method: request.method,
          headers: headers,
          body: request.body,
          timeout: request.timeout == 30.0 ? configuration.timeout : request.timeout
        )
        
        return try await performDownload(modifiedRequest)
      }
    )
  }
}

// MARK: - Mock Network Client for Testing

public extension NetworkClient {
  static func mock(
    requestHandler: @escaping @Sendable (NetworkRequest) async throws -> Data = { _ in Data() },
    uploadHandler: @escaping @Sendable (NetworkRequest, Data) async throws -> Data = { _, _ in Data() },
    downloadHandler: @escaping @Sendable (NetworkRequest) async throws -> URL = { _ in URL(fileURLWithPath: "/tmp/mock") }
  ) -> Self {
    Self(
      request: requestHandler,
      upload: uploadHandler,
      download: downloadHandler
    )
  }
}
