import Foundation

/// A property wrapper that guarantees thread-safe operations on the wrapped property.
@propertyWrapper
@dynamicMemberLookup
public final class Protected<T> {
    private let lock = Lock()

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: T {
        get {
            return lock.around { value }
        }
        set {
            lock.around { value = newValue }
        }
    }

    private var value: T

    public var projectedValue: Protected<T> {
        return self
    }

    public init(wrappedValue: T) {
        value = wrappedValue
    }

    /// Synchronously read or transform the contained value.
    /// - Parameter closure: The closure to execute.
    /// - Returns: The return value of the closure passed.
    public func read<U>(_ closure: (T) -> U) -> U {
        lock.around { closure(self.value) }
    }

    /// Synchronously modify the protected value.
    /// - Parameter closure: The closure to execute.
    /// - Returns: The modified value.
    @discardableResult
    public func write<U>(_ closure: (inout T) -> U) -> U {
        lock.around { closure(&self.value) }
    }

    public subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get {
            return lock.around { value[keyPath: keyPath] }
        }
        set {
            lock.around { value[keyPath: keyPath] = newValue }
        }
    }
}

extension Protected where T: RangeReplaceableCollection {
    /// Adds a new element to the end of this protected collection.
    /// - Parameter newElement: The `Element` to append.
    public func append(_ newElement: T.Element) {
        write { (ward: inout T) in
            ward.append(newElement)
        }
    }

    /// Adds the elements of a sequence to the end of this protected collection.
    /// - Parameter newElements: The `Sequence` to append.
    public func append<S: Sequence>(contentsOf newElements: S) where S.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }

    /// Add the elements of a collection to the end of the protected collection.
    /// - Parameter newElements: The `Collection` to append.
    public func append<C: Collection>(contentsOf newElements: C) where C.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
}

extension Protected where T == Data? {
    /// Adds the contents of a `Data` value to the end of the protected `Data`.
    /// - Parameter data: The `Data` to be appended.
    public func append(_ data: Data) {
        write { (ward: inout T) in
            ward?.append(data)
        }
    }
}

// MARK: -

private protocol Lockable {
    func lock()
    func unlock()
}

extension Lockable {
    /// Executes a closure returning a value while acquiring the lock.
    /// - Parameter closure: The closure to run.
    /// - Returns: The value the closure generated.
    func around<T>(_ closure: () -> T) -> T {
        lock()
        defer { unlock() }
        return closure()
    }

    /// Executes a closure while acquiring the lock.
    /// - Parameter closure: The closure to run.
    func around(_ closure: () -> Void) {
        lock()
        defer { unlock() }
        closure()
    }
}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
private typealias Lock = UnfairLock

/// An `os_unfair_lock` wrapper.
private final class UnfairLock: Lockable {
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    fileprivate func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
#endif

#if os(Linux)
private typealias Lock = MutexLock

/// A `pthread_mutex_t` wrapper.
private final class MutexLock: Lockable {
    private var mutex: UnsafeMutablePointer<pthread_mutex_t>

    init() {
        mutex = .allocate(capacity: 1)

        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, .init(PTHREAD_MUTEX_ERRORCHECK))

        let error = pthread_mutex_init(mutex, &attr)
        precondition(error == 0, "Failed to create pthread_mutex")
    }

    deinit {
        let error = pthread_mutex_destroy(mutex)
        precondition(error == 0, "Failed to destroy pthread_mutex")
    }

    fileprivate func lock() {
        let error = pthread_mutex_lock(mutex)
        precondition(error == 0, "Failed to lock pthread_mutex")
    }

    fileprivate func unlock() {
        let error = pthread_mutex_unlock(mutex)
        precondition(error == 0, "Failed to unlock pthread_mutex")
    }
}
#endif
