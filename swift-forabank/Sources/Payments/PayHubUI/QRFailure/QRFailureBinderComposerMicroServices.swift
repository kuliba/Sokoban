//
//  QRFailureBinderComposerMicroServices.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

public struct QRFailureBinderComposerMicroServices<QRFailure, Categories, DetailPayment> {
    
    public let makeQRFailure: MakeQRFailure
    public let makeCategories: MakeCategories
    public let makeDetailPayment: MakeDetailPayment
    
    public init(
        makeQRFailure: @escaping MakeQRFailure,
        makeCategories: @escaping MakeCategories,
        makeDetailPayment: @escaping MakeDetailPayment
) {
        self.makeQRFailure = makeQRFailure
        self.makeCategories = makeCategories
        self.makeDetailPayment = makeDetailPayment
    }
}

public extension QRFailureBinderComposerMicroServices {
    
    typealias MakeQRFailure = () -> QRFailure
    typealias MakeCategories = () -> Categories?
    typealias MakeDetailPayment = () -> DetailPayment
}
