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
        alert: ServicePaymentFlowState.Alert
    ) -> ServicePaymentFlowState {
        
        return .alert(alert)
    }
    
    func makeState(
        fraud: FraudNoticePayload
    ) -> ServicePaymentFlowState {
        
        return .fraud(fraud)
    }
    
    func makeState(
        formattedAmount: String = anyMessage(),
        merchantIcon: String? = anyMessage(),
        result: ServicePaymentFlowState.Completed.TransactionResult
    ) -> ServicePaymentFlowState {
        
        return .fullScreenCover(.init(
            formattedAmount: formattedAmount,
            merchantIcon: merchantIcon,
            result: result
        ))
    }
    
    func makeFraudPayload(
        title: String = anyMessage(),
        subtitle: String? = anyMessage(),
        formattedAmount: String = anyMessage(),
        delay: Double = .random(in: 1...100)
    ) -> FraudNoticePayload {
        
        return .init(title: title, subtitle: subtitle, formattedAmount: formattedAmount, delay: delay)
    }
    
    func makeFraud(
        hasExpired: Bool
    ) -> ServicePaymentFlowEvent.Completed.Fraud {
        
        return .init(hasExpired: hasExpired)
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
        icon: String? = anyMessage()
    ) -> AnywayPaymentContext {
        
        return .init(
            initial: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
            payment: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
            staged: .init(),
            outline: .init(
                amount: nil,
                product: makeOutlineProduct(),
                fields: .init(),
                payload: .init(
                    puref: anyMessage(),
                    title: anyMessage(),
                    subtitle: anyMessage(),
                    icon: icon
                )
            ),
            shouldRestart: false
        )
    }
    
    private func makeOutlineProduct(
        currency: String = anyMessage(),
        productID: Int = .random(in: 1...100),
        productType: AnywayPaymentOutline.Product.ProductType = .card
    ) -> AnywayPaymentOutline.Product {
        
        return .init(currency: currency, productID: productID, productType: productType)
    }
}
