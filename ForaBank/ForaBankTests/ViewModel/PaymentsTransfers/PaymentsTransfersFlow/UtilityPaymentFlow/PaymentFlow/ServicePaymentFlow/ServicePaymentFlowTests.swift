//
//  ServicePaymentFlowTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain
@testable import ForaBank
import XCTest

class ServicePaymentFlowTests: XCTestCase {
    
    func makeState(
        modal: ServicePaymentFlowState.Modal?
    ) -> ServicePaymentFlowState {
        
        return .init(modal: modal)
    }
    
    func makeFraud(
        title: String = anyMessage(),
        subtitle: String? = anyMessage(),
        formattedAmount: String = anyMessage(),
        delay: Double = .random(in: 1...100)
    ) -> FraudNoticePayload {
        
        return .init(title: title, subtitle: subtitle, formattedAmount: formattedAmount, delay: delay)
    }
    
    func makePaymentUpdate() -> AnywayPaymentUpdate {
        
        return .init(
            details: .init(
                amounts: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil),
                control: .init(isFinalStep: false, isFraudSuspected: false, isMultiSum: false, needOTP: false, needSum: false),
                info: .init(documentStatus: nil, infoMessage: nil, payeeName: nil, paymentOperationDetailID: nil, printFormType: nil)
            ),
            fields: [],
            parameters: []
        )
    }
    
    func makeReport(
        status: DocumentStatus = .completed,
        info: _OperationInfo = .detailID(.random(in: 1...100))
    ) -> AnywayTransactionReport {
        
        return .init(status: status, info: info)
    }
    
    func notify(
        context: AnywayPaymentContext? = nil,
        _ status: AnywayTransactionStatus?
    ) -> ServicePaymentFlowEvent {
        
        return .notify(.init(
            context: context ?? makeAnywayPaymentContext(),
            status: status
        ))
    }
    
    func makeAnywayPaymentContext(
    ) -> AnywayPaymentContext {
        
        return .init(
            initial: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
            payment: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
            staged: .init(),
            outline: .init(
                amount: 0,
                product: nil,
                fields: .init(),
                payload: .init(
                    puref: anyMessage(),
                    title: anyMessage(),
                    subtitle: anyMessage(),
                    icon: anyMessage()
                )
            ),
            shouldRestart: false
        )
    }
}
