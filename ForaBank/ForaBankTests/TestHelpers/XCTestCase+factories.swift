//
//  XCTestCase+factories.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

extension XCTestCase {
    
    func makeLatestService(
        additionalItems: [RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem]? = nil,
        amount: Decimal? = nil,
        currency: String? = nil,
        date: Int = .random(in: 1...1_000),
        detail: RemoteServices.ResponseMapper.LatestPayment.PaymentOperationDetailType? = nil,
        inn: String? = nil,
        lpName: String? = nil,
        md5Hash: String? = nil,
        name: String? = nil,
        paymentDate: Date = .now,
        paymentFlow: RemoteServices.ResponseMapper.LatestPayment.PaymentFlow? = nil,
        puref: String = anyMessage(),
        type: RemoteServices.ResponseMapper.LatestPayment.LatestType = .internet
    ) -> Latest.Service {
        
        return .init(
            additionalItems: additionalItems,
            amount: amount,
            currency: currency,
            date: date,
            detail: detail,
            inn: inn,
            lpName: lpName,
            md5Hash: md5Hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow,
            puref: puref,
            type: type
        )
    }
    
    func makePaymentServiceOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        icon: String? = anyMessage(),
        title: String = anyMessage(),
        type: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
    }
}
