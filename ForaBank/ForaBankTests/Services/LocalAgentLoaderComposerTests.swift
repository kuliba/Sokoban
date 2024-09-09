//
//  LocalAgentLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

import CombineSchedulers

final class LocalAgentLoaderComposer {
    
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
        load: @escaping () -> Void,
        save: @escaping () -> Void
    ) -> LocalAgentLoader {
        
        return .init(
            load: { self.interactiveScheduler.schedule(load) },
            save: { self.backgroundScheduler.schedule(save) }
        )
    }
}

struct LocalAgentLoader {
    
    let load: () -> Void
    let save: () -> Void
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
        
        sut.load()
        XCTAssertNoDiff(loadSpy.callCount, 0)
        
        interactiveScheduler.advance()
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    // MARK: - save
    
    func test_save_shouldPerformOnBackground() {
        
        let (sut, _, saveSpy, _, backgroundScheduler) = makeSUT()
        
        sut.save()
        XCTAssertNoDiff(saveSpy.callCount, 0)
        
        backgroundScheduler.advance()
        XCTAssertNoDiff(saveSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = LocalAgentLoaderComposer
    private typealias SUT = LocalAgentLoader
    private typealias LoadSpy = CallSpy<Void, Void>
    private typealias SaveSpy = CallSpy<Void, Void>
    
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
}
