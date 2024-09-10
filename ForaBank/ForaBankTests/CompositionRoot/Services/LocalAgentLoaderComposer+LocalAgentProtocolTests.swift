//
//  LocalAgentLoaderComposer+LocalAgentProtocolTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class LocalAgentLoaderComposer_LocalAgentProtocolTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, fromModelSpy, toModelSpy, localAgentSpy, _,_) = makeSUT()
        
        XCTAssertEqual(fromModelSpy.callCount, 0)
        XCTAssertEqual(toModelSpy.callCount, 0)
        XCTAssertEqual(localAgentSpy.storeCallCount, 0)
        XCTAssertEqual(localAgentSpy.loadCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldPerformOnInteractive() {
        
        let (sut, _,_, localAgentSpy, interactiveScheduler, _) = makeSUT()
        
        sut.load(Model.self) { _ in }
        XCTAssertNoDiff(localAgentSpy.loadCallCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(localAgentSpy.loadCallCount, 1)
    }
    
    func test_load_shouldCallLoad() {
        
        let loadPayload = Model.self
        let (sut, _,_, localAgentSpy, interactiveScheduler, _) = makeSUT()
        
        sut.load(loadPayload) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(localAgentSpy.loadCallCount, 1)
    }
    
    func test_load_shouldDeliverNilOnFailure() {
        
        let (sut, _,_,_, interactiveScheduler, _) = makeSUT(loadStub: nil)
        let exp = expectation(description: "wait for load completion")
        
        sut.load(Model.self) {
            
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
    
    func test_load_shouldCallFromModel() {
        
        let model = makeModel()
        let (sut, fromModel, _,_, interactiveScheduler, _) = makeSUT(loadStub: model)
        
        sut.load(Model.self) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(fromModel.payloads, [model])
    }
    
    func test_load_shouldDeliverLoaded() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _,_,_, interactiveScheduler, _) = makeSUT(
            fromModel: value,
            loadStub: model
        )
        let exp = expectation(description: "wait for load completion")
        
        sut.load(Model.self) {
            
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
    
    // MARK: - save
    
    func test_save_shouldPerformOnBackground() {
        
        let (sut, _,_, localAgentSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(makeValue()) { _ in }
        XCTAssertNoDiff(localAgentSpy.storeCallCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(localAgentSpy.storeCallCount, 1)
    }
    
    func test_save_shouldCallToModelWithValue() {
        
        let value = makeValue()
        let (sut, _, toModelSpy, _,_, backgroundScheduler) = makeSUT()
        
        sut.save(value) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(toModelSpy.payloads, [value])
    }
    
    func test_save_shouldCallLoadWithModel() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _,_, localAgentSpy, _, backgroundScheduler) = makeSUT(toModel: model)
        
        sut.save(value) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(localAgentSpy.storeMessages.map(\.0), [model])
        XCTAssertNoDiff(localAgentSpy.storeMessages.map(\.1), [nil])
    }
    
    func test_save_shouldCallLoadWithModelAndSerial() {
        
        let (value, model, serial) = (makeValue(), makeModel(), anyMessage())
        let (sut, _,_, localAgentSpy, _, backgroundScheduler) = makeSUT(serial: serial, toModel: model)
        
        sut.save(value) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(localAgentSpy.storeMessages.map(\.0), [model])
        XCTAssertNoDiff(localAgentSpy.storeMessages.map(\.1), [serial])
    }
    
    func test_save_shouldDeliverFailureOnFailure() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: .failure(anyError()))
        let exp = expectation(description: "wait for save completion")
        
        sut.save(makeValue()) {
            
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
    
    func test_save_shouldDeliverVoidOnSuccess() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: .success(()))
        let exp = expectation(description: "wait for save completion")
        
        sut.save(makeValue()) {
            
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
    
    // MARK: - Helpers
    
    private typealias Composer = LocalAgentLoaderComposer<Model.Type, Model, Value>
    private typealias SUT = LocalAgentLoader<Model.Type, Value>
    private typealias FromModelSpy = CallSpy<Model, Value>
    private typealias ToModelSpy = CallSpy<Value, Model>
    
    private func makeSUT(
        serial: String? = nil,
        fromModel: Value? = nil,
        toModel: Model? = nil,
        loadStub: Model? = nil,
        saveStubs: Result<Void, Error> = .success(()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fromModelSpy: FromModelSpy,
        toModelSpy: ToModelSpy,
        localAgentSpy: LocalAgentSpy<Model>,
        interactiveScheduler: TestSchedulerOf<DispatchQueue>,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let fromModelSpy = FromModelSpy(stubs: [fromModel ?? makeValue()])
        let toModelSpy = ToModelSpy(stubs: [toModel ?? makeModel()])
        let interactiveScheduler = DispatchQueue.test
        let backgroundScheduler = DispatchQueue.test
        let composer = Composer(
            fromModel: fromModelSpy.call(payload:),
            toModel: toModelSpy.call,
            interactiveScheduler: interactiveScheduler.eraseToAnyScheduler(),
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        let localAgentSpy = LocalAgentSpy<Model>(
            loadStub: loadStub, 
            storeStub: saveStubs,
            serialStub: serial
        )
        let sut = composer.compose(agent: localAgentSpy)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(localAgentSpy, file: file, line: line)
        
        return (sut, fromModelSpy, toModelSpy, localAgentSpy, interactiveScheduler, backgroundScheduler)
    }
    
    private struct Model: Codable, Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
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
