//
//  LocalImageLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.07.2024.
//

@testable import ForaBank
import SwiftUI
import XCTest

@available(iOS 16.0.0, *)
final class LocalImageLoaderComposerTests: XCTestCase {
    
    func test_load_shouldDeliverFailureOnLoadFromPersistenceFailure() {
        
        let loadError = anyError()
        let (sut, spy) = makeSUT(log: { _,_,_,_ in })
        
        let exp = expectation(description: "Load from persistence")
        var loadedImage: Image?
        
        sut.load("testKey") { result in
            
            loadedImage = try? result.get().1
            exp.fulfill()
        }
        spy.complete(with: .failure(loadError))
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNil(loadedImage)
    }
    
    func test_load_shouldDeliverStoredImage() {
        
        let storedImage = Image(systemName: "photo")
        let (sut, spy) = makeSUT(log: { _,_,_,_ in })
        
        let exp = expectation(description: "Load from persistence")
        var loadedImage: Image?
        
        sut.load("testKey") { result in
            
            loadedImage = try? result.get().1
            exp.fulfill()
        }
        spy.complete(with: .success(storedImage))
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(loadedImage, storedImage, "Should load image from persistent storage.")
    }
    
    func test_load_shouldNotCallLoadFromPersistenceOnceLoadedIntoMemory() {
        
        let storedImage = Image(systemName: "photo")
        let (sut, spy) = makeSUT(log: { _,_,_,_ in })
        
        let firstLoadExp = expectation(description: "First load from persistence")
        sut.load("testKey") { _ in firstLoadExp.fulfill() }
        spy.complete(with: .success(storedImage))
        
        wait(for: [firstLoadExp], timeout: 1)
        
        let secondLoadExp = expectation(description: "Second load from memory")
        var loadedImage: Image?
        
        sut.load("testKey") { result in
            
            loadedImage = try? result.get().1
            secondLoadExp.fulfill()
        }
        
        wait(for: [secondLoadExp], timeout: 1)
        
        XCTAssertEqual(loadedImage, storedImage, "Should load image from memory and not call load from persistence again")
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_load_shouldLogLoadingAndCachingEvents() {
        
        var logs = [String]()
        let image = Image(systemName: "photo")
        
        let (sut, spy) = makeSUT { _, message, _,_ in logs.append(message) }
        
        let exp = expectation(description: "Log loading and caching")
        
        sut.load("testKey") { _ in exp.fulfill() }
        spy.complete(with: .success(image))
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertTrue(logs.contains { $0.contains("Save success") }, "Should log save success")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ImageLoader
    private typealias Composer = LocalImageLoaderComposer
    private typealias LoadSpy = Spy<String, Image, Error>
    
    private func makeSUT(
        log: @escaping LocalImageLoaderComposer.Log,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let composer = Composer(load: spy.load, log: log)
        let sut = composer.compose()
        
        return (sut, spy)
    }
    
    private struct LoadError: Error, Equatable {}
}
