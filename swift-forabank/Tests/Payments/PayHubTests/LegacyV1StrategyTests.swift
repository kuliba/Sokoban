//
//  LegacyV1StrategyTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

final class LegacyV1Strategy<Payload, Legacy, V1, Failure: Error> {
    
    private let makeLegacy: MakeLegacy
    private let makeV1: MakeV1
    
    init(
        makeLegacy: @escaping MakeLegacy,
        makeV1: @escaping MakeV1
    ) {
        self.makeLegacy = makeLegacy
        self.makeV1 = makeV1
    }
    
    typealias MakeLegacy = (Payload) -> Legacy
    typealias MakeV1 = (Payload, @escaping (Result<V1, Failure>) -> Void) -> Void
}

extension LegacyV1Strategy {
    
    enum Response {
        
        case legacy(Legacy)
        case v1(Result<V1, Failure>)
    }
    
    typealias Completion = (Response) -> Void
    
    func compose(
        isLegacy: Bool,
        payload: Payload,
        _ completion: @escaping Completion
    ) {
        if isLegacy {
            completion(.legacy(makeLegacy(payload)))
        } else {
            makeV1(payload) { completion(.v1($0)) }
        }
    }
}

import XCTest

final class LegacyV1StrategyTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, legacySpy, v1Spy) = makeSUT()
        
        XCTAssertEqual(legacySpy.callCount, 0)
        XCTAssertEqual(v1Spy.callCount, 0)
    }
    
    // MARK: - compose legacy
    
    func test_compose_shouldCallMakeLegacyWithPayload_isLegacyTrue() {
        
        let payload = makePayload()
        let (sut, legacySpy, _) = makeSUT()
        
        sut.compose(isLegacy: true, payload: payload) { _ in }
        
        XCTAssertNoDiff(legacySpy.payloads, [payload])
    }
    
    func test_compose_shouldDeliverLegacyOnLegacy_isLegacyTrue() {
        
        let legacy = makeLegacy()
        let (sut, _,_) = makeSUT(legacy: legacy)
        let exp = expectation(description: "wait for completion")
        
        sut.compose(isLegacy: true, payload: makePayload()) {
            
            switch $0 {
            case let .legacy(receivedLegacy):
                XCTAssertNoDiff(receivedLegacy, legacy)
                
            default:
                XCTFail("Expected legacy, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    // MARK: - compose v1
    
    func test_compose_shouldCallMakeV1WithPayload_isLegacyFalse() {
        
        let payload = makePayload()
        let (sut, _, v1Spy) = makeSUT()
        
        sut.compose(isLegacy: false, payload: payload) { _ in }
        
        XCTAssertNoDiff(v1Spy.payloads, [payload])
    }
    
    func test_compose_shouldDeliverFailureOnV1Failure_isLegacyFalse() {
        
        let failure = makeFailure()
        let (sut, _, v1Spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.compose(isLegacy: false, payload: makePayload()) {
            
            switch $0 {
            case let .v1(.failure(receivedFailure)):
                XCTAssertNoDiff(receivedFailure, failure)
                
            default:
                XCTFail("Expected failure, got \($0) instead")
            }
            
            exp.fulfill()
        }
        
        v1Spy.complete(with: .failure(failure))
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_compose_shouldDeliverV1OnV1Success_isLegacyFalse() {
        
        let v1 = makeV1()
        let (sut, _, v1Spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.compose(isLegacy: false, payload: makePayload()) {
            
            switch $0 {
            case let .v1(.success(receivedV1)):
                XCTAssertNoDiff(receivedV1, v1)
                
            default:
                XCTFail("Expected failure, got \($0) instead")
            }
            
            exp.fulfill()
        }
        
        v1Spy.complete(with: .success(v1))
        
        wait(for: [exp], timeout: 0.05)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LegacyV1Strategy<Payload, Legacy, V1, Failure>
    private typealias LegacySpy = CallSpy<Payload, Legacy>
    private typealias V1Spy = Spy<Payload, Result<V1, Failure>>
    
    private func makeSUT(
        legacy: Legacy? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        legacySpy: LegacySpy,
        v1Spy: V1Spy
    ) {
        let legacySpy = LegacySpy(response: legacy ?? makeLegacy())
        let v1Spy = V1Spy()
        let sut = SUT(
            makeLegacy: legacySpy.call(payload:),
            makeV1: v1Spy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(legacySpy, file: file, line: line)
        trackForMemoryLeaks(v1Spy, file: file, line: line)
        
        return (sut, legacySpy, v1Spy)
    }
    
    private struct Legacy: Equatable {
        
        let value: String
    }
    
    private func makeLegacy(
        _ value: String = anyMessage()
    ) -> Legacy {
        
        return .init(value: value)
    }
    
    private struct V1: Equatable {
        
        let value: String
    }
    
    private func makeV1(
        _ value: String = anyMessage()
    ) -> V1 {
        
        return .init(value: value)
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
}
