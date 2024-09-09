//
//  LocalAgentLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers

final class LocalAgentLoaderComposer<LoadPayload, LoadResponse, SavePayload, SaveResponse> {
    
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        interactiveScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.interactiveScheduler = interactiveScheduler
        self.backgroundScheduler = backgroundScheduler
    }
}

extension LocalAgentLoaderComposer {
    
    func compose(
        load: @escaping (LoadPayload) -> LoadResponse,
        save: @escaping (SavePayload) -> SaveResponse
    ) -> Loader {
        
        return .init(
            load: { payload, completion in
                
                self.interactiveScheduler.schedule { completion(load(payload)) }
            },
            save: { payload, completion
                
                in self.backgroundScheduler.schedule { completion(save(payload)) }
            }
        )
    }
    
    typealias Loader = LocalAgentLoader<LoadPayload, LoadResponse, SavePayload, SaveResponse>
}

struct LocalAgentLoader<LoadPayload, LoadResponse, SavePayload, SaveResponse> {
    
    let load: (LoadPayload, @escaping (LoadResponse) -> Void) -> Void
    let save: (SavePayload, @escaping (SaveResponse) -> Void) -> Void
}

import CombineSchedulers
import XCTest

final class LocalAgentLoaderComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loadSpy, saveSpy, _,_) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(saveSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldPerformOnInteractive() {
        
        let (sut, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(makeLoadPayload()) { _ in }
        XCTAssertNoDiff(loadSpy.callCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_load_shouldCallLoadWithPayload() {
        
        let loadPayload = makeLoadPayload()
        let (sut, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(loadPayload) { _ in }
        interactiveScheduler.advance()
        
        XCTAssertNoDiff(loadSpy.payloads, [loadPayload])
    }
    
    func test_load_shouldDeliverLoaded() {
        
        let loadResponse = makeLoadResponse()
        let (sut, _,_, interactiveScheduler, _) = makeSUT(loadStubs: [loadResponse])
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
    
    func test_save_shouldPerformOnBackground() {
        
        let (sut, _, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(makeSavePayload()) { _ in }
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    func test_save_shouldCallLoadWithPayload() {
        
        let savePayload = makeSavePayload()
        let (sut, _, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(savePayload) { _ in }
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(saveSpy.payloads, [savePayload])
    }
    
    func test_save_shouldDeliverLoaded() {
        
        let saveResponse = makeSaveResponse()
        let (sut, _,_, _, backgroundScheduler) = makeSUT(saveStubs: [saveResponse])
        let exp = expectation(description: "wait for save completion")
        var receivedResponse = [SaveResponse]()
        
        sut.save(makeSavePayload()) {
            
            receivedResponse.append($0)
            exp.fulfill()
        }
        
        backgroundScheduler.advance()
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResponse, [saveResponse])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = LocalAgentLoaderComposer<LoadPayload, LoadResponse, SavePayload, SaveResponse>
    private typealias SUT = LocalAgentLoader<LoadPayload, LoadResponse, SavePayload, SaveResponse>
    private typealias LoadSpy = CallSpy<LoadPayload, LoadResponse>
    private typealias SaveSpy = CallSpy<SavePayload, SaveResponse>
    
    private func makeSUT(
        loadStubs: [LoadResponse]? = nil,
        saveStubs: [SaveResponse]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        saveSpy: SaveSpy,
        interactiveScheduler: TestSchedulerOf<DispatchQueue>,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let interactiveScheduler = DispatchQueue.test
        let backgroundScheduler = DispatchQueue.test
        let composer = Composer(
            interactiveScheduler: interactiveScheduler.eraseToAnyScheduler(),
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        let loadSpy = LoadSpy(stubs: loadStubs ?? [makeLoadResponse()])
        let saveSpy = SaveSpy(stubs: saveStubs ?? [makeSaveResponse()])
        let sut = composer.compose(load: loadSpy.call, save: saveSpy.call)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(saveSpy, file: file, line: line)
        
        return (sut, loadSpy, saveSpy, interactiveScheduler, backgroundScheduler)
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
    
    private struct SavePayload: Equatable {
        
        let value: String
    }
    
    private func makeSavePayload(
        _ value: String = anyMessage()
    ) -> SavePayload {
        
        return .init(value: value)
    }
    
    private struct SaveResponse: Equatable {
        
        let value: String
    }
    
    private func makeSaveResponse(
        _ value: String = anyMessage()
    ) -> SaveResponse {
        
        return .init(value: value)
    }
}
