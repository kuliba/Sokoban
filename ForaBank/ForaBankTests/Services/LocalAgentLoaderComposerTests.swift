//
//  LocalAgentLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers

final class LocalAgentLoaderComposer<LoadPayload, LoadResponse, Model: Encodable, Value> {
    
    private let toModel: (Value) -> Model
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        toModel: @escaping (Value) -> Model,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.toModel = toModel
        self.interactiveScheduler = interactiveScheduler
        self.backgroundScheduler = backgroundScheduler
    }
}

extension LocalAgentLoaderComposer {
    
    func compose(
        load: @escaping (LoadPayload) -> LoadResponse,
        save: @escaping (Model, Serial?) throws -> Void
    ) -> Loader {
        
        return .init(
            load: { payload, completion in
                
                self.interactiveScheduler.schedule { completion(load(payload)) }
            },
            save: { payload, completion in
                
                self.backgroundScheduler.schedule {
                    
                    completion(.init(catching: {
                        
                        try save(self.toModel(payload.value), payload.serial)
                    }))
                }
            }
        )
    }
    
    typealias Serial = String
    typealias Loader = LocalAgentLoader<LoadPayload, LoadResponse, Value>
}

struct LocalAgentLoader<LoadPayload, LoadResponse, Model> {
    
    let load: (LoadPayload, @escaping (LoadResponse) -> Void) -> Void
    let save: (SavePayload, @escaping (Result<Void, Error>) -> Void) -> Void
}

extension LocalAgentLoader {
    
    typealias SavePayload = LocalAgentLoaderSavePayload<Model>
}

struct LocalAgentLoaderSavePayload<Value> {
    
    let value: Value
    let serial: Serial?
    
    typealias Serial = String
}

extension LocalAgentLoaderSavePayload: Equatable where Value: Equatable {}

import CombineSchedulers
import XCTest

