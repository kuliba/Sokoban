//
//  PaymentsTransfersViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import UIPrimitives
import AnywayPaymentDomain

struct PaymentsTransfersViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
    let makeIconView: MakeIconView
    let makeUpdateInfoView: MakeUpdateInfoView
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makePaymentCompleteView: MakePaymentCompleteView
}

extension PaymentsTransfersViewFactory {
    
    typealias MakeIconView = IconDomain.MakeIconView
    typealias MakeAnywayPaymentFactory = (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory<IconDomain.IconView>
    
    typealias TransactionResult = UtilityServicePaymentFlowState.FullScreenCover.TransactionResult
    typealias MakePaymentCompleteView = (TransactionResult, @escaping () -> Void) -> PaymentCompleteView
}
