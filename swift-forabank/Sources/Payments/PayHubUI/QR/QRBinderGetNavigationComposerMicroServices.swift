//
//  QRBinderGetNavigationComposerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Foundation

public struct QRBinderGetNavigationComposerMicroServices<Payments> {
    
    public let makePayments: MakePayments
    
    public init(
        makePayments: @escaping MakePayments
    ) {
        self.makePayments = makePayments
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload: Equatable {
        
        case c2bSubscribe(URL)
    }
}
