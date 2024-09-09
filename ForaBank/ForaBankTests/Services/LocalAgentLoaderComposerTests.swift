//
//  LocalAgentLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers

final class LocalAgentLoaderComposer<LoadPayload, SavePayload> {
    
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
        load: @escaping (LoadPayload) -> Void,
        save: @escaping (SavePayload) -> Void
    ) -> Loader {
        
        return .init(
            load: { payload in self.interactiveScheduler.schedule { load(payload) }},
            save: { payload in self.backgroundScheduler.schedule { save(payload) }}
        )
    }
    
    typealias Loader = LocalAgentLoader<LoadPayload, SavePayload>
}

struct LocalAgentLoader<LoadPayload, SavePayload> {
    
    let load: (LoadPayload) -> Void
    let save: (SavePayload) -> Void
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
        
        sut.load(makeLoadPayload())
        XCTAssertNoDiff(loadSpy.callCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_load_shouldCallLoadWithPayload() {
        
        let loadPayload = makeLoadPayload()
        let (sut, loadSpy, _, interactiveScheduler, _) = makeSUT()
        
        sut.load(loadPayload)
        interactiveScheduler.advance()

        XCTAssertNoDiff(loadSpy.payloads, [loadPayload])
    }
    
    // MARK: - save
    
    func test_save_shouldPerformOnBackground() {
        
        let (sut, _, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(makeSavePayload())
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    func test_save_shouldCallLoadWithPayload() {
        
        let savePayload = makeSavePayload()
        let (sut, _, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save(savePayload)
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(saveSpy.payloads, [savePayload])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = LocalAgentLoaderComposer<LoadPayload, SavePayload>
    private typealias SUT = LocalAgentLoader<LoadPayload, SavePayload>
    private typealias LoadSpy = CallSpy<LoadPayload, Void>
    private typealias SaveSpy = CallSpy<SavePayload, Void>
    
    private func makeSUT(
        loadStubs: [Void] = [()],
        saveStubs: [Void] = [()],
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
        let loadSpy = LoadSpy(stubs: loadStubs)
        let saveSpy = SaveSpy(stubs: saveStubs)
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
    
    private struct SavePayload: Equatable {
        
        let value: String
    }
    
    private func makeSavePayload(
        _ value: String = anyMessage()
    ) -> SavePayload {
        
        return .init(value: value)
    }
}
