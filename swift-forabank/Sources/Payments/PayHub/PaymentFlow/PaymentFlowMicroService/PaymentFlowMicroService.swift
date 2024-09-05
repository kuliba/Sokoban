//
//  PaymentFlowMicroService.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentFlowMicroService<Mobile, QR, Standard, Tax, Transport> {
    
    public let makePaymentFlow: MakePaymentFlow
    
    public init(
        makePaymentFlow: @escaping MakePaymentFlow
    ) {
        self.makePaymentFlow = makePaymentFlow
    }
}

public extension PaymentFlowMicroService {
    
    typealias Flow = PaymentFlow<Mobile, QR, Standard, Tax, Transport>
    typealias MakePaymentFlow = (PaymentFlowID, @escaping (Flow) -> Void) -> Void
}
