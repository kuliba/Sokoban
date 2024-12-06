//
//  XCTestCase+makeServiceCategory.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import ForaBank
import XCTest

extension ServiceCategory {
    
    static func stub(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: ServiceCategory.PaymentFlow = .mobile,
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .networkMarketing
    ) -> Self {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}

extension XCTestCase {
    
    func makeServiceCategory(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: ServiceCategory.PaymentFlow = .mobile,
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .networkMarketing
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}
