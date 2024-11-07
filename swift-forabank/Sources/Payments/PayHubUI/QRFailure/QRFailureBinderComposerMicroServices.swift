//
//  QRFailureBinderComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

public struct QRFailureBinderComposerMicroServices<QRCode, QRFailure, Categories, DetailPayment> {
    
    public let makeCategories: MakeCategories
    public let makeDetailPayment: MakeDetailPayment
    public let makeQRFailure: MakeQRFailure
    
    public init(
        makeCategories: @escaping MakeCategories,
        makeDetailPayment: @escaping MakeDetailPayment,
        makeQRFailure: @escaping MakeQRFailure
    ) {
        self.makeCategories = makeCategories
        self.makeDetailPayment = makeDetailPayment
        self.makeQRFailure = makeQRFailure
    }
}

public extension QRFailureBinderComposerMicroServices {
    
    typealias MakeCategories = (QRCode) -> Categories
    typealias MakeDetailPayment = (QRCode) -> DetailPayment
    typealias MakeQRFailure = (QRCode) -> QRFailure
}
