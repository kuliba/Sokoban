//
//  ServicePaymentFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AmountComponent
import Foundation

struct ServicePaymentFlowFactory {
    
    let bottomSheetContent: BottomSheetContent
    let fullScreenCoverContent: FullScreenCoverContent
    let makeElementView: MakeElementView
    let makeFooterView: MakeFooterView
}

extension ServicePaymentFlowFactory {

    typealias BottomSheetContent = (FraudNoticePayload) -> PaymentFlowModalView

    typealias TransactionResult = ServicePaymentFlowState.TransactionResult
    typealias FullScreenCoverContent = (TransactionResult) -> PaymentCompleteView
    
    typealias IconView = IconDomain.IconView
    typealias Element = AnywayTransactionState.IdentifiedModel
    typealias MakeElementView = (Element) -> AnywayPaymentElementView<IconView>
    
    typealias MakeFooterView = (FooterViewModel) -> AnywayPaymentFooterView
}
