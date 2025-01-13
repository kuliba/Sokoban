//
//  RootViewModelFactory+batchOperatorsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 08.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_batchOperatorsTests: RootViewModelFactoryServiceCategoryTests {
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.batchOperators(categories: []) {
            
            XCTAssert($0.isEmpty)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverEmptyOnNonStandardCategoryType() {
        
        let nonStandard = makeServiceCategory(flow: .mobile)
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.batchOperators(categories: [nonStandard]) {
            
            XCTAssert($0.isEmpty)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverCategoryOnFailure() {
        
        let standard = makeServiceCategory(flow: .standard)
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.batchOperators(categories: [standard]) {
            
            XCTAssertNoDiff($0, [standard])
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverEmptyOnSuccess() {
        
        let standard = makeServiceCategory(flow: .standard)
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.batchOperators(categories: [standard]) {
            
            XCTAssert($0.isEmpty)
            exp.fulfill()
        }
        
        httpClient.complete(with: getOperatorsListByParamJSON())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    
}
