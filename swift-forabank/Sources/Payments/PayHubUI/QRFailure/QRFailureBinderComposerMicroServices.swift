//
//  QRFailureBinderComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

public struct QRFailureBinderComposerMicroServices<QRCode, QRFailure, CategoryPicker, DetailPayment> {
    
    public let makeCategoryPicker: MakeCategoryPicker
    public let makeDetailPayment: MakeDetailPayment
    public let makeQRFailure: MakeQRFailure
    
    public init(
        makeCategoryPicker: @escaping MakeCategoryPicker,
        makeDetailPayment: @escaping MakeDetailPayment,
        makeQRFailure: @escaping MakeQRFailure
    ) {
        self.makeCategoryPicker = makeCategoryPicker
        self.makeDetailPayment = makeDetailPayment
        self.makeQRFailure = makeQRFailure
    }
}

public extension QRFailureBinderComposerMicroServices {
    
    typealias MakeCategoryPicker = (QRCode) -> CategoryPicker
    typealias MakeDetailPayment = (QRCode?) -> DetailPayment
    typealias MakeQRFailure = (QRCodeDetails<QRCode>?) -> QRFailure
}
