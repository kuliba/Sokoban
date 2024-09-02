//
//  CategoryPickerDestinationMicroServiceComposerTests.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

struct CategoryPickerDestinationMicroService<Category, Success, Failure: Error> {
    
    let makeDestination: MakeDestination
}

extension CategoryPickerDestinationMicroService {
    
    typealias MakeDestinationCompletion = (Result<Success, Failure>) -> Void
    typealias MakeDestination = (Category, @escaping MakeDestinationCompletion) -> Void
}

struct CategoryPickerDestinationNanoServices<Operator, Failure> {
    
    let loadOperators: LoadOperators
    let makeFailure: MakeFailure
}

extension CategoryPickerDestinationNanoServices {
    
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    typealias MakeFailure = (@escaping (Failure) -> Void) -> Void
}

final class CategoryPickerDestinationMicroServiceComposer<Category, Operator, Success, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = CategoryPickerDestinationNanoServices<Operator, Failure>
}

extension CategoryPickerDestinationMicroServiceComposer {
    
    func compose(
        with category: Category
    ) -> MicroService {
        
        return .init(makeDestination: makeDestination)
    }
    
    typealias MicroService = CategoryPickerDestinationMicroService<Category, Success, Failure>
}

private extension CategoryPickerDestinationMicroServiceComposer {
    
    func makeDestination(
        category: Category,
        completion: @escaping MicroService.MakeDestinationCompletion
    ) {
        nanoServices.loadOperators { [weak self] in self?.handle($0, completion) }
    }
    
    func handle(
        _ result: Result<[Operator], Error>,
        _ completion: @escaping MicroService.MakeDestinationCompletion
    ) {
        nanoServices.makeFailure { completion(.failure($0)) }
    }
}

import XCTest

final class CategoryPickerDestinationMicroServiceComposerTests: XCTestCase {
    
    func test_makeDestination_shouldFailOnLoadOperatorsFailure() {
        
        let failure = makeFailure()
        let (sut, loadOperatorsSpy, _, makeFailureSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            loadOperatorsSpy.complete(with: .failure(anyError()))
            makeFailureSpy.complete(with: failure)
        }
    }
    
    func test_makeDestination_shouldFailOnEmptyLoadedOperators() {
        
        let failure = makeFailure()
        let (sut, loadOperatorsSpy, _, makeFailureSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            loadOperatorsSpy.complete(with: .success([]))
            makeFailureSpy.complete(with: failure)
        }
    }
    
    func test_makeDestination_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadOperatorsSpy: LoadOperatorsSpy
        (sut, loadOperatorsSpy, _, _) = makeSUT()
        var receivedResult: Result<Success, Failure>?
        
        sut?.makeDestination(makeCategory()) { receivedResult = $0 }
        sut = nil
        loadOperatorsSpy.complete(with: .failure(anyError()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_makeDestination_shouldNotCallLoadLatestOnLoadOperatorsFailure() {
        
        let (sut, loadOperatorsSpy, loadLatestSpy, _) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(loadLatestSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = CategoryPickerDestinationMicroServiceComposer<Category, Operator, Success, Failure>
    private typealias SUT = Composer.MicroService
    private typealias LoadOperatorsSpy = Spy<Void, Result<[Operator], Error>>
    private typealias LoadLatestSpy = Spy<Void, Result<[Latest], Error>>
    private typealias MakeFailureSpy = Spy<Void, Failure>
    
    private func makeSUT(
        with category: Category? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadOperatorsSpy: LoadOperatorsSpy,
        loadLatestSpy: LoadLatestSpy,
        makeFailureSpy: MakeFailureSpy
    ) {
        let loadOperatorsSpy = LoadOperatorsSpy()
        let loadLatestSpy = LoadLatestSpy()
        let makeFailureSpy = MakeFailureSpy()
        let composer = Composer(nanoServices: .init(
            loadOperators: loadOperatorsSpy.process(completion:),
            makeFailure: makeFailureSpy.process(completion:)
        ))
        let sut = composer.compose(with: category ?? makeCategory())
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(loadOperatorsSpy, file: file, line: line)
        trackForMemoryLeaks(makeFailureSpy, file: file, line: line)
        
        return (sut, loadOperatorsSpy, loadLatestSpy, makeFailureSpy)
    }
    
    private struct Category: Equatable {
        
        let value: String
    }
    
    private func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
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
    
    private struct Latest: Error, Equatable {
        
        let value: String
    }
    
    private func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
    
    private struct Operator: Error, Equatable {
        
        let value: String
    }
    
    private func makeOperator(
        _ value: String = anyMessage()
    ) -> Operator {
        
        return .init(value: value)
    }
    
    private struct Success: Equatable {
        
        let value: String
    }
    
    private func makeSuccess(
        _ value: String = anyMessage()
    ) -> Success {
        
        return .init(value: value)
    }
    
    private func expect(
        _ sut: SUT,
        with category: Category? = nil,
        toDeliver expectedResult: Result<Success, Failure>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.makeDestination(category ?? makeCategory()) {
            
            exp.fulfill()
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
