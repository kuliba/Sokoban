//
//  RootViewModelFactory+initiateStandardPaymentFlowTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 08.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_initiateStandardPaymentFlowTests: RootViewModelFactoryServiceCategoryTests {
    
    func test_shouldCallLogger_onMissingCategory() {
        
        let (sut, _, logger) = makeSUT()
        XCTAssertEqual(logger.callCount, 0)
        
        sut.initiateStandardPaymentFlow(ofType: makeServiceCategoryType()) { _ in }
        
        XCTAssertEqual(logger.callCount, 1)
    }
    
    func test_shouldDeliverMissingCategoryOfTypeFailure_onMissingCategory() {
        
        let type = makeServiceCategoryType()
        let (sut, _,_) = makeSUT()
        
        expect(sut: sut, with: type, toDeliver: .missingCategoryOfType(type))
    }
    
    func test_shouldDeliverMakeStandardPaymentFailure_onMissingOperatorForCategory() {
        
        let category = makeServiceCategory(type: anyMessage())
        let cache = makeCache(category: category, operatorType: anyMessage())
        let model = makeModelWithCache(cache: cache)
        let (sut, _,_) = makeSUT(model: model)
        
        expect(sut: sut, with: category.type, toDeliver: .makeStandardPaymentFailure)
    }
    
    func test_shouldDeliverSuccess_onCachedOperatorForCategory() {
        
        let category = makeServiceCategory(type: .security)
        let cache = makeCache(category: category, operatorType: category.type)
        let model = makeModelWithCache(cache: cache)
        let (sut, httpClient, _) = makeSUT(model: model)
        
        expect(sut: sut, with: category.type, toDeliver: .success) {
            
            httpClient.complete(with: anyError())
        }
    }
    
    // MARK: - Helpers
    
    private func makeServiceCategoryType(
    ) -> ServiceCategory.CategoryType {
        
        return anyMessage()
    }
    
    private func equatable(
        _ result: SUT.StandardPaymentResult
    ) -> StandardPaymentResult {
        
        switch result {
        case let .failure(failure):
            switch failure {
            case .makeStandardPaymentFailure:
                return .makeStandardPaymentFailure
                
            case let .missingCategoryOfType(type):
                return .missingCategoryOfType(type)
            }
            
        case .success:
            return .success
        }
    }
    
    private enum StandardPaymentResult: Equatable {
        
        case makeStandardPaymentFailure
        case missingCategoryOfType(ServiceCategory.CategoryType)
        case success
    }
    
    private func expect(
        sut: SUT,
        with type: ServiceCategory.CategoryType? = nil,
        toDeliver expectedResult: StandardPaymentResult,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let type = type ?? makeServiceCategoryType()
        let exp = expectation(description: "wait for completion")
        
        sut.initiateStandardPaymentFlow(ofType: type) {
            
            XCTAssertNoDiff(self.equatable($0), expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
