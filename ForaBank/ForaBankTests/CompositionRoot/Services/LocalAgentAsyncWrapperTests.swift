//
//  LocalAgentAsyncWrapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class LocalAgentAsyncWrapperTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, agent, _,_) = makeSUT()
        
        XCTAssertEqual(agent.loadCallCount, 0)
        XCTAssertEqual(agent.storeCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - composedLoad
    
    func test_composedLoad_shouldPerformOnInteractive() {
        
        let (sut, agent, interactiveScheduler, _) = makeSUT()
        let load = sut.composeLoad(fromModel: fromModel(model:))
        
        load { _ in }
        XCTAssertEqual(agent.loadCallCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertEqual(agent.loadCallCount, 1)
    }
    
    func test_composedLoad_shouldDeliverNilOnFailure() {
        
        let (sut, _, interactiveScheduler, _) = makeSUT(loadStub: nil)
        let load = sut.composeLoad(fromModel: fromModel(model:))
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            switch $0 {
            case .none:
                break
                
            case .some:
                XCTFail("Expected nil, got \(String(describing: $0)) instead.")
            }
            exp.fulfill()
        }
        
        interactiveScheduler.advance()
        wait(for: [exp], timeout: 1)
    }
    
    func test_composedLoad_shouldCallFromModel() {
        
        let model = makeModel()
        let (sut, _, interactiveScheduler, _) = makeSUT(loadStub: model)
        let fromModel = CallSpy<Model, Value>(stubs: [makeValue()])
        let load = sut.composeLoad(fromModel: fromModel.call(payload:))
        let exp = expectation(description: "wait for load completion")
        
        load { _ in exp.fulfill() }
        interactiveScheduler.advance()
        
        wait(for: [exp], timeout: 1)
        XCTAssertNoDiff(fromModel.payloads, [model])
    }
    
    func test_composedLoad_shouldDeliverLoaded() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _, interactiveScheduler, _) = makeSUT(loadStub: model)
        let fromModel = CallSpy<Model, Value>(stubs: [value])
        let load = sut.composeLoad(fromModel: fromModel.call(payload:))
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            switch $0 {
            case .none:
                XCTFail("Expected value, got nil instead.")
                
            case let .some(data):
                XCTAssertNoDiff(data, value)
            }
            exp.fulfill()
        }
        
        interactiveScheduler.advance()
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - composedSave
    
    func test_composedSave_shouldPerformOnBackground() {
        
        let (sut, agent, _, backgroundScheduler) = makeSUT()
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let save = sut.composeSave(toModel: toModel.call(payload:))
        
        save(makeValue(), anyMessage()) { _ in }
        XCTAssertNoDiff(agent.storeCallCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(agent.storeCallCount, 1)
    }
    
    func test_composedSave_shouldCallToModelWithValue() {
        
        let (value, serial) = (makeValue(), anyMessage())
        let (sut, _,_, backgroundScheduler) = makeSUT()
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let save = sut.composeSave(toModel: toModel.call(payload:))
        
        save(value, serial) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(toModel.payloads, [value])
    }
    
    func test_composedSave_shouldCallSaveWithPayload() {
        
        let (value, serial, model) = (makeValue(), anyMessage(), makeModel())
        let (sut, agent, _, backgroundScheduler) = makeSUT()
        let toModel = CallSpy<Value, Model>(stubs: [model])
        let save = sut.composeSave(toModel: toModel.call(payload:))
        
        save(value, serial) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [model])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    func test_composedSave_shouldDeliverFailureOnFailure() {
        
        let (value, serial, model) = (makeValue(), anyMessage(), makeModel())
        let (sut, _,_, backgroundScheduler) = makeSUT(saveStub: .failure(anyError()))
        let toModel = CallSpy<Value, Model>(stubs: [model])
        let save = sut.composeSave(toModel: toModel.call(payload:))
        let exp = expectation(description: "wait for save completion")
        
        save(value, serial) {
            
            switch $0 {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        backgroundScheduler.advance()
        wait(for: [exp], timeout: 1)
    }
    
    func test_composedSave_shouldDeliverVoidOnSuccess() {
        
        let (sut, _,_, backgroundScheduler) = makeSUT(saveStub: .success(()))
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let save = sut.composeSave(toModel: toModel.call(payload:))
        let exp = expectation(description: "wait for save completion")
        
        save(makeValue(), anyMessage()) {
            
            switch $0 {
            case .failure:
                XCTFail("Expected success, got \($0) instead.")
                
            case .success(()):
                break
            }
            exp.fulfill()
        }
        
        backgroundScheduler.advance()
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - composeUpdate
    
    func test_composeUpdate_shouldPerformOnBackground() {
        
        let (sut, agent, _, backgroundScheduler) = makeSUT()
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), anyMessage()) { _ in }
        XCTAssertNoDiff(agent.loadCallCount, 0)
        XCTAssertNoDiff(agent.storeCallCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(agent.loadCallCount, 1)
        XCTAssertNoDiff(agent.storeCallCount, 1)
    }
    
    func test_composeUpdate_shouldNotCallReduceOnEmptyLoad() {
        
        let (sut, _,_, backgroundScheduler) = makeSUT(
            loadStub: nil
        )
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), anyMessage()) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(reduce.callCount, 0)
    }
    
    func test_composeUpdate_shouldCallReduceOnNonEmptyLoad() {
        
        let (stored, updated) = (makeModel(), makeModel())
        let (sut, _,_, backgroundScheduler) = makeSUT(
            loadStub: stored
        )
        let toModel = CallSpy<Value, Model>(stubs: [updated])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), anyMessage()) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(reduce.payloads.map(\.0), [stored])
        XCTAssertNoDiff(reduce.payloads.map(\.1), [updated])
    }
    
    func test_composeUpdate_shouldCallStoreWithUpdateEmptySerialOnEmptyLoad() {
        
        let updated = makeModel()
        let (sut, agent, _, backgroundScheduler) = makeSUT(
            loadStub: nil
        )
        let toModel = CallSpy<Value, Model>(stubs: [updated])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), nil) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [updated])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [nil])
    }
    
    func test_composeUpdate_shouldCallStoreWithUpdateOnEmptyLoad() {
        
        let (updated, serial) = (makeModel(), anyMessage())
        let (sut, agent, _, backgroundScheduler) = makeSUT(
            loadStub: nil
        )
        let toModel = CallSpy<Value, Model>(stubs: [updated])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), serial) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [updated])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    func test_composeUpdate_shouldCallStoreWithReducesEmNonEmptySerialOnEmptyLoad() {
        
        let reduced = makeModel()
        let (sut, agent, _, backgroundScheduler) = makeSUT(
            loadStub: makeModel()
        )
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(reduced, true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), nil) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [reduced])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [nil])
    }
    
    func test_composeUpdate_shouldCallStoreWithReducesOnNonEmptyLoad() {
        
        let (reduced, serial) = (makeModel(), anyMessage())
        let (sut, agent, _, backgroundScheduler) = makeSUT(
            loadStub: makeModel()
        )
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(reduced, true)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), serial) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [reduced])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    func test_composeUpdate_shouldNotCallStoreOnNonEmptyLoadNoChanges() {
        
        let (sut, agent, _, backgroundScheduler) = makeSUT(
            loadStub: makeModel()
        )
        let toModel = CallSpy<Value, Model>(stubs: [makeModel()])
        let reduce = CallSpy<(Model, Model), (Model, Bool)>(stubs: [(makeModel(), false)])
        let update = sut.composeUpdate(
            toModel: toModel.call(payload:),
            reduce: reduce.call
        )
        
        update(makeValue(), anyMessage()) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(agent.storeCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LocalAgentAsyncWrapper
    
    private func makeSUT(
        loadStub: Model? = nil,
        saveStub: Result<Void, Error> = .failure(anyError()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        agent: LocalAgentSpy<Model>,
        interactiveScheduler: TestSchedulerOf<DispatchQueue>,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let agent = LocalAgentSpy<Model>(
            loadStub: loadStub,
            storeStub: saveStub
        )
        let interactiveScheduler = DispatchQueue.test
        let backgroundScheduler = DispatchQueue.test
        let sut = SUT(
            agent: agent,
            interactiveScheduler: interactiveScheduler.eraseToAnyScheduler(),
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(agent, file: file, line: line)
        trackForMemoryLeaks(interactiveScheduler, file: file, line: line)
        trackForMemoryLeaks(backgroundScheduler, file: file, line: line)
        
        return (sut, agent, interactiveScheduler, backgroundScheduler)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private func fromModel(model: Model) -> Value {
        
        return .init(value: model.value)
    }
    
    private struct Model: Codable, Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
}
