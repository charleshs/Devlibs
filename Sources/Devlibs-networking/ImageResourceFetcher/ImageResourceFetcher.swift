import os.log
import Devlibs_core

#if canImport(UIKit)
import UIKit
public typealias Image = UIImage
#elseif canImport(Cocoa)
import Cocoa
public typealias Image = NSImage
#endif

public final class ImageResourceFetcher {
    public enum Error: Swift.Error {
        case invalidURL
        case dataNotImage
        case networkError(HttpClient.Error)
    }

    public typealias Completion = (Result<Image, Error>) -> Void

    private let session: URLSession
    private let log: OSLog?
    private let imageCache: Cache<String, Image>

    private var codableImageCache: Cache<String, CodableImage> {
        return imageCache.compactMap(CodableImage.init)
    }

    private lazy var httpClient = HttpClient(session: session, log: nil)

    public init(log: OSLog? = nil) {
        let session = URLSession(configuration: .default)
        session.delegateQueue.maxConcurrentOperationCount = 10
        self.session = session
        self.log = log
        self.imageCache = Cache<String, Image>(entriesTotalCost: 1000)
    }

    /// Executes an asynchronous task fetching an image through a given url string.
    /// - parameters:
    ///     - urlPath: The string representation of the url.
    ///     - completion: The completion handler offering a value of type `Result<Image, ImageResourceLoader.Error>`.
    /// - Returns: An optional value of `URLSessionDataTask`.
    @discardableResult
    public func fetchImage(urlPath: String, completion: @escaping Completion) -> URLSessionDataTask? {
        guard let resource = ImageResource(urlPath: urlPath) else {
            completion(.failure(.invalidURL))
            return nil
        }
        return fetchImage(from: resource, completion: completion)
    }

    @discardableResult
    public func fetchImage<R: HttpResource>(from resource: R, completion: @escaping Completion) -> URLSessionDataTask? {
        let cacheKey = resource.url.absoluteString

        let completionHandler = Delegation<Result<Data, HttpClient.Error>, Void>.create(on: self) { loader, result in
            switch result {
            case .failure(let error):
                completion(.failure(.networkError(error)))
            case .success(let data):
                guard let image = Image(data: data) else {
                    return completion(.failure(.dataNotImage))
                }
                loader.imageCache.insert(image, forKey: cacheKey, cost: image.cacheCost)
                completion(.success(image))
            }
        }

        if let image = imageCache.value(forKey: cacheKey) {
            completion(.success(image))
            return nil
        }

        let task = httpClient.fetchData(for: resource) {
            completionHandler.invoke($0)
        }
        task.resume()
        return task
    }
}

#if canImport(Combine)
import Combine

extension ImageResourceFetcher {
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
    public func imagePublisher(urlPath: String) -> AnyPublisher<Image, Error> {
        let loadImageHandler = Delegation<Completion, Void>.create(on: self) { loader, completion in
            loader.fetchImage(urlPath: urlPath, completion: completion)
        }

        return Future<Image, Error> { completion in
            loadImageHandler.invoke(completion)
        }
        .share()
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - Internal

private extension ImageResourceFetcher {
    struct ImageResource: HttpResource {
        let url: URL
        let httpHeaders: [HTTP.Header] = []
        let httpMethod: HTTP.Method = .get
        var httpBody: Data? = nil
    }
}

private extension ImageResourceFetcher.ImageResource {
    init?(urlPath: String) {
        guard let url = URL(string: urlPath) else {
            return nil
        }
        self.url = url
    }
}

private extension Image {
    var cacheCost: Int {
        let totalPoints = size.width * size.height
        return Int(totalPoints / 1_000_000)
    }
}

private struct CodableImage: Codable {
    let base64EncodedString: String

    var image: Image? {
        guard let imageData = Data(base64Encoded: base64EncodedString) else {
            return nil
        }
        return Image(data: imageData)
    }

    init?(image: Image) {
        #if os(macOS)
        guard let imageData = image.tiffRepresentation else {
            return nil
        }
        #else
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return nil
        }
        #endif
        base64EncodedString = imageData.base64EncodedString()
    }
}
