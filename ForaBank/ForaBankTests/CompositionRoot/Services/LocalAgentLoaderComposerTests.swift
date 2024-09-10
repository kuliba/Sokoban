//
//  LocalAgentLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class LocalAgentLoaderComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, fromModelSpy, toModelSpy, loadSpy, saveSpy, _,_) = makeSUT()
        
        XCTAssertEqual(fromModelSpy.callCount, 0)
        XCTAssertEqual(toModelSpy.callCount, 0)
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(saveSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldPerformOnInteractive() {
        
        let (sut, _,_, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(makeLoadPayload()) { _ in }
        XCTAssertNoDiff(loadSpy.callCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_load_shouldCallLoadWithPayload() {
        
        let loadPayload = makeLoadPayload()
        let (sut, _,_, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(loadPayload) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(loadSpy.payloads, [loadPayload])
    }
    
    func test_load_shouldDeliverNilOnFailure() {
        
        let (sut, _,_,_,_, interactiveScheduler, _) = makeSUT(loadStub: nil)
        let exp = expectation(description: "wait for load completion")
        
        sut.load(makeLoadPayload()) {
            
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
        let (sut, fromModel, _,_,_, interactiveScheduler, _) = makeSUT(loadStub: model)
        
        sut.load(makeLoadPayload()) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(fromModel.payloads, [model])
    }
    
    func test_load_shouldDeliverLoaded() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _,_,_,_, interactiveScheduler, _) = makeSUT(
            fromModel: value,
            loadStub: model
        )
        let exp = expectation(description: "wait for load completion")
        
        sut.load(makeLoadPayload()) {
            
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
        
        let (sut, _,_,_, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(makeValue()) { _ in }
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    func test_save_shouldCallToModelWithValue() {
        
        let value = makeValue()
        let (sut, _, toModelSpy, _,_,_, backgroundScheduler) = makeSUT()
        
        sut.save(value) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(toModelSpy.payloads, [value])
    }
    
    func test_save_shouldCallSaveWithPayload() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _,_,_, saveSpy, _, backgroundScheduler) = makeSUT(toModel: model)
        
        sut.save(value) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(saveSpy.payloads, [model])
    }
    
    func test_save_shouldDeliverFailureOnFailure() {
        
        let (sut, _,_,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.failure(anyError())])
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
        
        let (sut, _,_,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.success(())])
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
    
    private typealias Composer = LocalAgentLoaderComposer<LoadPayload, Model, Value>
    private typealias SUT = LocalAgentLoader<LoadPayload, Value>
    private typealias FromModelSpy = CallSpy<Model, Value>
    private typealias ToModelSpy = CallSpy<Value, Model>
    private typealias LoadSpy = CallSpy<LoadPayload, Model?>
    private typealias SaveSpy = CallSpy<Model, Result<Void, Error>>
    
    private func makeSUT(
        fromModel: Value? = nil,
        toModel: Model? = nil,
        loadStub: Model? = nil,
        saveStubs: [Result<Void, Error>] = [.success(())],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fromModelSpy: FromModelSpy,
        toModelSpy: ToModelSpy,
        loadSpy: LoadSpy,
        saveSpy: SaveSpy,
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
        let loadSpy = LoadSpy(stubs: [loadStub])
        let saveSpy = SaveSpy(stubs: saveStubs)
        let sut = composer.compose(
            load: loadSpy.call,
            save: saveSpy.call
        )
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(saveSpy, file: file, line: line)
        
        return (sut, fromModelSpy, toModelSpy, loadSpy, saveSpy, interactiveScheduler, backgroundScheduler)
    }
    
    private struct LoadPayload: Equatable {
        
        let value: String
    }
    
    private func makeLoadPayload(
        _ value: String = anyMessage()
    ) -> LoadPayload {
        
        return .init(value: value)
    }
    
    private struct Model: Equatable {
        
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
