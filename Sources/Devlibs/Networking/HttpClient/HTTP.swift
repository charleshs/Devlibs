import Foundation

public enum HTTP {
    /// Supported HTTP methods.
    public enum Method: String {
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
        case trace = "TRACE"
        case patch = "PATCH"
    }

    /// A type representing an item in HTTP header fields.
    public enum Header {
        case authorization(Authorization)
        case contentType(ContentType)
        case userAgent(String)
        case other(key: String, value: String)

        public var key: String {
            switch self {
            case .authorization: return "Authorization"
            case .contentType: return "Content-Type"
            case .userAgent: return "User-Agent"
            case .other(let key, _): return key
            }
        }

        public var value: String {
            switch self {
            case .authorization(let authroization):
                return authroization.value
            case .userAgent(let value):
                return value
            case .contentType(let contentType):
                return contentType.value
            case .other(_, let value):
                return value
            }
        }

        public func modify(request: inout URLRequest) {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    /// A type representing the `Authorization` HTTP header field.
    public enum Authorization {
        case bearer(_ token: String)
        case other(String)

        public var value: String {
            switch self {
            case .bearer(let token):
                return "Bearer \(token)"
            case .other(let value):
                return value
            }
        }
    }

    /// A type representing the `Content-Type` HTTP header field.
    public enum ContentType {
        case formData
        case urlEncodedForm
        case json
        case plain
        case other(String)

        public var value: String {
            switch self {
            case .formData: return "multipart/form-data"
            case .urlEncodedForm: return "application/x-www-form-urlencoded;charset=utf-8"
            case .json: return "application/json;charset=utf-8"
            case .plain: return "text/plain;charset=utf-8"
            case .other(let value): return value
            }
        }
    }
}
