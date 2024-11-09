//
//  QRBinderGetNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct QRBinderGetNavigationComposerMicroServices<MixedPicker, MultiplePicker, Operator, Payments, Provider, QRCode, QRMapping, QRFailure, ServicePicker> {
    
    public let makeMixedPicker: MakeMixedPicker
    public let makeMultiplePicker: MakeMultiplePicker
    public let makePayments: MakePayments
    public let makeQRFailure: MakeQRFailure
    public let makeServicePicker: MakeServicePicker
    
    public init(
        makeMixedPicker: @escaping MakeMixedPicker,
        makeMultiplePicker: @escaping MakeMultiplePicker,
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure,
        makeServicePicker: @escaping MakeServicePicker
    ) {
        self.makeMixedPicker = makeMixedPicker
        self.makeMultiplePicker = makeMultiplePicker
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
        self.makeServicePicker = makeServicePicker
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = (MakeMultiplePickerPayload) -> MultiplePicker
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload {
        
        case c2bSubscribe(URL)
        case c2b(URL)
        case details(QRCode) // MainViewModelAction.Show.Requisites
    }
    
    typealias MakeQRFailure = (QRCodeDetails<QRCode>) -> QRFailure
    
    typealias ProviderPayload = PayHub.ProviderPayload<Provider, QRCode, QRMapping>
    typealias MakeServicePicker = (ProviderPayload) -> ServicePicker
}

extension QRBinderGetNavigationComposerMicroServices.MakePaymentsPayload: Equatable where QRCode: Equatable {}
