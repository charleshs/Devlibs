import Foundation
import os.log
import Devlibs_core

/// A class that provides an universal functionality to perform data-fetching tasks using `URLSession`.
/// It supports both direct output as `Data` and conversion of response into any `Decodable` type.
/// For debugging purposes, `HttpClient` accepts an `OSLog` object with which programmers then
/// can access the auto-generated logs using `Console.app` on the MacOS .
public final class HttpClient {
    /// Errors thrown by `HttpClient`.
    public enum Error: LocalizedError {
        case requestBuilderError(Swift.Error)
        case networkError(Swift.Error)
        case noResponse
        case notHttpResponse(URLResponse?)
        case httpStatusError(_ response: HTTPURLResponse, data: Data?)
        case dataIsNil
        case responseModifierError(Swift.Error)
        case malformedBody(Data, decodingError: Swift.Error)

        public var errorDescription: String? {
            switch self {
            case .requestBuilderError(let error):
                return "Failed building request: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .noResponse:
                return "Server did not provide a response"
            case .notHttpResponse:
                return "Received an unknown response"
            case .httpStatusError(let httpResponse, _):
                return "HTTP status code: \(httpResponse.statusCode)"
            case .dataIsNil:
                return "Received an empty response body"
            case .responseModifierError(let error):
                return "Failed modifying response: \(error.localizedDescription)"
            case .malformedBody(_, let error):
                return "Malformed response: \(error.localizedDescription)"
            }
        }

        fileprivate var logMessage: String {
            switch self {
            case .requestBuilderError(let error):
                return "[HttpClient] Failed preparing request: \(error.localizedDescription)"
            case .networkError(let error):
                return "[HttpClient] \(error.localizedDescription)"
            case .noResponse:
                return "[HttpClient] Server did not provide a response"
            case .notHttpResponse(let response):
                return ["[HttpClient] Received an unknown response:", response?.description].compactMap { $0 }.joined(separator: " ")
            case .httpStatusError(let response, let data):
                let dataString = (data ?? Data()).utf8String
                return ["[HttpClient] HTTP status code: \(response.statusCode)", dataString].compactMap { $0 }.joined(separator: "\n")
            case .dataIsNil:
                return "[HttpClient] Received an empty response body"
            case .responseModifierError(let error):
                return "[HttpClient] Failed modifying response: \(error.localizedDescription)"
            case .malformedBody(let data, let error):
                return ["[HttpClient] \(error.localizedDescription)", data.utf8String].compactMap { $0 }.joined(separator: "\n")
            }
        }
    }

    public typealias Completion<T> = (Result<T, Error>) -> Void

    /// The `URLSession` object used by the client.
    public let session: URLSession

    /// The `OSLog` object used for logging.
    public let log: OSLog?

    @Protected
    private var processingTasks: [UUID: URLSessionDataTask] = [:]

    /// Creates a new object of `HttpClient`.
    /// - Parameters:
    ///   - session: An object of `URLSession`, `.shared` by default.
    ///   - log: An object of `OSLog`.
    public required init(session: URLSession = .shared, log: OSLog? = nil) {
        self.session = session
        self.log = log
    }

    // MARK: - Public methods

    /// Performs a netowrking task on the provided `HttpResource`.
    /// - Parameters:
    ///   - resource: The resource for the networking task.
    ///   - completion: The completion block that accepts and handles the fetched `Data`.
    /// - Returns: The networking task that is processed.
    @discardableResult
    public func fetchData<ResourceType: HttpResource>(
        for resource: ResourceType,
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask {
        return performRequest(resource.urlRequest, completion: completion)
    }

    /// Performs a netowrking task on the provided `Request`.
    /// - Parameters:
    ///   - request: The request for the networking task.
    ///   - completion: The completion block that accepts and handles the fetched `Data`.
    /// - Returns: The networking task that is processed.
    @discardableResult
    public func fetchData<RequestType: Request>(
        for request: RequestType,
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask? {
        return performRequest(request, completion: completion)
    }

    /// Performs a networking task on the provided `HttpResource` and decodes the response as the specified type.
    /// - Parameters:
    ///   - resource: The resource for the networking task.
    ///   - responseDecodingType: The type as which the response is decoded.
    ///   - decoder: A `JSONDecoder`. Defaults to `JSONDecoder()`.
    ///   - completion: The completion block that accepts and handles the fetched and decoded `Body` value.
    /// - Returns: The networking task that is processed.
    @discardableResult
    public func fetchResponse<ResourceType: HttpResource, Body: Decodable>(
        for resource: ResourceType,
        responseDecodingType: Body.Type = Body.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping Completion<Body>
    ) -> URLSessionDataTask {
        let uuid = UUID()
        let identifier = uuid.dataTaskIdentifier
        let urlReqeust = resource.urlRequest

        let completionHandler = Delegation<Result<Body, Error>, Void>.create(on: self) { client, result in
            completion(result)

            switch result {
            case .failure(let error):
                client.logError(urlReqeust, identifier: identifier, error: error)
            case .success(let response):
                client.logDecodingResponse(identifier: identifier, response: response)
            }
        }

        return performRequest(urlReqeust, uuid: uuid) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                do {
                    let body = try decoder.decode(Body.self, from: data)
                    completionHandler.invoke(.success(body))
                }
                catch {
                    completionHandler.invoke(.failure(.malformedBody(data, decodingError: error)))
                }
            }
        }
    }

