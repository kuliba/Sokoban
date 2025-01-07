//
//  RootViewModelFactory+handleSelectedServiceCategoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_handleSelectedServiceCategoryTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverServiceCategoryFailure() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut: sut, with: makeServiceCategory(), toDeliver: .serviceCategoryFailure)
    }
    
    func test_shouldDeliverPaymentProviderPicker_onCachedOperator() {
        
        let category = makeServiceCategory(type: .security)
        let model = makeModelWithOperator(for: category)
        let (sut, httpClient, _) = makeSUT(model: model)
        
        expect(sut: sut, with: category, toDeliver: .paymentProviderPicker) {
            
            httpClient.complete(with: anyError())
        }
    }
    
    // MARK: - Helpers
    
    private func makeModelWithOperator(
        for category: ServiceCategory
    ) -> Model {
        
        let (_, codable) = makeOperatorWithModel(type: category.type)
        let localAgent = LocalAgentMock(values: [[codable]])
        
        return .mockWithEmptyExcept(localAgent: localAgent)
    }
    
    private enum EquatableDestination: Equatable {
        
        case paymentProviderPicker
        case serviceCategoryFailure
    }
    
    private func equatable(
        _ destination: StandardSelectedCategoryDestination
    ) -> EquatableDestination {
        
        switch destination {
        case .failure: return .serviceCategoryFailure
        case .success: return .paymentProviderPicker
        }
    }
    
    // from RootViewModelFactory+loadCachedOperatorsTests.swift:118
    private func makeOperatorWithModel(
        type: ServiceCategory.CategoryType = "repaymentLoansAndAccounts",
        sortedOrder: Int = .random(in: 1...100)
    ) -> (UtilityPaymentProvider, CodableServicePaymentOperator) {
        
        let `operator` = makePaymentServiceOperator(type: type)
        
        return (`operator`, codable(`operator`, sortedOrder: sortedOrder))
    }
    
    private func codable(
        _ `operator`: UtilityPaymentProvider,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: `operator`.id, inn: `operator`.inn, md5Hash: `operator`.icon, name: `operator`.name, type: `operator`.type, sortedOrder: sortedOrder)
    }
    
    private func expect(
        sut: SUT,
        with category: ServiceCategory,
        toDeliver expectedDestination: EquatableDestination,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleSelectedServiceCategory(category) {
            
            XCTAssertNoDiff(self.equatable($0), expectedDestination, "Expected \(expectedDestination), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
