//
//  RootViewModelFactoryServiceCategoryTests+ext.swift
//  VortexTests
//
//  Created by Igor Malyarov on 08.01.2025.
//

@testable import Vortex
import XCTest

extension RootViewModelFactoryServiceCategoryTests {
    
    func makeModelWithOperator(
        for category: ServiceCategory
    ) -> Model {
        
        let (_, codable) = makeOperatorWithModel(type: category.type)
        let localAgent = LocalAgentMock(values: [[codable]])
        
        return .mockWithEmptyExcept(localAgent: localAgent)
    }
    
    func makeOperatorWithModel(
        type: ServiceCategory.CategoryType = "repaymentLoansAndAccounts",
        sortedOrder: Int = .random(in: 1...100)
    ) -> (UtilityPaymentProvider, CodableServicePaymentOperator) {
        
        let `operator` = makePaymentServiceOperator(type: type)
        
        return (`operator`, codable(`operator`, sortedOrder: sortedOrder))
    }
    
    func codable(
        _ `operator`: UtilityPaymentProvider,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: `operator`.id, inn: `operator`.inn, md5Hash: `operator`.icon, name: `operator`.name, type: `operator`.type, sortedOrder: sortedOrder)
    }
}
