//
//  QRBinderGetMappedNavigationComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation
import PayHub

public struct QRBinderGetMappedNavigationComposerMicroServices<MixedPicker, Operator, Provider, QRCode, QRMapping, QRFailure> {
    
    public let makeQRFailure: MakeQRFailure
    public let makeMixedPicker: MakeMixedPicker
    
    public init(
        makeQRFailure: @escaping MakeQRFailure,
        makeMixedPicker: @escaping MakeMixedPicker
    ) {
        self.makeQRFailure = makeQRFailure
        self.makeMixedPicker = makeMixedPicker
    }
}

public extension QRBinderGetMappedNavigationComposerMicroServices {
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = (MakeMixedPickerPayload) -> MixedPicker
        
    typealias MakeQRFailure = (QRCodeDetails<QRCode>) -> QRFailure
}
