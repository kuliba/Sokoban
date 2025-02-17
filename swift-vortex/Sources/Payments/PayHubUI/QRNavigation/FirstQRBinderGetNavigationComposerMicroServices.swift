//
//  FirstQRBinderGetNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import VortexTools
import Foundation
import PayHub

public struct FirstQRBinderGetNavigationComposerMicroServices<Payments, QRCode, QRFailure, Source, SearchByUIN> {
    
    public let makePayments: MakePayments
    public let makeQRFailure: MakeQRFailure
    public let makeSearchByUIN: MakeSearchByUIN
    
    public init(
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure,
        makeSearchByUIN: @escaping MakeSearchByUIN
    ) {
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
        self.makeSearchByUIN = makeSearchByUIN
    }
}

public extension FirstQRBinderGetNavigationComposerMicroServices {
    
    typealias MakePayments = (MakePaymentsPayload<QRCode, Source>) -> Payments
    typealias MakeQRFailure = (QRCode?) -> QRFailure
    typealias MakeSearchByUIN = (String) -> SearchByUIN
}
