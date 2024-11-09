//
//  QRBinderGetNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct QRBinderGetNavigationComposerMicroServices<ConfirmSberQR, MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source> {
    
    public let makeConfirmSberQR: MakeConfirmSberQR
    public let makeMixedPicker: MakeMixedPicker
    public let makeMultiplePicker: MakeMultiplePicker
    public let makeOperatorModel: MakeOperatorModel
    public let makePayments: MakePayments
    public let makeQRFailure: MakeQRFailure
    public let makeServicePicker: MakeServicePicker
    
    public init(
        makeConfirmSberQR: @escaping MakeConfirmSberQR,
        makeMixedPicker: @escaping MakeMixedPicker,
        makeMultiplePicker: @escaping MakeMultiplePicker,
        makeOperatorModel: @escaping MakeOperatorModel,
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure,
        makeServicePicker: @escaping MakeServicePicker
    ) {
        self.makeConfirmSberQR = makeConfirmSberQR
        self.makeMixedPicker = makeMixedPicker
        self.makeMultiplePicker = makeMultiplePicker
        self.makeOperatorModel = makeOperatorModel
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
        self.makeServicePicker = makeServicePicker
    }
}

public extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakeConfirmSberQR = (URL, @escaping (ConfirmSberQR?) -> Void) -> Void
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = (MakeMultiplePickerPayload) -> MultiplePicker
    
    typealias MakeOperatorModelPayload = SinglePayload<Operator, QRCode, QRMapping>
    typealias MakeOperatorModel = (MakeOperatorModelPayload) -> OperatorModel
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload {
        
        case c2bSubscribe(URL)
        case c2b(URL)
        case details(QRCode) // MainViewModelAction.Show.Requisites
        case source(Source)
    }
    
    typealias MakeQRFailure = (QRCode?) -> QRFailure
    
    typealias ProviderPayload = PayHub.ProviderPayload<Provider, QRCode, QRMapping>
    typealias MakeServicePicker = (ProviderPayload) -> ServicePicker
}

extension QRBinderGetNavigationComposerMicroServices.MakePaymentsPayload: Equatable where QRCode: Equatable, Source: Equatable {}
