//
//  PaymentFlowMicroServiceComposerNanoServices.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax, Transport, Failure: Error> {
    
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
    
    typealias Make<T> = (@escaping (Result<T, Failure>) -> Void) -> Void
    
    typealias MakeMobile = Make<Mobile>
    typealias MakeQR = Make<QR>
    typealias MakeStandard = Make<Standard>
    typealias MakeTax = Make<Tax>
    typealias MakeTransport = Make<Transport>
}
