#if canImport(Combine)
import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publisher {
    /// Transforms into a publisher that emits an array of maximum N consecutive elements from the upstream.
    /// - Parameter size: The maximum size of the array, must be greater than 1
    ///
    /// Taken and modified from: https://github.com/CombineCommunity/CombineExt/blob/main/Sources/Operators/Nwise.swift
    public func backtrack(max size: Int) -> AnyPublisher<[Output], Failure> {
        assert(size > 1, "n must be greater than 1")

        return scan([]) { arr, item in Array((arr + [item])).suffix(size) }
            .eraseToAnyPublisher()
    }

    /// Groups the elements of the source publisher into arrays of N consecutive elements.
    ///
    /// The resulting publisher:
    ///    - does not emit anything until the source publisher emits at least N elements;
    ///    - emits an array for every element after that;
    ///    - forwards any errors or completed events.
    ///
    /// - parameter size: The size of the groups, must be greater than 1
    ///
    /// - returns: A type erased publisher that holds an array with the given size.
    public func backtrack(_ size: Int) -> AnyPublisher<[Output], Failure> {
        assert(size > 1, "n must be greater than 1")

        return scan([]) { acc, item in Array((acc + [item]).suffix(size)) }
            .filter { $0.count == size }
            .eraseToAnyPublisher()
    }

    /// Groups the elements of the source publisher into tuples of the previous and current elements
    ///
    /// The resulting publisher:
    ///    - does not emit anything until the source publisher emits at least 2 elements;
    ///    - emits a tuple for every element after that, consisting of the previous and the current item;
    ///    - forwards any error or completed events.
    ///
    /// - returns: A type erased publisher that holds a tuple with 2 elements.
    public func pairwise() -> AnyPublisher<(Output, Output), Failure> {
        return backtrack(2)
            .map { ($0[0], $0[1]) }
            .eraseToAnyPublisher()
    }

    public func withUnretained<Target: AnyObject>(_ target: Target) -> AnyPublisher<(Target, Output), Failure> {
        return compactMap { [weak target] output in target.map { ($0, output) } }
            .eraseToAnyPublisher()
    }

    public func sinkUnretained<Target: AnyObject>(
        on target: Target,
        receiveCompletion: @escaping (Target, Subscribers.Completion<Failure>) -> Void = { _, _ in },
        receiveValue: @escaping (Target, Output) -> Void
    ) -> AnyCancellable {
        return sink { [weak target] completion in
            guard let target = target else { return }
            receiveCompletion(target, completion)
        } receiveValue: { [weak target] output in
            guard let target = target else { return }
            receiveValue(target, output)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publisher where Failure == Never {
    public func assignUnretained<Root: AnyObject>(
        to target: Root,
        for keyPath: ReferenceWritableKeyPath<Root, Output>
    ) -> AnyCancellable {
        return sink { [weak target] output in
            target?[keyPath: keyPath] = output
        }
    }
}
#endif
