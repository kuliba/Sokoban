//
//  PaymentsTransfersViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import UIPrimitives

struct PaymentsTransfersViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
    let makeIconView: MakeIconView
}

extension PaymentsTransfersViewFactory {
    
    typealias MakeIconView = IconDomain.MakeIconView
}
