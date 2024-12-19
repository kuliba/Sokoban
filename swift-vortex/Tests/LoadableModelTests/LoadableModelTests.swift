//
//  LoadableModelTests.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

import LoadableModel
import XCTest

final class LoadableModelTests: XCTestCase {
    
    // MARK: init
    
    func test_init_shouldNotSetInitialState() {
        
        let initialState: Model.State = .local("abc")
        let (_, spy, _, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_init_shouldNotCallLocalLoad() {
        
        let (_, _, localLoader, _) = makeSUT()
        
        XCTAssertNoDiff(localLoader.loadCallCount, 0)
    }
    
    func test_init_shouldNotCallRemoteLoad() {
        
        let (_, _, _, remoteLoader) = makeSUT()
        
        XCTAssertNoDiff(remoteLoader.loadCallCount, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldSetStateToRemoteOnRemoteCompletion() {
        
        let (sut, spy, _, remoteLoader) = makeSUT()
        
        sut.load()
        remoteLoader.complete(with: .success("abc"))
        
        XCTAssertNoDiff(spy.values, [
            .remote("abc"),
        ])
    }
    
    func test_load_shouldSetStateToLocalOnLocalCompletion() {
        
        let (sut, spy, localLoader, _) = makeSUT()
        
        sut.load()
        localLoader.complete(with: .success("123"))
        
        XCTAssertNoDiff(spy.values, [
            .local("123"),
        ])
    }
    
    func test_load_shouldSetStateToLocalAfterRemote() {
        
        let (sut, spy, localLoader, remoteLoader) = makeSUT()
        
        sut.load()
        localLoader.complete(with: .success("123"))
        remoteLoader.complete(with: .success("abc"))
        
        XCTAssertNoDiff(spy.values, [
            .local("123"),
            .remote("abc"),
        ])
    }
    
    func test_load_shouldSetStateToRemoteAfterLocal() {
        
        let (sut, spy, localLoader, remoteLoader) = makeSUT()
        
        sut.load()
        remoteLoader.complete(with: .success("abc"))
        localLoader.complete(with: .success("123"))
        
        XCTAssertNoDiff(spy.values, [
            .remote("abc"),
            .local("123"),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Model = LoadableModel<String, LoadError>
    
    private func makeSUT(
        initialState: Model.State = .placeholder,
        reducer: Model.Reducer = .basic,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Model,
        spy: ValueSpy<Model.State>,
        localLoader: LoaderSpy,
        remoteLoader: LoaderSpy
    ) {
        
        let localLoader = LoaderSpy()
        let remoteLoader = LoaderSpy()
        let spy = ValueSpy<Model.State>()
        
        let sut = Model(
            initialState: initialState,
            localLoad: localLoader.load,
            remoteLoad: remoteLoader.load,
            reduce: reducer.reduce,
            observe: spy.observe
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(localLoader, file: file, line: line)
        trackForMemoryLeaks(remoteLoader, file: file, line: line)
        
        return (sut, spy, localLoader, remoteLoader)
    }
    
    private final class LoaderSpy {
        
        private var completions = [Model.Completion]()
        var loadCallCount: Int { completions.count }
        
        func load(completion: @escaping Model.Completion) {
            
            completions.append(completion)
        }
        
        func complete(
            with result: Model.LoadResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class ValueSpy<Value: Equatable> {
        
        private(set) var values = [Value]()
        
        func observe(_ value: Value) {
            
            values.append(value)
        }
    }
    
    enum LoadError: Error, Equatable {
        
        case localError
        case remoteError
    }
}
