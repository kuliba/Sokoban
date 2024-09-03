//
//  StandardSelectedCategoryDestinationMicroServiceComposerTests.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

import PayHub
import XCTest

final class StandardSelectedCategoryDestinationMicroServiceComposerTests: XCTestCase {
    
    func test_makeDestination_shouldDeliverFailureOnLoadOperatorsFailure() {
        
        let failure = makeFailure()
        let (sut, _, loadOperatorsSpy,makeFailureSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            loadOperatorsSpy.complete(with: .failure(anyError()))
            makeFailureSpy.complete(with: failure)
        }
    }
    
    func test_makeDestination_shouldDeliverFailureOnEmptyLoadedOperators() {
        
        let failure = makeFailure()
        let (sut, _, loadOperatorsSpy, makeFailureSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure)) {
            
            loadOperatorsSpy.complete(with: .success([]))
            makeFailureSpy.complete(with: failure)
        }
    }
    
    func test_makeDestination_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadOperatorsSpy: LoadOperatorsSpy
        (sut, _, loadOperatorsSpy, _,_) = makeSUT()
        var receivedResult: Result<Success, Failure>?
        
        sut?.makeDestination(makeCategory()) { receivedResult = $0 }
        sut = nil
        loadOperatorsSpy.complete(with: .failure(anyError()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_makeDestination_shouldNotCallLoadLatestOnLoadOperatorsFailure() {
        
        let (sut, loadLatestSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(loadLatestSpy.callCount, 0)
    }
    
    func test_makeDestination_shouldNotCallLoadLatestOnEmptyLoadOperators() {
        
        let (sut, loadLatestSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([]))
        
        XCTAssertEqual(loadLatestSpy.callCount, 0)
    }
    
    func test_makeDestination_shouldCallLoadLatestOnOneLoadedOperator() {
        
        let (sut, loadLatestSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([makeOperator()]))
        
        XCTAssertEqual(loadLatestSpy.callCount, 1)
    }
    
    func test_makeDestination_shouldCallLoadLatestOnTwoLoadedOperators() {
        
        let (sut, loadLatestSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([makeOperator(), makeOperator()]))
        
        XCTAssertEqual(loadLatestSpy.callCount, 1)
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithOneLoadedOperatorEmptyLatestOnLoadLatestFailure() {
        
        let `operator` = makeOperator()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([`operator`]))
        loadLatestSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [],
            operators: [`operator`]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithOneLoadedOperatorEmptyLoadedLatest() {
        
        let `operator` = makeOperator()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([`operator`]))
        loadLatestSpy.complete(with: .success([]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [],
            operators: [`operator`]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithOneLoadedOperatorOneLoadedLatest() {
        
        let latest = makeLatest()
        let `operator` = makeOperator()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([`operator`]))
        loadLatestSpy.complete(with: .success([latest]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [latest],
            operators: [`operator`]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithOneLoadedOperatorTwoLoadedLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let `operator` = makeOperator()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([`operator`]))
        loadLatestSpy.complete(with: .success([latest1, latest2]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [latest1, latest2],
            operators: [`operator`]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithTwoLoadedOperatorsEmptyLatestOnLoadLatestFailure() {
        
        let (operator1, operator2) = (makeOperator(), makeOperator())
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([operator1, operator2]))
        loadLatestSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [],
            operators: [operator1, operator2]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithTwoLoadedOperatorsEmptyLoadedLatest() {
        
        let (operator1, operator2) = (makeOperator(), makeOperator())
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([operator1, operator2]))
        loadLatestSpy.complete(with: .success([]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [],
            operators: [operator1, operator2]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithTwoLoadedOperatorsOneLoadedLatest() {
        
        let latest = makeLatest()
        let (operator1, operator2) = (makeOperator(), makeOperator())
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([operator1, operator2]))
        loadLatestSpy.complete(with: .success([latest]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [latest],
            operators: [operator1, operator2]
        )])
    }
    
    func test_makeDestination_shouldCallMakeSuccessWithTwoLoadedOperatorsTwoLoadedLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let (operator1, operator2) = (makeOperator(), makeOperator())
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        sut.makeDestination(makeCategory()) { _ in }
        loadOperatorsSpy.complete(with: .success([operator1, operator2]))
        loadLatestSpy.complete(with: .success([latest1, latest2]))
        
        XCTAssertEqual(makeSuccessSpy.payloads, [.init(
            latest: [latest1, latest2],
            operators: [operator1, operator2]
        )])
    }
    
    func test_makeDestination_shouldDeliverSuccessOnOneLoadedOperatorOnLoadLatestFailure() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator()]))
            loadLatestSpy.complete(with: .failure(anyError()))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldCDeliverSuccessOnTwoLoadedOperatorsOnLoadLatestFailure() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator(), makeOperator()]))
            loadLatestSpy.complete(with: .failure(anyError()))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldDeliverSuccessOnOneLoadedOperatorEmptyLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator()]))
            loadLatestSpy.complete(with: .success([]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldCDeliverSuccessOnTwoLoadedOperatorsEmptyLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator(), makeOperator()]))
            loadLatestSpy.complete(with: .success([]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldDeliverSuccessOnOneLoadedOperatorOneLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator()]))
            loadLatestSpy.complete(with: .success([makeLatest()]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldCDeliverSuccessOnTwoLoadedOperatorsOneLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator(), makeOperator()]))
            loadLatestSpy.complete(with: .success([makeLatest()]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldDeliverSuccessOnOneLoadedOperatorTwoLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator()]))
            loadLatestSpy.complete(with: .success([makeLatest(), makeLatest()]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    func test_makeDestination_shouldCDeliverSuccessOnTwoLoadedOperatorsTwoLoadedLatest() {
        
        let success = makeSuccess()
        let (sut, loadLatestSpy, loadOperatorsSpy, _, makeSuccessSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(success)) {
            
            loadOperatorsSpy.complete(with: .success([makeOperator(), makeOperator()]))
            loadLatestSpy.complete(with: .success([makeLatest(), makeLatest()]))
            makeSuccessSpy.complete(with: success)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Composer = StandardSelectedCategoryDestinationMicroServiceComposer<Latest, Category, Operator, Success, Failure>
    private typealias SUT = Composer.MicroService
    private typealias LoadOperatorsSpy = Spy<Void, Result<[Operator], Error>>
    private typealias LoadLatestSpy = Spy<Void, Result<[Latest], Error>>
    private typealias MakeFailureSpy = Spy<Void, Failure>
    private typealias MakeSuccessSpy = Spy<Composer.NanoServices.MakeSuccessPayload, Success>
    
    private func makeSUT(
        with category: Category? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadLatestSpy: LoadLatestSpy,
        loadOperatorsSpy: LoadOperatorsSpy,
        makeFailureSpy: MakeFailureSpy,
        makeSuccessSpy: MakeSuccessSpy
    ) {
        let loadOperatorsSpy = LoadOperatorsSpy()
        let loadLatestSpy = LoadLatestSpy()
        let makeFailureSpy = MakeFailureSpy()
        let makeSuccessSpy = MakeSuccessSpy()
        let composer = Composer(nanoServices: .init(
            loadLatest: loadLatestSpy.process(completion:),
            loadOperators: loadOperatorsSpy.process(completion:),
            makeFailure: makeFailureSpy.process(completion:),
            makeSuccess: makeSuccessSpy.process(_:completion:)
        ))
        let sut = composer.compose(with: category ?? makeCategory())
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(loadOperatorsSpy, file: file, line: line)
        trackForMemoryLeaks(loadLatestSpy, file: file, line: line)
        trackForMemoryLeaks(makeFailureSpy, file: file, line: line)
        trackForMemoryLeaks(makeSuccessSpy, file: file, line: line)
        
        return (sut, loadLatestSpy, loadOperatorsSpy, makeFailureSpy, makeSuccessSpy)
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
