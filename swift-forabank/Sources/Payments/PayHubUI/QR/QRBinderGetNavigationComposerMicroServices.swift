//
//  QRBinderGetNavigationComposerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Foundation

public struct QRBinderGetNavigationComposerMicroServices<Payments, QRCode, QRFailure> {
    
    public let makeQRFailure: MakeQRFailure
    public let makePayments: MakePayments
    
    public init(
        makeQRFailure: @escaping MakeQRFailure,
        makePayments: @escaping MakePayments
    ) {
        self.makeQRFailure = makeQRFailure
        self.makePayments = makePayments
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakeQRFailure = (QRCode) -> QRFailure
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload: Equatable {
        
        case c2bSubscribe(URL)
        case c2b(URL)
    }
}
