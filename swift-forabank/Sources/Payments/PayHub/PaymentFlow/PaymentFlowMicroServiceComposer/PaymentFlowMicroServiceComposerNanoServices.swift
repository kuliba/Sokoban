//
//  PaymentFlowMicroServiceComposerNanoServices.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax, Transport> {
    
    public let makeMobile: MakeMobile
    public let makeQR: MakeQR
    public let makeStandard: MakeStandard
    public let makeTax: MakeTax
    public let makeTransport: MakeTransport
    
    public init(
        makeMobile: @escaping MakeMobile, 
        makeQR: @escaping MakeQR,
        makeStandard: @escaping MakeStandard,
        makeTax: @escaping MakeTax,
        makeTransport: @escaping MakeTransport
    ) {
        self.makeMobile = makeMobile
        self.makeQR = makeQR
        self.makeStandard = makeStandard
        self.makeTax = makeTax
        self.makeTransport = makeTransport
    }
}

public extension PaymentFlowMicroServiceComposerNanoServices {
    
    typealias MakeMobile = (@escaping (Mobile) -> Void) -> Void
    typealias MakeQR = (@escaping (QR) -> Void) -> Void
    typealias MakeStandard = (@escaping (Standard) -> Void) -> Void
    typealias MakeTax = (@escaping (Tax) -> Void) -> Void
    typealias MakeTransport = (@escaping (Transport) -> Void) -> Void
}
