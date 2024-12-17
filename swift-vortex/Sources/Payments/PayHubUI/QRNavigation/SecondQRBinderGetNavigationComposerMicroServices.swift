//
//  SecondQRBinderGetNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct SecondQRBinderGetNavigationComposerMicroServices<ConfirmSberQR, MixedPicker, MultiplePicker, Operator, OperatorModel, Provider, QRCode, QRMapping, ServicePicker> {
    
    public let makeConfirmSberQR: MakeConfirmSberQR
    public let makeMixedPicker: MakeMixedPicker
    public let makeMultiplePicker: MakeMultiplePicker
    public let makeOperatorModel: MakeOperatorModel
    public let makeServicePicker: MakeServicePicker
    
    public init(
        makeConfirmSberQR: @escaping MakeConfirmSberQR,
        makeMixedPicker: @escaping MakeMixedPicker,
        makeMultiplePicker: @escaping MakeMultiplePicker,
        makeOperatorModel: @escaping MakeOperatorModel,
        makeServicePicker: @escaping MakeServicePicker
    ) {
        self.makeConfirmSberQR = makeConfirmSberQR
        self.makeMixedPicker = makeMixedPicker
        self.makeMultiplePicker = makeMultiplePicker
        self.makeOperatorModel = makeOperatorModel
        self.makeServicePicker = makeServicePicker
    }
}

public extension SecondQRBinderGetNavigationComposerMicroServices {
    
    typealias MakeConfirmSberQR = (URL, @escaping (ConfirmSberQR?) -> Void) -> Void
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = (MakeMultiplePickerPayload) -> MultiplePicker
    
    typealias MakeOperatorModelPayload = SinglePayload<Operator, QRCode, QRMapping>
    typealias MakeOperatorModel = (MakeOperatorModelPayload) -> OperatorModel
    
    typealias ProviderPayload = PayHub.ProviderPayload<Provider, QRCode, QRMapping>
    typealias MakeServicePicker = (ProviderPayload) -> ServicePicker
}
