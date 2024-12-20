//
//  ExpiringInMemoryStoreTests.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

import EphemeralStores
import XCTest

final class ExpiringInMemoryStoreTests: XCTestCase {
    
    func test_retrieve_shouldDeliverFailureOnEmpty() {
        
        let sut = makeSUT()
        let exp = expectation(description: "wait for retrieval completion")
        
        sut.retrieve {
            
            switch $0 {
            case .failure:
                break
                
            case .success:
                XCTFail("Expected failure, got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_shouldHaveNoSideEffectOnEmpty() {
        
        let sut = makeSUT()
        let exp = expectation(description: "wait for retrieval completion")
        
        sut.retrieve { _ in
            
            sut.retrieve {
                
                switch $0 {
                case .failure:
                    break
                    
                default:
                    XCTFail("Expected failure, got \($0) instead.")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_insert_shouldInsertItem() {
        
        let (item, expiration) = (makeItem(), Date())
        let sut = makeSUT()
        let insertExp = expectation(description: "wait for insert completion")
        let retrieveExp = expectation(description: "wait for retrieval completion")
        
        sut.insert(item, validUntil: expiration) {
            
            switch $0 {
            case .success(()):
                break
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            
            insertExp.fulfill()
        }
        
        wait(for: [insertExp], timeout: 1)
        
        sut.retrieve {
            
            switch $0 {
            case let .success(retrieved):
                XCTAssertNoDiff(retrieved.0, item)
                XCTAssertNoDiff(retrieved.1, expiration)
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            
            retrieveExp.fulfill()
        }
        
        wait(for: [retrieveExp], timeout: 1)
    }
    
    func test_insert_shouldOverridePreviouslyInsertedValue() {
        
        let (item, expiration) = (makeItem(), Date())
        let sut = makeSUT()
        let firstInsertExp = expectation(description: "wait for first insert completion")
        let secondInsertExp = expectation(description: "wait for second insert completion")
        let retrieveExp = expectation(description: "wait for retrieval completion")
        
        sut.insert(makeItem(), validUntil: .init()) { _ in
            
            firstInsertExp.fulfill()
        }
        
        wait(for: [firstInsertExp], timeout: 1)
        
        sut.insert(item, validUntil: expiration) {
            
            switch $0 {
            case .success(()):
                break
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            
            secondInsertExp.fulfill()
        }
        
        wait(for: [secondInsertExp], timeout: 1)
        
        sut.retrieve {
            
            switch $0 {
            case let .success(retrieved):
                XCTAssertNoDiff(retrieved.0, item)
                XCTAssertNoDiff(retrieved.1, expiration)
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            
            retrieveExp.fulfill()
        }
        
        wait(for: [retrieveExp], timeout: 1)
    }
    
    func test_delete_shouldHaveNoSideEffectsOnEmpty() {
        
        let sut = makeSUT()
        let deleteExp = expectation(description: "wait for delete completion")
        let retrieveExp = expectation(description: "wait for retrieve completion")
        
        sut.deleteCache { _ in
            
            deleteExp.fulfill()
        }
        
        wait(for: [deleteExp], timeout: 1)
        
        sut.retrieve {
            
            switch $0 {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
            
            retrieveExp.fulfill()
        }
        
        wait(for: [retrieveExp], timeout: 1)
    }
    
    func test_delete_shouldDeleteValue() {
        
        let sut = makeSUT()
        let insertExp = expectation(description: "wait for insert completion")
        let deleteExp = expectation(description: "wait for delete completion")
        let retrieveExp = expectation(description: "wait for retrieve completion")
        
        sut.insert(makeItem(), validUntil: .init()) { _ in
            
            insertExp.fulfill()
        }
        
        wait(for: [insertExp], timeout: 1)
        
        sut.deleteCache { _ in
            
            deleteExp.fulfill()
        }
        
        wait(for: [deleteExp], timeout: 1)
        
        sut.retrieve {
            
            switch $0 {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
            
            retrieveExp.fulfill()
        }
        
        wait(for: [retrieveExp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ExpiringInMemoryStore<Item>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private struct Item: Equatable {
        
        let value: String
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
}
