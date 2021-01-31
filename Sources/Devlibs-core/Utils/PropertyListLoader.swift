import Foundation

/// A static object that loads property-lists.
public struct PropertyListLoader {
    public enum Error: LocalizedError {
        case fileDoesNotExist(_ path: String)
        case dictionaryIncompatible

        public var errorDescription: String? {
            switch self {
            case .fileDoesNotExist(let path):
                return "The file attempted reading does not exist. <\(path)>"
            case .dictionaryIncompatible:
                return "Failed to read the content as a dictionary."
            }
        }
    }

    private init() {}

    /// Loads content of a property-list file into a dictionary.
    /// - Parameters:
    ///   - filename: The name of the property-list file (excluding the extension).
    ///   - bundle: The bundle in which the property-list file is located.
    /// - Throws: An error of type `PropertyListLoader.Error`.
    /// - Returns: The content of the property-list file in a hash-map representation.
    @inlinable
    public static func dictionary(from filename: String, in bundle: Bundle) throws -> [String: Any] {
        guard let path = bundle.path(forResource: filename, ofType: "plist") else {
            throw Error.fileDoesNotExist("\(bundle.bundlePath)/\(filename).plist")
        }

        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            throw Error.dictionaryIncompatible
        }

        return dictionary
    }

    /// Loads the content of a property-list file into a decoded object of type `T`.
    /// - Parameters:
    ///   - filename: The name of the property-list file (excluding the extension).
    ///   - bundle: The bundle in which the property-list file is located.
    ///   - type: The type to which the content is decoded.
    ///   - decoder: The object that decodes the data.
    /// - Throws: An error typed `PropertyListLoader.Error`.
    /// - Returns: The content of the property-list file.
    @inlinable
    public static func object<T: Decodable>(
        from filename: String,
        in bundle: Bundle,
        ofType type: T.Type = T.self,
        using decoder: PropertyListDecoder = PropertyListDecoder()
    ) throws -> T {
        guard let path = bundle.path(forResource: filename, ofType: "plist") else {
            throw Error.fileDoesNotExist("\(bundle.bundlePath)/\(filename).plist")
        }

        let url = URL(fileURLWithPath: path)
        return try object(from: url, ofType: T.self)
    }

    /// Loads the content of a property-list file from an url into an object of type `T`.
    /// - Parameters:
    ///   - url: The url of the property-list file.
    ///   - type: The type to which the content is decoded.
    ///   - decoder: The object that decodes the data.
    /// - Throws: An error typed `PropertyListLoader.Error`.
    /// - Returns: The content of the property-list file.
    @inlinable
    public static func object<T: Decodable>(
        from url: URL,
        ofType type: T.Type = T.self,
        using decoder: PropertyListDecoder = PropertyListDecoder()
    ) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}
