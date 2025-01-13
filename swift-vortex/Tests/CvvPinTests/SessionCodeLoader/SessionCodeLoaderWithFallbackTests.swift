//
//  SessionCodeLoaderWithFallbackTests.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import CvvPin
import XCTest

final class SessionCodeLoaderWithFallbackTests: XCTestCase {
    
    func test_shouldLoadPrimaryResultOnSuccessfulPrimaryLoad() {
        
        let sessionCode = uniqueSessionCode()
        let (sut, primary, _) = makeSUT()
        
        expect(sut, toLoad: .success(sessionCode)) {
            primary.complete(with: .success(sessionCode))
        }
    }
    
    func test_shouldLoadFallbackResultOnFailedPrimaryLoad() {
        
        let sessionCode = uniqueSessionCode()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut, toLoad: .success(sessionCode)) {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .success(sessionCode))
        }
    }
    
    func test_shouldDeliverFallbackErrorOnPrimaryAndFallbackError() {
        
        let fallbackError = anyNSError(domain: "fallback")
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut, toLoad: .failure(fallbackError)) {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .failure(fallbackError))
        }
    }
    
    func test_shouldNotDeliverPrimaryResultAfterInstanceHasBeenDeallocated() {
        
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        var sut: SessionCodeLoader? = primary.fallback(to: fallback)
        
        var receivedResults = [LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        primary.complete(with: .success(uniqueSessionCode()))
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_shouldNotDeliverFallbackResultAfterInstanceHasBeenDeallocated() {
        
        let (_, primary, fallback) = makeSUT()
        var sut: SessionCodeLoader? = primary.fallback(to: fallback)
        
        var receivedResults = [LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        primary.complete(with: .failure(anyNSError()))
        sut = nil
        fallback.complete(with: .success(uniqueSessionCode()))
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SessionCodeLoader,
        primary: LoaderSpy,
        fallback: LoaderSpy
    ) {
        
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = primaryLoader.fallback(to: fallbackLoader)
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
    
    // MARK: - LoaderSpy
    
    private final class LoaderSpy: SessionCodeLoader {
        
        private var completions = [LoadCompletion]()
        
        func load(completion: @escaping LoadCompletion) {
            
            completions.append(completion)
        }
        
        func complete(with loadResult: LoadResult, at index: Int = 0) {
            
            completions[index](loadResult)
        }
    }
}
