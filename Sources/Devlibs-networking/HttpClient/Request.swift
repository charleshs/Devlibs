import Foundation

public protocol Request {
    var resource: HttpResource { get }
    var requestModifier: RequestModifier? { get }
    var responseModifier: ResponseModifier? { get }
}

extension Request {
    public func prepareRequest() -> Result<URLRequest, HttpClient.Error> {
        guard let requestModifier = requestModifier else {
            return .success(resource.urlRequest)
        }

        do {
            let request = try requestModifier.modify(resource.urlRequest)
            return .success(request)
        }
        catch {
            return .failure(.requestBuilderError(error))
        }
    }

    public func modifyResponse(input data: Data) -> Result<Data, HttpClient.Error> {
        guard let responseModifier = responseModifier else {
            return .success(data)
        }

        do {
            let outputData = try responseModifier.modify(input: data)
            return .success(outputData)
        }
        catch {
            return .failure(.responseModifierError(error))
        }
    }
}

/// An object that modifies a `URLRequest` instance.
public protocol RequestModifier: AnyObject {
    func modify(_ request: URLRequest) throws -> URLRequest
}

public final class AggregateRequestModifier: RequestModifier {
    private let requestModifiers: [RequestModifier]

    public init(requestModifiers: [RequestModifier]) {
        self.requestModifiers = requestModifiers
    }

    public func modify(_ request: URLRequest) throws -> URLRequest {
        return try requestModifiers.reduce(into: request) { req, modifier in
            req = try modifier.modify(req)
        }
    }
}

/// An object that modifies a `Data` instance (typically responses from a networking request).
public protocol ResponseModifier: AnyObject {
    func modify(input: Data) throws -> Data
}

public final class AggregateResponseModifier: ResponseModifier {
    private let responseModifiers: [ResponseModifier]

    public init(responseModifiers: [ResponseModifier]) {
        self.responseModifiers = responseModifiers
    }

    public func modify(input data: Data) throws -> Data {
        return try responseModifiers.reduce(into: data) { data, modifier in
            data = try modifier.modify(input: data)
        }
    }
}
