//
//  StrategyTests.swift
//
//
//  Created by Igor Malyarov on 14.10.2024.
//

final class Strategy<T> {
    
    let primary: Load
    let fallback: Load
    
    init(
        primary: @escaping Load,
        fallback: @escaping Load
    ) {
        self.primary = primary
        self.fallback = fallback
    }
    
    typealias LoadCompletion = ([T]?) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

extension Strategy {
    
    @inlinable
    func load(
        completion: @escaping LoadCompletion
    ) {
        primary { [fallback] in
            
            switch $0 {
            case .none:
                fallback { completion($0) }
                
            case let .some(value):
                completion(value)
            }
        }
    }
}

import XCTest

final class StrategyTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, primary, fallback) = makeSUT()
        
        XCTAssertEqual(primary.callCount, 0)
        XCTAssertEqual(fallback.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallPrimary() {
        
        let (sut, primary, fallback) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(primary.callCount, 1)
        XCTAssertEqual(fallback.callCount, 0)
    }
    
    func test_load_shouldNotCallFallBack() {
        
        let (sut, _, fallback) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(fallback.callCount, 0)
    }
    
    func test_load_shouldCallFallbackOnPrimaryFailure() {
        
        let (sut, primary, fallback) = makeSUT()
        
        sut.load { _ in }
        primary.complete(with: nil)
        
        XCTAssertEqual(fallback.callCount, 1)
    }
    
    func test_load_shouldNotCallFallbackOnPrimaryEmptySuccess() {
        
        let (sut, primary, fallback) = makeSUT()
        
        sut.load { _ in }
        primary.complete(with: [])
        
        XCTAssertEqual(fallback.callCount, 0)
    }
    
    func test_load_shouldNotCallFallbackOnPrimarySuccessOfOne() {
        
        let (sut, primary, fallback) = makeSUT()
        
        sut.load { _ in }
        primary.complete(with: [makeValue()])
        
        XCTAssertEqual(fallback.callCount, 0)
    }
    
    func test_load_shouldNotCallFallbackOnPrimarySuccessOfTwo() {
        
        let (sut, primary, fallback) = makeSUT()
        
        sut.load { _ in }
        primary.complete(with: [makeValue(), makeValue()])
        
        XCTAssertEqual(fallback.callCount, 0)
    }
    
    func test_load_shouldDeliverEmptyOnPrimaryEmptySuccess() {
        
        let (sut, primary, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        primary.complete(with: [])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverOneOnPrimarySuccessOfOne() {
        
        let value = makeValue()
        let (sut, primary, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, [value])
            exp.fulfill()
        }
        primary.complete(with: [value])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverTwoOnPrimarySuccessOfTwo() {
        
        let values = [makeValue(), makeValue()]
        let (sut, primary, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        primary.complete(with: values)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverEmptyOnPrimaryFailureFallbackEmptySuccess() {
        
        let (sut, primary, fallback) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        primary.complete(with: nil)
        fallback.complete(with: [])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverFailureOnPrimaryFailureFallbackFailure() {
        
        let (sut, primary, fallback) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, nil)
            exp.fulfill()
        }
        primary.complete(with: nil)
        fallback.complete(with: nil)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverOneOnPrimaryFailureFallbackSuccessOfOne() {
        
        let value = makeValue()
        let (sut, primary, fallback) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, [value])
            exp.fulfill()
        }
        primary.complete(with: nil)
        fallback.complete(with: [value])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverTwoOnPrimaryFailureFallbackSuccessOfTwo() {
        
        let values = [makeValue(), makeValue()]
        let (sut, primary, fallback) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        primary.complete(with: nil)
        fallback.complete(with: values)
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Strategy<Value>
    private typealias LoadSpy = Spy<Void, [Value]?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        primary: LoadSpy,
        fallback: LoadSpy
    ) {
        let primary = LoadSpy()
        let fallback = LoadSpy()
        
        let sut = SUT(
            primary: primary.process(completion:),
            fallback: fallback.process(completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        
        return (sut, primary, fallback)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
