//
//  FirstQRBinderGetNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct FirstQRBinderGetNavigationComposerMicroServices<Payments, QRCode, QRFailure, Source> {
    
    public let makePayments: MakePayments
    public let makeQRFailure: MakeQRFailure
    
    public init(
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure
    ) {
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
    }
}

public extension FirstQRBinderGetNavigationComposerMicroServices {
    
    typealias MakePayments = (MakePaymentsPayload<QRCode, Source>) -> Payments
    
    typealias MakeQRFailure = (QRCode?) -> QRFailure
}
