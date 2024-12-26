//
//  CodableServicePaymentOperatorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import Vortex
import XCTest

class CodableServicePaymentOperatorTests: XCTestCase {
    
    typealias Payload = LoadOperatorsPayload
    typealias CategoryType = ServiceCategory.CategoryType
    
    func makePayload(
        afterOperatorID id: String? = nil,
        for type: CategoryType = .internet,
        searchText: String = "",
        pageSize: Int = 3
    ) -> Payload {
        
        return .init(categoryType: type, operatorID: id, searchText: searchText, pageSize: pageSize)
    }
    
    func makeCodable(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: CategoryType = .repaymentLoansAndAccounts,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type, sortedOrder: sortedOrder)
    }
    
    func makeOperator(
        _ codable: CodableServicePaymentOperator
    ) -> UtilityPaymentProvider {
        
        return .init(id: codable.id, icon: codable.md5Hash, inn: codable.inn, title: codable.name, type: codable.type)
    }
}
