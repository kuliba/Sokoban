//
//  CodableServicePaymentOperatorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import XCTest

class CodableServicePaymentOperatorTests: XCTestCase {
    
    typealias Payload = UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    typealias CategoryType = ServiceCategory.CategoryType
    
    func makePayload(
        afterOperatorID id: String? = nil,
        for type: CategoryType = .internet,
        searchText: String = "",
        pageSize: Int = 3
    ) -> Payload {
        
        return .init(afterOperatorID: id, for: type, searchText: searchText, pageSize: pageSize)
    }
    
    func makeCodable(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: CategoryType = .repaymentLoansAndAccounts,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type.name, sortedOrder: sortedOrder)
    }
    
    func makeOperator(
        _ codable: CodableServicePaymentOperator
    ) -> PaymentServiceOperator {
        
        return .init(id: codable.id, inn: codable.inn, icon: codable.md5Hash, name: codable.name, type: codable.type)
    }
}
