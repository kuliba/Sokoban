//
//  LoadNanoServicesTests.swift
//
//
//  Created by Igor Malyarov on 07.01.2025.
//

/// `LoadNanoServices` provides a mechanism to load "latest" and "operators" data
/// for a given category asynchronously. It handles error scenarios and ensures
/// results are only delivered when valid operators are available.
final class LoadNanoServices<Category, Latest, Operator> {
    
    /// Callback for loading the latest items.
    let loadLatest: LoadLatest
    
    /// Callback for loading operators.
    let loadOperators: LoadOperators
    
    /// Initializes with the required loaders.
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
    }
}

extension LoadNanoServices {
    
    /// Completion handler for loading latest items.
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    
    /// Function type for loading latest items for a given category.
    typealias LoadLatest = (Category, @escaping LoadLatestCompletion) -> Void
    
    /// Completion handler for loading operators.
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    
    /// Function type for loading operators for a given category.
    typealias LoadOperators = (Category, @escaping LoadOperatorsCompletion) -> Void
}

extension LoadNanoServices {
    
    /// Represents a successful result containing latest items and operators.
    struct Success {
        
        /// Non-empty list of latest items.
        let latest: [Latest]
        
        /// Non-empty list of operators.
        // TODO: enforce non-empty
        let operators: [Operator]
    }
    
    /// Completion handler for the combined loading process.
    typealias LoadCompletion = (Success?) -> Void
    
    /// Executes the combined loading process for a given category.
    /// - Calls `loadOperators` first and validates results before calling `loadLatest`.
    /// - Delivers `nil` if operators fail to load or are empty.
    /// - Provides a `Success` object on valid results.
    func load(
        category: Category,
        completion: @escaping LoadCompletion
    ) {
        loadOperators(category) { [weak self] in
            
            guard let self else { return }
            
            guard case let .success(operators) = $0,
                  !operators.isEmpty
            else { return completion(nil) }
            
            loadLatest(category) { [weak self] in
                
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
    
    func test_load_shouldCallLoadOperatorsWithCategory() {
        
        let category = makeCategory()
        let (sut, _, loadOperators) = makeSUT()
        
        sut.load(category: category) { _ in }
        
        XCTAssertNoDiff(loadOperators.payloads, [category])
    }
    
    func test_load_shouldDeliverNil_onLoadOperatorsFailure() {
        
        let (sut, _, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: nil
        ) {
            loadOperators.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldNotDeliverResult_onInstanceDeallocation() {
        
        var sut: SUT?
        let loadOperators: LoadOperatorsSpy
        (sut, _, loadOperators) = makeSUT()
        var callCount = 0
        
        sut?.load(category: makeCategory()) { _ in callCount += 1 }
        sut = nil
        loadOperators.complete(with: .failure(anyError()))
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_load_shouldDeliverNil_onEmptyLoadOperators() {
        
        let (sut, _, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: nil
        ) {
            loadOperators.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onOneLoadOperatorsLoadLatestFailure() {
        
        let operators = [makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: [], operators: operators)
        ) {
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
        
        sut?.load(category: makeCategory()) { _ in callCount += 1 }
        loadOperators.complete(with: .success([makeOperator()]))
        sut = nil
        loadLatest.complete(with: .success([]))
        
        XCTAssertEqual(callCount, 0)
    }
    
    func test_load_shouldCallLoadLatestWithCategory() {
        
        let category = makeCategory()
        let operators = [makeOperator(), makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            with: category,
            toDeliver: .init(latest: [], operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .failure(anyError()))
            
            XCTAssertNoDiff(loadLatest.payloads, [category])
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onTwoLoadOperatorsLoadLatestFailure() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: [], operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onOneLoadOperatorsEmptyLoadLatest() {
        
        let operators = [makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: [], operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccessWithEmptyLatest_onTwoLoadOperatorsEmptyLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: [], operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverSuccess_onOneLoadOperatorsOneLoadLatest() {
        
        let operators = [makeOperator()]
        let latest = [makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: latest, operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onTwoLoadOperatorsOneLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let latest = [makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: latest, operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onOneLoadOperatorsTwoLoadLatest() {
        
        let operators = [makeOperator()]
        let latest = [makeLatest(), makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: latest, operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    func test_load_shouldDeliverSuccess_onTwoLoadOperatorsTwoLoadLatest() {
        
        let operators = [makeOperator(), makeOperator()]
        let latest = [makeLatest(), makeLatest()]
        let (sut, loadLatest, loadOperators) = makeSUT()
        
        expect(
            sut,
            toDeliver: .init(latest: latest, operators: operators)
        ) {
            loadOperators.complete(with: .success(operators))
            loadLatest.complete(with: .success(latest))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadNanoServices<Category, Latest, Operator>
    private typealias LoadLatestSpy = Spy<Category, Result<[Latest], Error>>
    private typealias LoadOperatorsSpy = Spy<Category, Result<[Operator], Error>>
    
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
    
    private struct Category: Equatable {
        
        let value: String
    }
    
    private func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
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
        with category: Category? = nil,
        toDeliver expected: SUT.Success?,
        on action: () -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load(category: category ?? makeCategory()) {
            
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
