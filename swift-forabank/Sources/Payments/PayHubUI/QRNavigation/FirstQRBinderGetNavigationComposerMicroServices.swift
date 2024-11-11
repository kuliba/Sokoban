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
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload {
        
        case c2bSubscribe(URL)
        case c2b(URL)
        case details(QRCode) // MainViewModelAction.Show.Requisites
        case source(Source)
    }
    
    typealias MakeQRFailure = (QRCode?) -> QRFailure
}

extension FirstQRBinderGetNavigationComposerMicroServices.MakePaymentsPayload: Equatable where QRCode: Equatable, Source: Equatable {}