    /// Performs a networking task on the provided `Request` and decodes the response as the specified type.
    /// - Parameters:
    ///   - request: The request for the networking task.
    ///   - responseDecodingType: The type as which the response is decoded.
    ///   - decoder: A `JSONDecoder`. Defaults to `JSONDecoder()`.
    ///   - completion: The completion block that accepts and handles the fetched and decoded `Body` value.
    /// - Returns: The networking task that is processed.
    public func fetchResponse<RequestType: Request, Body: Decodable>(
        for request: RequestType,
        responseDecodingType: Body.Type = Body.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping Completion<Body>
    ) -> URLSessionDataTask? {
        let uuid = UUID()
        let identifier = uuid.dataTaskIdentifier

        let completionHandler = Delegation<Result<Body, Error>, Void>.create(on: self) { client, result in
            completion(result)

            switch result {
            case .failure(let error):
                client.logError(request.resource.urlRequest, identifier: identifier, error: error)
            case .success(let response):
                client.logDecodingResponse(identifier: identifier, response: response)
            }
        }

        return performRequest(request, uuid: uuid) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                do {
                    let body = try decoder.decode(Body.self, from: data)
                    completionHandler.invoke(.success(body))
                }
                catch {
                    completionHandler.invoke(.failure(.malformedBody(data, decodingError: error)))
                }
            }
        }
    }

    /// Cancels a `URLSessionDataTask`
    /// - Parameter task: The task to be cancelled.
    public func cancelTask(_ task: URLSessionDataTask?) {
        guard let task = task else { return }

        $processingTasks.write { pool in
            task.cancel()
            if let uuid = pool.first(where: { (key, value) in value === task })?.key {
                pool.removeValue(forKey: uuid)

                logTaskCancelled(identifier: uuid.dataTaskIdentifier)
            }
        }
    }

    // MARK: -

    /// Performs `URLSessionDataTask` on `Request`.
    private func performRequest(
        _ request: Request,
        uuid: UUID = UUID(),
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask? {
        let errorHandler = Delegation<(URLRequest, Error), Void>.create(on: self) { client, input in
            let (urlRequest, error) = input
            completion(.failure(error))

            client.logError(urlRequest, identifier: uuid.dataTaskIdentifier, error: error)
        }

        switch request.prepareRequest() {
        // Prepare request failure
        case .failure(let error):
            errorHandler.invoke((request.resource.urlRequest, error))
            return nil
        // Prepare request successful
        case .success(let urlRequest):
            return performRequest(urlRequest, uuid: uuid) { result in
                switch result {
                // Perform request failure (error handled by `performRequest` method)
                case .failure(let error):
                    completion(.failure(error))
                // Perform request successful
                case .success(let data):
                    switch request.modifyResponse(input: data) {
                    // Modify response failure
                    case .failure(let error):
                        errorHandler.invoke((urlRequest, error))
                    // Modify response successful
                    case .success(let data):
                        completion(.success(data))
                    }
                }
            }
        }
    }

    /// Performs `URLSessionDataTask` on `URLRequest`.
    private func performRequest(
        _ request: URLRequest,
        uuid: UUID = UUID(),
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask {
        let identifier = uuid.dataTaskIdentifier

        logRequest(request, identifier: identifier)

        let removingTaskFromPoolHandler = Delegation<Void, Void>.create(on: self) { client, _ in
            client.$processingTasks.write { pool in
                pool.removeValue(forKey: uuid)
            }
            // Required because the `write` method above returns a non-void value
            return
        }

        let loggingHandler = Delegation<Result<Data, Error>, Void>.create(on: self) { client, result in
            switch result {
            case .failure(let error):
                client.logError(request, identifier: identifier, error: error)
            case .success(let data):
                client.logSuccess(request, identifier: identifier, data: data)
            }
        }

        let task = session.dataTask(with: request) { data, res, err in
            let outputResult: Result<Data, Error>

            defer {
                loggingHandler.invoke(outputResult)
                removingTaskFromPoolHandler.invoke()
                completion(outputResult)
            }

            if let error = err {
                outputResult = .failure(.networkError(error))
                return
            }
            guard let response = res else {
                outputResult = .failure(.noResponse)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                outputResult = .failure(.notHttpResponse(response))
                return
            }
            guard (200 ..< 300) ~= httpResponse.statusCode else {
                outputResult = .failure(.httpStatusError(httpResponse, data: data))
                return
            }
            guard let data = data else {
                outputResult = .failure(.dataIsNil)
                return
            }

            outputResult = .success(data)
        }

        $processingTasks.write { pool in
            pool.updateValue(task, forKey: uuid)
            task.resume()
        }

        return task
    }
}

// MARK: - Logging methods

extension HttpClient {
    private func logRequest(_ request: URLRequest, identifier: String) {
        guard let log = log else { return }

        var headersDescription = request.allHTTPHeaderFields?.map { "\($0): \($1)" }.joined(separator: "\n") ?? "nil"
        headersDescription = headersDescription.isEmpty ? "n/a" : headersDescription

        let readableRequest = """
        * URL: \(String(describing: request))
        * Headers:\n\(headersDescription)
        * Body:\n\(request.httpBody.map { $0.utf8String ?? "Body not UTF8" } ?? "nil")
        """
        log.info("\n[%@] Performing HTTP request:\n%@", identifier, readableRequest)
    }

    private func logSuccess(_ request: URLRequest, identifier: String, data: Data) {
        guard let log = log else { return }

        log.info(
            "\n[%@] Received response for \"%@\" with body:\n%@",
            identifier, String(describing: request), data.utf8String ?? String(describing: data)
        )
    }

    private func logDecodingResponse<Body: Decodable>(identifier: String, response: Body) {
        guard let log = log else { return }

        log.info(
            "[%@] Decoded response:\n%@",
            identifier, String(describing: response)
        )
    }

    private func logError(_ request: URLRequest, identifier: String, error: Error) {
        guard let log = log else { return }

        log.error(
            "\n[%@] Received error for \"%@\" with message: \n%@",
            identifier, String(describing: request), error.logMessage
        )
    }

    private func logTaskCancelled(identifier: String) {
        guard let log = log else { return }

        log.info("[%@] Task cancelled", identifier)
    }
}

// MARK: - Combine support

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension HttpClient {
    private typealias Cancellation = () -> Void

    private typealias TaskDelegation<T> = Delegation<Completion<T>, Cancellation>

    /// Returns a publisher that sends the result of type `Data` of the networking task on `HttpResource`.
    /// - Parameter resource: The resource for the networking task.
    /// - Returns: An instance of type `AnyPublisher<Data, Error>`.
    public func dataPublisher<ResourceType: HttpResource>(for resource: ResourceType) -> AnyPublisher<Data, Error> {
        let dataTaskHandler = TaskDelegation<Data>.create(on: self) { client, completion in
            let task = client.fetchData(for: resource, completion: completion)
            return { client.cancelTask(task) }
        }

        return publisher(handler: dataTaskHandler)
    }

    /// Returns a publisher that sends the result of type `Data` of the networking task on `Request`.
    /// - Parameter request: The request for the networking task.
    /// - Returns: An instance of type `AnyPublisher<Data, Error>`.
    public func dataPublisher<RequestType: Request>(for request: RequestType) -> AnyPublisher<Data, Error> {
        let dataTaskHandler = TaskDelegation<Data>.create(on: self) { client, completion in
            let task = client.fetchData(for: request, completion: completion)
            return { client.cancelTask(task) }
        }

        return publisher(handler: dataTaskHandler)
    }

    /// Returns a publisher that sends the decoded response conforming to `Decodable` of the networking task on `HttpResource`.
    /// - Parameter resource: The resource for the networking task.
    /// - Returns: An instance of type `AnyPublisher<Decodable, Error>`.
    public func responsePublisher<ResourceType: HttpResource, Body: Decodable>(
        for resource: ResourceType,
        as type: Body.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Body, Error> {
        let dataTaskHandler = TaskDelegation<Body>.create(on: self) { client, completion in
            let task = client.fetchResponse(for: resource, responseDecodingType: Body.self, decoder: decoder, completion: completion)
            return { client.cancelTask(task) }
        }

        return publisher(handler: dataTaskHandler)
    }

    /// Returns a publisher that sends the decoded response conforming to `Decodable` of the networking task on `Request`.
    /// - Parameter request: The request for the networking task.
    /// - Returns: An instance of type `AnyPublisher<Decodable, Error>`.
    public func responsePublisher<RequestType: Request, Body: Decodable>(
        for request: RequestType,
        as type: Body.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Body, Error> {
        let dataTaskHandler = TaskDelegation<Body>.create(on: self) { client, completion in
            let task = client.fetchResponse(for: request, responseDecodingType: Body.self, decoder: decoder, completion: completion)
            return { client.cancelTask(task) }
        }

        return publisher(handler: dataTaskHandler)
    }

    private func publisher<T>(handler: TaskDelegation<T>) -> AnyPublisher<T, Error> {
        var cancel: Cancellation?
        return Future<T, Error> { promise in
            cancel = handler.invoke(promise)
        }
        .handleEvents(receiveCancel: cancel)
        .share()
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - Internal Extensions

private extension Data {
    var utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
}

private extension UUID {
    /// Converts UUID into a shorter identifiable string.
    var dataTaskIdentifier: String {
        return uuidString.split(separator: "-").last.map(String.init) ?? uuidString
    }
}
