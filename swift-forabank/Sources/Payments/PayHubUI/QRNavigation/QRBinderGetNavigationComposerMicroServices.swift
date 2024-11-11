//
//  QRBinderGetNavigationComposerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct QRBinderGetNavigationComposerMicroServices<MixedPicker, MultiplePicker, Operator, Payments, Provider, QRCode, QRMapping, QRFailure> {
    
    public let makeQRFailure: MakeQRFailure
    public let makePayments: MakePayments
    public let makeMixedPicker: MakeMixedPicker
    public let makeMultiplePicker: MakeMultiplePicker
    
    public init(
        makeQRFailure: @escaping MakeQRFailure,
        makePayments: @escaping MakePayments,
        makeMixedPicker: @escaping MakeMixedPicker,
        makeMultiplePicker: @escaping MakeMultiplePicker
    ) {
        self.makeQRFailure = makeQRFailure
        self.makePayments = makePayments
        self.makeMixedPicker = makeMixedPicker
        self.makeMultiplePicker = makeMultiplePicker
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload: Equatable {
        
        case c2bSubscribe(URL)
        case c2b(URL)
    }
    
    typealias MakeQRFailure = (QRCodeDetails<QRCode>) -> QRFailure
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = (MakeMultiplePickerPayload) -> MultiplePicker
}
