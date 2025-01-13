//
//  LocalSessionCodeLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import CvvPin
import XCTest

final class LocalSessionCodeLoaderTests: XCTestCase {
    
    typealias LoadError = LocalSessionCodeLoader.LoadError
    
    func test_init_shouldNotMessageStoreUponCreation() {
        
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    // MARK: - save
    
    func test_save_shouldCallDeleteCashedSessionCode() {
        
        let (store, sut) = makeSUT()
        let sessionCode = uniqueSessionCode()
        
        sut.save(sessionCode) { _ in }
        
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_shouldNotCallInsertionOnDeletionError() {
        
        let (store, sut) = makeSUT()
        let sessionCode = uniqueSessionCode()
        let deletionError = anyNSError()
        
        sut.save(sessionCode) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_shouldCallInsertionWithTimestampOnSuccessfulDeletion() {
        
        let sessionCode = uniqueSessionCode()
        let timestamp = Date()
        let (store, sut) = makeSUT(currentDate: { timestamp })
        
        sut.save(sessionCode) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertNoDiff(store.messages, [
            .delete,
            .insert(sessionCode: sessionCode, timestamp: timestamp)
        ])
    }
    
    func test_save_shouldDeliverErrorOnDeletionError() {
        
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_shouldDeliverErrorOnInsertionError() {
        
        let (store, sut) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: insertionError) {
            
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_shouldSucceedOnSuccessfulInsertion() {
        
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: nil) {
            
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_shouldNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        
        let store: SessionCodeStoreSpy
        var sut: LocalSessionCodeLoader?
        (store, sut) = makeSUT()
        let sessionCode = uniqueSessionCode()
        
        var receivedResults = [LocalSessionCodeLoader.SaveResult]()
        sut?.save(sessionCode) {
            receivedResults.append($0)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_shouldNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        
        let store: SessionCodeStoreSpy
        var sut: LocalSessionCodeLoader?
        (store, sut) = makeSUT()
        let sessionCode = uniqueSessionCode()
        
        var receivedResults = [LocalSessionCodeLoader.SaveResult]()
        sut?.save(sessionCode) {
            receivedResults.append($0)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - load
    
    func test_init_shouldNotCallLoadUponCreation() {
        
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_shouldCallStoreRetrieve() {
        
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_shouldDeliverLoadErrorOnStoreRetrieveError() {
        
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toLoad: .failure(LoadError.loadFailure)) {
            
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_shouldDeliverSessionCodeOnNonExpiredSessionCode() {
        
        let (store, sut) = makeSUT(isExpired: { _ in false })
        let sessionCode = uniqueSessionCode()
        
        expect(sut, toLoad: .success(sessionCode)) {
            
            store.completeRetrieval(with: sessionCode.local, timestamp: .init())
        }
    }
    
    func test_load_shouldDeliverErrorOnExpiredSessionCode() {
        
        let (store, sut) = makeSUT(isExpired: { _ in true })
        let sessionCode = uniqueSessionCode()
        
        expect(sut, toLoad: .failure(LoadError.expiredCache)) {
            
            store.completeRetrieval(with: sessionCode.local, timestamp: .init())
        }
    }
    
    func test_load_shouldNotRequestDeleteCacheOnRetrievalError() {
        
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    func test_load_shouldNotRequestDeleteCacheOnRetrievalSuccess() {
        
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueSessionCode().local, timestamp: .init())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    func test_load_shouldNotRequestDeleteCacheOnNonExpiredCache() {
        
        let (store, sut) = makeSUT(isExpired: { _ in false })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueSessionCode().local, timestamp: .init())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    func test_load_shouldNotRequestDeleteCacheOnExpiredCache() {
        
        let (store, sut) = makeSUT(isExpired: { _ in true })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueSessionCode().local, timestamp: .init())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    func test_load_shouldNotDeliverRetreivalErrorAfterSUTInstanceHasBeenDeallocated() {
        
        let store: SessionCodeStoreSpy
        var sut: LocalSessionCodeLoader?
        (store, sut) = makeSUT()
        
        var receivedResults = [LoadResult]()
        sut?.load {
            receivedResults.append($0)
        }
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - validate cache
    
    func test_validateCache_shouldRequestDeleteCacheOnRetrievalError() {
        
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertNoDiff(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_shouldRequestDeleteCacheOnExpiredCache() {
        
        let (store, sut) = makeSUT(isExpired: { _ in true })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueSessionCode().local, timestamp: .init())
        
        XCTAssertNoDiff(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_shouldNotRequestDeleteCacheOnNonExpiredCache() {
        
        let (store, sut) = makeSUT(isExpired: { _ in false })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueSessionCode().local, timestamp: .init())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    func test_validateCache_shouldNotRequestInvalidCacheDeletionAfterSUTInstanceHasBeenDeallocated() {
        
        let store: SessionCodeStoreSpy
        var sut: LocalSessionCodeLoader?
        (store, sut) = makeSUT()
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertNoDiff(store.messages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        isExpired: @escaping (Date) -> Bool = { _ in true },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        store: SessionCodeStoreSpy,
        sut: LocalSessionCodeLoader
    ) {
        let store = SessionCodeStoreSpy()
        let sut = LocalSessionCodeLoader(
            store: store,
            currentDate: currentDate,
            isExpired: isExpired
        )
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    // MARK: - assertion helpers
    
    private func expect(
        _ sut: LocalSessionCodeLoader,
        toCompleteWith expectedError: NSError?,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sessionCode = uniqueSessionCode()
        let exp = expectation(description: "wait for save completion")
        var receivedError: Error?
        
        sut.save(sessionCode) {
            
            if case let .failure(error) = $0 {
                receivedError = error
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNoDiff(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    // MARK: - SessionCodeStoreSpy
    
    private final class SessionCodeStoreSpy: SessionCodeStore {
        
        private(set) var deletionCompletions = [DeletionCompletion]()
        private(set) var insertionCompletions = [InsertionCompletion]()
        private(set) var retrievalCompletions = [RetrievalCompletion]()
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            
            case delete
            case insert(sessionCode: GetProcessingSessionCodeDomain.SessionCode, timestamp: Date)
            case retrieve
        }
        
        func deleteCachedSessionCode(
            completion: @escaping DeletionCompletion
        ) {
            deletionCompletions.append(completion)
            messages.append(.delete)
        }
        
        func insert(
            _ localSessionCode: LocalSessionCode,
            timestamp: Date,
            completion: @escaping InsertionCompletion
        ) {
            let message: Message = .insert(
                sessionCode: localSessionCode.toModel,
                timestamp: timestamp
            )
            messages.append(message)
            insertionCompletions.append(completion)
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            
            messages.append(.retrieve)
            retrievalCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            
            deletionCompletions[index](.failure(error))
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            
            deletionCompletions[index](.success(()))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            
            insertionCompletions[index](.failure(error))
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            
            insertionCompletions[index](.success(()))
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrieval(with localSessionCode: LocalSessionCode, timestamp: Date, at index: Int = 0) {
            
            retrievalCompletions[index](.success((localSessionCode, timestamp)))
        }
    }
}

// MARK: - Test Helpers

private extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        
        self + seconds
    }
}
