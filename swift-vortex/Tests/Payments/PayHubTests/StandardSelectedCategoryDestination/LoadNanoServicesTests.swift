//
//  LoadNanoServicesTests.swift
//
//
//  Created by Igor Malyarov on 07.01.2025.
//

final class LoadNanoServices<Latest, Operator> {
    
    let loadLatest: LoadLatest
    let loadOperators: LoadOperators
    
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
    }
}

extension LoadNanoServices {
    
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatest = (@escaping LoadLatestCompletion) -> Void
    
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
}

extension LoadNanoServices {
    
    struct Success {
        
        let latest: [Latest]
        // TODO: enforce non-empty
        let operators: [Operator]
    }
    
    typealias LoadCompletion = (Success?) -> Void
    
    func load(
        completion: @escaping LoadCompletion
    ) {
        loadOperators { [weak self] in
            
            guard let self else { return }
            
            guard case let .success(operators) = $0,
                  !operators.isEmpty
            else { return completion(nil) }
            
            loadLatest { [weak self] in
                
                guard self != nil else { return }
                
                completion(.init(
                    latest: (try? $0.get()) ?? [],
                    operators: operators
                ))
            }
        }
    }
}

extension LoadNanoServices.Success: Equatable where Latest: Equatable, Operator: Equatable {}

import PayHub
import XCTest

final class LoadNanoServicesTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loadLatest, loadOperators) = makeSUT()
        
        XCTAssertEqual(loadLatest.callCount, 0)
        XCTAssertEqual(loadOperators.callCount, 0)
    }
    
    func test_load_shouldDeliverNil_onLoadOperatorsFailure() {
        
        let (sut, _, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: nil) {
            
            loadOperators.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldNotDeliverResult_onInstanceDeallocation() {
        
        var sut: SUT?
        let loadOperators: LoadOperatorsSpy
        (sut, _, loadOperators) = makeSUT()
        var callCount = 0
        
        sut?.load { _ in callCount += 1 }
        sut = nil
        loadOperators.complete(with: .failure(anyError()))
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_load_shouldDeliverNil_onEmptyLoadOperators() {
        
        let (sut, _, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: nil) {
            
            loadOperators.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onOneLoadOperatorsLoadLatestFailure() {
        
        let operators = [makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: [], operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldNotDeliverResult_onInstanceDeallocationAfterLoadOperators() {
        
        var sut: SUT?
        let loadLatest: LoadLatestSpy
        let loadOperators: LoadOperatorsSpy
        (sut, loadLatest, loadOperators) = makeSUT()
        var callCount = 0
        
        sut?.load { _ in callCount += 1 }
        loadOperators.complete(with: .success([makeOperator()]))
        sut = nil
        loadLatest.complete(with: .success([]))
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onTwoLoadOperatorsLoadLatestFailure() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: [], operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onOneLoadOperatorsEmptyLoadLatest() {
        
        let operators = [makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: [], operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onTwoLoadOperatorsEmptyLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: [], operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccess_onOneLoadOperatorsOneLoadLatest() {
        
        let operators = [makeOperator()]
        let latest = [makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: latest, operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onTwoLoadOperatorsOneLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let latest = [makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: latest, operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onOneLoadOperatorsTwoLoadLatest() {
        
        let operators = [makeOperator()]
        let latest = [makeLatest(), makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: latest, operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onTwoLoadOperatorsTwoLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let latest = [makeLatest(), makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(sut, toDeliver: .init(latest: latest, operators: operators)) {
            
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadNanoServices<Latest, Operator>
    private typealias LoadLatestSpy = Spy<Void, Result<[Latest], Error>>
    private typealias LoadOperatorsSpy = Spy<Void, Result<[Operator], Error>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadLatest: LoadLatestSpy,
        loadOperators: LoadOperatorsSpy
    ) {
        let loadLatest = LoadLatestSpy()
        let loadOperators = LoadOperatorsSpy()
        let sut = SUT(
            loadLatest: loadLatest.process,
            loadOperators: loadOperators.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadLatest, file: file, line: line)
        trackForMemoryLeaks(loadOperators, file: file, line: line)
        
        return (sut, loadLatest, loadOperators)
    }
    
    private struct Latest: Equatable {
        
        let value: String
    }
    
    private func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
    
    private struct Operator: Equatable {
        
        let value: String
    }
    
    private func makeOperator(
        _ value: String = anyMessage()
    ) -> Operator {
        
        return .init(value: value)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expected: SUT.Success?,
        on action: () -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load {
            
            XCTAssertNoDiff(
                $0,
                expected,
                "Expected \(String(describing: expected)), but got \(String(describing: $0)) instead",
                file: file,
                line: line
            )
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
