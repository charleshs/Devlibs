import Combine
import XCTest
@testable import Devlibs

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ReactiveRemoveDuplicatesTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var upstreamSequence: [Int]!
    private var outputSequence: [Int]!
    private var subject: PassthroughSubject<Int, Never>!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        upstreamSequence = [1, 2, 2, 2, 3, 5, 6, 6, 8, 8]
        outputSequence = []
        subject = PassthroughSubject()
    }

    func testRemoveDuplicates() {
        let promise = expectation(description: "remove-duplicates")
        subject
            .removeDuplicates(onIgnored: { _ in })
            .sink { [weak self] comp in
                XCTAssertEqual(self?.outputSequence, [1, 2, 3, 5, 6, 8])
                promise.fulfill()
            } receiveValue: { [weak self] value in
                self?.outputSequence.append(value)
            }
            .store(in: &cancellables)

        startEmittingElements()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testHandlerOnIgnored() {
        var duplicatesCount: Int = 0

        let promise = expectation(description: "on-ignored-handler")
        subject
            .removeDuplicates(onIgnored: { _ in
                duplicatesCount += 1
            })
            .sink { comp in
                XCTAssertEqual(duplicatesCount, 4)
                promise.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)

        startEmittingElements()
        waitForExpectations(timeout: 1, handler: nil)
    }

    private func startEmittingElements() {
        upstreamSequence.enumerated().forEach { (index, value) in
            subject.send(value)
            if index == upstreamSequence.endIndex - 1 {
                subject.send(completion: .finished)
            }
        }
    }
}
