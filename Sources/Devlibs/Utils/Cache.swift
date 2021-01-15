import Foundation

/// A fully Swift-compatible cache with support for time-based rejection, on-disk persistence,
/// and a limit on the number or cost of entries it contains.
public final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let keyTracker = KeyTracker()
    private let dateProvider: () -> Date
    private let entryLifespan: TimeInterval

    /// Creates a `Cache` object.
    /// - Parameters:
    ///   - dateProvider: A closure that returns a `Date` used to determine the validity of entries. Use `Date.init` as default.
    ///   - entryLifespan: The entry's lifespan expressed in seconds. Defaults to 12 hours.
    ///   - maximumEntryCount: The maximum number of objects the cache should hold. Defaults to `0` (unlimited).
    ///   - entriesTotalCost: The maximum total cost that the cache can hold before it starts evicting objects. Defaults to `0` (unlimited).
    public init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifespan: TimeInterval = 12 * 60 * 60,
        maximumEntryCount: Int = 0,
        entriesTotalCost: Int = 0
    ) {
        self.dateProvider = dateProvider
        self.entryLifespan = entryLifespan

        wrapped.delegate = keyTracker
        wrapped.countLimit = maximumEntryCount
        wrapped.totalCostLimit = entriesTotalCost
    }

    /// Inserts an object to the cache.
    /// - Parameters:
    ///   - value: The object to store in the cache.
    ///   - key: The key with which to associate the value.
    ///   - cost: The cost with which to associate the key-value pair.
    public func insert(_ value: Value, forKey key: Key, cost: Int = 0) {
        let expiration = dateProvider().addingTimeInterval(entryLifespan)
        let entry = Entry(key: key, value: value, expiration: expiration, cost: cost)
        wrapped.setObject(entry, forKey: WrappedKey(key), cost: cost)
        keyTracker.keys.insert(key)
    }

    /// Returns the value associated with a given key.
    /// - Parameter key: An object identifying the value.
    public func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider().addingTimeInterval(entryLifespan) < entry.expiration else {
            removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    /// Removes the value of the specified key in the cache.
    /// - Parameter key: The key identifying the value to be removed.
    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    public func removeAll() {
        wrapped.removeAllObjects()
    }

    public subscript(_ key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                return removeValue(forKey: key)
            }
            insert(value, forKey: key)
        }
    }

    /// Returns an array of cached `Entry`
    private func getEntries() -> [Entry] {
        return keyTracker.keys.compactMap { key in
            wrapped.object(forKey: WrappedKey(key))
        }
    }
}

// MARK: - Transformation

extension Cache {
    /// Returns a cache object containing results of mapping the given closure over values of the current cache.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of type `Value` as its parameter
    ///                        and returns a transformed value of the same or of a different type.
    /// - Returns: A cache object with its `Value` of type `T`.
    public func map<T>(_ transform: (Value) -> T) -> Cache<Key, T> {
        let newCache = mutated(newValueType: T.self)
        let entries = getEntries()
        entries.forEach { entry in
            newCache.insert(transform(entry.value), forKey: entry.key, cost: entry.cost)
        }

        return newCache
    }

    /// Returns a cache object containing non-`nil` results of mapping the given closure over values of the current cache.
    /// - Parameter transform: A closure that accepts a value of the current cache as its argument and returns an optional value.
    /// - Returns: A cache object with its `Value` of type `T`.
    public func compactMap<T>(_ transform: (Value) -> T?) -> Cache<Key, T> {
        let newCache = mutated(newValueType: T.self)
        let entries = getEntries()
        entries.forEach { entry in
            guard let newValue = transform(entry.value) else { return }
            newCache.insert(newValue, forKey: entry.key, cost: entry.cost)
        }

        return newCache
    }

    /// Returns a new cache with the same `Key` but different `Value`.
    /// - Parameter newValueType: The new `Value` type of the created cache.
    private func mutated<T>(newValueType: T.Type) -> Cache<Key, T> {
        return Cache<Key, T>(
            dateProvider: dateProvider,
            entryLifespan: entryLifespan,
            maximumEntryCount: wrapped.countLimit,
            entriesTotalCost: wrapped.totalCostLimit
        )
    }
}

// MARK: - Codable Conformance

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach { entry in
            insert(entry.value, forKey: entry.key, cost: entry.cost)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let entries: [Entry] = getEntries()
        try container.encode(entries)
    }
}

// MARK: - Persistence

extension Cache where Key: Codable, Value: Codable {
    public enum PersistError: Swift.Error {
        case cacheFolderDoesNotExist
    }

    public static func readFromDisk(filename: String, fileManager: FileManager = .default) throws -> Cache {
        let fileURL = try getFileURL(filename: filename, fileManager: fileManager)
        let data = try Data(contentsOf: fileURL)

        return try JSONDecoder().decode(Cache.self, from: data)
    }

    private static func getFileURL(filename: String, fileManager: FileManager) throws -> URL {
        guard let cacheFolderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw PersistError.cacheFolderDoesNotExist
        }

        let fullFilename = [filename, "cache"].joined(separator: ".")
        return cacheFolderURL.appendingPathComponent(fullFilename)
    }

    public func saveToDisk(filename: String, fileManager: FileManager = .default) throws {
        let fileURL = try Self.getFileURL(filename: filename, fileManager: fileManager)
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}

// MARK: - Internal Types

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys: Set<Key> = []

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }

    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int {
            return key.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }

    final class Entry {
        let key: Key
        let value: Value
        let expiration: Date
        let cost: Int

        init(key: Key, value: Value, expiration: Date, cost: Int) {
            self.key = key
            self.value = value
            self.expiration = expiration
            self.cost = cost
        }
    }
}
