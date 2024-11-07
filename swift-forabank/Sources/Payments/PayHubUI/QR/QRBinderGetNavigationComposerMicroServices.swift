//
//  QRBinderGetNavigationComposerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct QRBinderGetNavigationComposerMicroServices<MixedPicker, Operator, Payments, Provider, QRCode, QRMapping, QRFailure> {
    
    public let makeQRFailure: MakeQRFailure
    public let makePayments: MakePayments
    public let makeMixedPicker: MakeMixedPicker
    
    public init(
        makeQRFailure: @escaping MakeQRFailure,
        makePayments: @escaping MakePayments,
        makeMixedPicker: @escaping MakeMixedPicker
    ) {
        self.makeQRFailure = makeQRFailure
        self.makePayments = makePayments
        self.makeMixedPicker = makeMixedPicker
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakeMixedPickerPayload = (MultiElementArray<OperatorProvider<Operator, Provider>>, QRCode, QRMapping)
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload: Equatable {
        
        case c2bSubscribe(URL)
        case c2b(URL)
    }
    
    typealias MakeQRFailure = (QRCode) -> QRFailure
}
