//
//  PaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

enum PaymentEvent<Update> {
    
    case update(Update)
}

extension PaymentEvent: Equatable where Update: Equatable {}

enum PaymentEffect<Digest> {
    
    case `continue`(Digest)
}

extension PaymentEffect: Equatable where Digest: Equatable {}

final class PaymentEffectHandler<Digest, Update> {
    
    private let process: Process
    
    init(process: @escaping Process) {
        
        self.process = process
    }
}

extension PaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .continue(digest):
            process(digest, dispatch)
        }
    }
}

private extension PaymentEffectHandler {
    
    func process(
        _ digest: Digest,
        _ dispatch: @escaping Dispatch
    ) {
        process(digest) { [weak self] in
            
            guard self != nil else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                fatalError()
                
            case let .success(update):
                dispatch(.update(update))
            }
        }
    }
}

extension PaymentEffectHandler {
    
    typealias ProcessResult = Result<Update, ServiceFailure>
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias Process = (Digest, @escaping ProcessCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent<Update>
    typealias Effect = PaymentEffect<Digest>
}

import XCTest

final class PaymentEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, processing) = makeSUT()
        
        XCTAssertEqual(processing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigest() {
        
        let digest = makeDigest()
        let (sut, processing) = makeSUT()
        
        sut.handleEffect(.continue(digest)) { _ in }
        
        XCTAssertNoDiff(processing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        expect(toDeliver: .update(update), on: .continue(makeDigest()), with: .success(update))
    }
    
    func test_continue_shouldNotDeliverProcessingResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, processing) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(.continue(makeDigest())) { received.append($0) }
        sut = nil
        processing.complete(with: .success(makeUpdate()))
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentEffectHandler<Digest, Update>
    private typealias Processing = Spy<Digest, SUT.ProcessResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        processing: Processing
    ) {
        let processing = Processing()
        let sut = SUT(process: processing.process)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        
        return (sut, processing)
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        on effect: SUT.Effect,
        with processingResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, processing) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff(expectedEvent, $0, "Expected \(expectedEvent), but got \($0) instead.")
            exp.fulfill()
        }
        
        processing.complete(with: processingResult)
        
        wait(for: [exp], timeout: 1)
    }
}

private struct Digest: Equatable {
    
    let value: String
}

private struct Update: Equatable {
    
    let value: String
}

private func makeDigest(
    _ value: String = UUID().uuidString
) -> Digest {
    
    .init(value: value)
}

private func makeUpdate(
    _ value: String = UUID().uuidString
) -> Update {
    
    .init(value: value)
}
