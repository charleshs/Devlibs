#if canImport(UIKit)
import UIKit
public typealias ImageView = UIImageView
#elseif canImport(Cocoa)
import Cocoa
public typealias ImageView = NSImageView
#endif

private var processingTasks: [ImageView: URLSessionDataTask] = [:]

public struct ImageResourceLoaderWrapper {
    private let base: ImageView
    private let loader: ImageResourceLoader

    public init(_ base: ImageView) {
        self.base = base
        self.loader = ImageResourceLoader()
    }

    /// Loads and assigns an image to the wrapped `ImageView`.
    /// - Parameters:
    ///   - urlString: The path to the image resource.
    ///   - failureImage: An image to be displayed if the loading fails.
    ///   - placeholder: An image to be displayed while loading.
    public func setImage(from urlString: String, failureImage: Image? = nil, placeholder: Image? = nil) {
        base.image = placeholder
        let task = loader.fetchImage(urlPath: urlString) { result in
            processingTasks.removeValue(forKey: base)

            switch result {
            case .success(let image):
                base.image = image
            case .failure:
                base.image = failureImage
            }
        }
        processingTasks[base] = task
    }

    /// Cancels the task of loading image.
    public func cancel() {
        let cancelledTask = processingTasks.removeValue(forKey: base)
        cancelledTask?.cancel()
    }
}

extension ImageView {
    public var wrapped: ImageResourceLoaderWrapper {
        return ImageResourceLoaderWrapper(self)
    }
}
