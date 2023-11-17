//
//  LocalSessionCodeLoaderIntegrationTests.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import CvvPin
import XCTest

final class LocalSessionCodeLoaderIntegrationTests: XCTestCase {
    
    typealias LoadError = LocalSessionCodeLoader.LoadError
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStore()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_shouldDeliverErrorOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toLoad: .failure(LoadError.loadFailure)) {}
    }
    
    func test_load_shouldDeliverSessionCodeSavedByAnotherInstance() {
        
        let sutPerformingSave = makeSUT()
        let sutPerformingLoad = makeSUT()
        let sessionCode = uniqueSessionCode()
        
        save(sessionCode, on: sutPerformingSave)
        expect(sutPerformingLoad, toLoad: .success(sessionCode)) {}
    }
    
    func test_shouldOverrideCacheSavedBySeparateInstance() {
        
        let sutPerformingFirstSave = makeSUT()
        let sutPerformingLastSave = makeSUT()
        let sutPerformingLoad = makeSUT()
        let firstSessionCode = uniqueSessionCode()
        let lastSessionCode = uniqueSessionCode()
        
        save(firstSessionCode, on: sutPerformingFirstSave)
        save(lastSessionCode, on: sutPerformingLastSave)
        
        expect(sutPerformingLoad, toLoad: .success(lastSessionCode), on: {})
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> LocalSessionCodeLoader {
        let store = CodableSessionCodeStore(storeURL: testStoreURL())
        let sut = LocalSessionCodeLoader(
            store: store,
            currentDate: Date.init,
            isExpired: { Date().distance(to: $0) > 300 }
        )
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testStoreURL() -> URL {
        
        cachesDirectory()
            .appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStore() {
        
        removeStoreArtefacts()
    }
    
    private func undoStoreSideEffects() {
        
        removeStoreArtefacts()
    }
    
    private func removeStoreArtefacts() {
        
        try? FileManager.default.removeItem(at: testStoreURL())
    }
    
    private func save(
        _ sessionCode: GetProcessingSessionCodeDomain.SessionCode,
        on sut: LocalSessionCodeLoader,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let saveExpectation = expectation(description: "wait for save")
        
        sut.save(sessionCode) { saveResult in
            
            if case let .failure(error) = saveResult {
                
                XCTFail("Expected success, got \(error) instead.", file: file, line: line)
            }
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
    }
}