final class LocalAgentLoaderComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, toModelSpy, loadSpy, saveSpy, _,_) = makeSUT()
        
        XCTAssertEqual(toModelSpy.callCount, 0)
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(saveSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldPerformOnInteractive() {
        
        let (sut, _, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(makeLoadPayload()) { _ in }
        XCTAssertNoDiff(loadSpy.callCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_load_shouldCallLoadWithPayload() {
        
        let loadPayload = makeLoadPayload()
        let (sut, _, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(loadPayload) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(loadSpy.payloads, [loadPayload])
    }
    
#warning("add fromModelSpy tests: payloads & delivered value & serial")
    
    func test_load_shouldDeliverLoaded() {
        
        let loadResponse = makeLoadResponse()
        let (sut, _,_,_, interactiveScheduler, _) = makeSUT(loadStubs: [loadResponse])
        let exp = expectation(description: "wait for load completion")
        var receivedResponse = [LoadResponse]()
        
        sut.load(makeLoadPayload()) {
            
            receivedResponse.append($0)
            exp.fulfill()
        }
        
        interactiveScheduler.advance()
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResponse, [loadResponse])
    }
    
    // MARK: - save
    
    func test_save_shouldPerformOnBackground_nilSerial() {
        
        let (sut, _,_, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(.init(value: makeValue(), serial: nil)) { _ in }
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    func test_save_shouldPerformOnBackground_nonNilSerial() {
        
        let (sut, _,_, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(.init(value: makeValue(), serial: anyMessage())) { _ in }
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    func test_save_shouldCallToModelWithValue_nilSerial() {
        
        let value = makeValue()
        let (sut, toModelSpy,_, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(.init(value: value, serial: nil)) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(toModelSpy.payloads, [value])
    }
    
    func test_save_shouldCallToModelWithValue_nonNilSerial() {
        
        let value = makeValue()
        let (sut, toModelSpy,_, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(.init(value: value, serial: anyMessage())) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(toModelSpy.payloads, [value])
    }
    
    func test_save_shouldCallLoadWithPayload_nilSerial() {
        
        let (value, model) = (makeValue(), makeModel())
        let (sut, _,_, saveSpy, _, backgroundScheduler) = makeSUT(toModel: model)
        
        sut.save(.init(value: value, serial: nil)) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(saveSpy.payloads.map(\.0), [model])
        XCTAssertNoDiff(saveSpy.payloads.map(\.1), [nil])
    }
    
    func test_save_shouldCallSaveWithPayload_nonNilSerial() {
        
        let (value, serial, model) = (makeValue(), anyMessage(), makeModel())
        let (sut, _,_, saveSpy, _, backgroundScheduler) = makeSUT(toModel: model)
        
        sut.save(.init(value: value, serial: serial)) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(saveSpy.payloads.map(\.0), [model])
        XCTAssertNoDiff(saveSpy.payloads.map(\.1), [serial])
    }
    
    func test_save_shouldDeliverFailureOnFailure_nilSerial() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.failure(anyError())])
        let exp = expectation(description: "wait for save completion")
        
        sut.save(.init(value: makeValue(), serial: nil)) {
            
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
    
    func test_save_shouldDeliverFailureOnFailure_nonNilSerial() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.failure(anyError())])
        let exp = expectation(description: "wait for save completion")
        
        sut.save(.init(value: makeValue(), serial: anyMessage())) {
            
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
    
    func test_save_shouldDeliverVoidOnSuccess_nilSerial() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.success(())])
        let exp = expectation(description: "wait for save completion")
        
        sut.save(.init(value: makeValue(), serial: nil)) {
            
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
    
    func test_save_shouldDeliverVoidOnSuccess_nonNilSerial() {
        
        let (sut, _,_,_,_, backgroundScheduler) = makeSUT(saveStubs: [.success(())])
        let exp = expectation(description: "wait for save completion")
        
        sut.save(.init(value: makeValue(), serial: anyMessage())) {
            
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
    
    private typealias Composer = LocalAgentLoaderComposer<LoadPayload, LoadResponse, Model, Value>
    private typealias SUT = LocalAgentLoader<LoadPayload, LoadResponse, Value>
    private typealias ToModelSpy = CallSpy<Value, Model>
    private typealias LoadSpy = CallSpy<LoadPayload, LoadResponse>
    private typealias SaveSpy = CallSpy<(Model, String?), Result<Void, Error>>
    
    private func makeSUT(
        toModel: Model? = nil,
        loadStubs: [LoadResponse]? = nil,
        saveStubs: [Result<Void, Error>] = [.success(())],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        toModelSpy: ToModelSpy,
        loadSpy: LoadSpy,
        saveSpy: SaveSpy,
        interactiveScheduler: TestSchedulerOf<DispatchQueue>,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let toModelSpy = ToModelSpy(stubs: [toModel ?? makeModel()])
        let interactiveScheduler = DispatchQueue.test
        let backgroundScheduler = DispatchQueue.test
        let composer = Composer(
            toModel: toModelSpy.call,
            interactiveScheduler: interactiveScheduler.eraseToAnyScheduler(),
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        let loadSpy = LoadSpy(stubs: loadStubs ?? [makeLoadResponse()])
        let saveSpy = SaveSpy(stubs: saveStubs)
        let sut = composer.compose(
            load: loadSpy.call,
            save: saveSpy.call
        )
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(saveSpy, file: file, line: line)
        
        return (sut, toModelSpy, loadSpy, saveSpy, interactiveScheduler, backgroundScheduler)
    }
    
    private struct LoadPayload: Equatable {
        
        let value: String
    }
    
    private func makeLoadPayload(
        _ value: String = anyMessage()
    ) -> LoadPayload {
        
        return .init(value: value)
    }
    
    private struct LoadResponse: Equatable {
        
        let value: String
    }
    
    private func makeLoadResponse(
        _ value: String = anyMessage()
    ) -> LoadResponse {
        
        return .init(value: value)
    }
    
    private struct Model: Equatable, Encodable {
        
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
