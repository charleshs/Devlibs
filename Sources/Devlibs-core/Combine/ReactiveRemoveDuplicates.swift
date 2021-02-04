#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    /// Publishes only elements that don’t match the previous element, as evaluated by a provided closure.
    /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering.
    ///                        Return `true` from this closure to indicate that the second element is a duplicate of the first.
    /// - Parameter onIgnored: A closure to be called whenever a duplicate is removed.
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates(
        by predicate: @escaping (Output, Output) -> Bool,
        onIgnored: @escaping (Output) -> Void
    ) -> Publishers.ReactiveRemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate, reaction: onIgnored)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Equatable {
    /// Publishes only elements that don’t match the previous element.
    /// - Parameter onIgnored: A closure to be called whenever a duplicate is removed.
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates(onIgnored: @escaping (Output) -> Void) -> Publishers.ReactiveRemoveDuplicates<Self> {
        return .init(upstream: self, predicate: ==, reaction: onIgnored)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
    public struct ReactiveRemoveDuplicates<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure


        private let upstream: Upstream
        private let predicate: (Output, Output) -> Bool
        private let reaction: (Output) -> Void

        public init(upstream: Upstream, predicate: @escaping (Output, Output) -> Bool, reaction: @escaping (Output) -> Void) {
            self.upstream = upstream
            self.predicate = predicate
            self.reaction = reaction
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber, upstream: upstream, predicate: predicate, reaction: reaction)
            subscriber.receive(subscription: subscription)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publishers.ReactiveRemoveDuplicates {
    private final class Subscription<S: Subscriber, Upstream: Publisher>: Combine.Subscription where S.Input == Upstream.Output,
                                                                                                     S.Failure == Upstream.Failure {
        private var subscriber: S?
        private var cancellable: AnyCancellable?
        private var last: S.Input?

        init(
            subscriber: S,
            upstream: Upstream,
            predicate: @escaping (Upstream.Output, S.Input) -> Bool,
            reaction: @escaping (Upstream.Output) -> Void
        ) {
            cancellable = upstream.sink(
                receiveCompletion: { completion in
                    subscriber.receive(completion: completion)
                },
                receiveValue: { [unowned self] output in
                    defer { self.last = output }

                    // Ignores and performs reaction only when the following conditions are met:
                    // 1. The previous value exists
                    // 2. `output` is a duplicate of the previous value
                    if let last = self.last, predicate(output, last) {
                        return reaction(output)
                    }

                    _ = subscriber.receive(output)
                }
            )
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            cancellable = nil
        }
    }
}
#endif
