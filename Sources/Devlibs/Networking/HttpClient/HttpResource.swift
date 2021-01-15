import Foundation

public protocol HttpResource {
    // MARK: Required

    /// The URL of the HTTP resource.
    var url: URL { get }

    /// Header fields for the HTTP resource.
    var httpHeaders: [HTTP.Header] { get }

    /// The HTTP method of the resource.
    var httpMethod: HTTP.Method { get }

    /// The body of the HTTP resource.
    var httpBody: Data? { get }

    // MARK: With default implementation

    /// The `URLRequest` instance generated according to the four defined properties.
    var urlRequest: URLRequest { get }
}

extension HttpResource {
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        httpHeaders.forEach { header in
            header.modify(request: &request)
        }
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        return request
    }
}
