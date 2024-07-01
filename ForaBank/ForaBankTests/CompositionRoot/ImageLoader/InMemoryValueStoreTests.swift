//
//  InMemoryValueStoreTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.07.2024.
//

@testable import ForaBank
import XCTest

final class InMemoryValueStoreTests: XCTestCase {
    
    func test_shouldRetrieveSavedValue() {
        
        let sut = makeSUT()
        let exp = expectation(description: "wait for retrieve")
        
        sut.save(
            payload: (key: 1, value: "testValue")
        ) { _ in
            
            sut.retrieve(key: 1) { result in
                
                XCTAssertNoDiff(try? result.get(), "testValue")
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldFailToRetrieveMissingValue() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Fail to retrieve missing value")
        
        sut.retrieve(key: 1) { result in
            
            switch result {
                
            case let .failure(error):
                XCTAssertNotNil(error as? SUT.RetrievalFailure, "The operation couldn’t be completed. (InMemoryValueStore<String, String>.RetrievalFailure error 1.)")
                
            default:
                XCTFail("Expected failure but got success")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldSaveAndRetrieveMultipleValues() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Save and retrieve multiple values")
        
        let payloads = [(1, "value1"), (2, "value2"), (3, "value3")]
        
        sut.save(payloads: payloads) { _ in
            
            sut.retrieve(keys: [1, 2, 3]) { results in
                
                XCTAssertNoDiff(try? results[0].get(), "value1")
                XCTAssertNoDiff(try? results[1].get(), "value2")
                XCTAssertNoDiff(try? results[2].get(), "value3")
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldHandleConcurrentAccess() {
        
        let sut = makeSUT()
        let exp1 = expectation(description: "Concurrent save 1")
        let exp2 = expectation(description: "Concurrent save 2")
        
        DispatchQueue.global().async {
            
            sut.save(payload: (key: 1, value: "value1")) { _ in
                
                exp1.fulfill()
            }
        }
        
        DispatchQueue.global().async {
            sut.save(payload: (key: 2, value: "value2")) { _ in
                
                exp2.fulfill()
            }
        }
        
        wait(for: [exp1, exp2], timeout: 1.0)
        
        let exp3 = expectation(description: "Retrieve concurrently saved values")
        
        sut.retrieve(keys: [1, 2]) { results in
            
            XCTAssertNoDiff(try? results[0].get(), "value1")
            XCTAssertNoDiff(try? results[1].get(), "value2")
            exp3.fulfill()
        }
        
        wait(for: [exp3], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = InMemoryValueStore<Key, Value>
    private typealias Key = Int
    private typealias Value = String
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
