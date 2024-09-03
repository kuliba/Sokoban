//
//  PaymentFlowMicroServiceComposer.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentFlowMicroServiceComposer<Mobile, QR, Standard, Tax, Transport> {
    
    private let nanoServices: NanoServices
    
    public init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax, Transport>
}

public extension PaymentFlowMicroServiceComposer {
    
    func compose() -> MicroService {
        
        return .init(makePaymentFlow: makePaymentFlow)
    }
    
    typealias MicroService = PaymentFlowMicroService<Mobile, QR, Standard, Tax, Transport>
}

private extension PaymentFlowMicroServiceComposer {
    
    typealias Flow = MicroService.Flow
    
    func makePaymentFlow(
        type: Flow.ID,
        completion: @escaping (MicroService.Flow) -> Void
    ) {
        switch type {
        case .mobile:
            nanoServices.makeMobile { completion(.mobile($0)) }
            
        case .qr:
            nanoServices.makeQR { completion(.qr($0)) }
            
        case .standard:
            nanoServices.makeStandard { completion(.standard($0)) }
            
        case .taxAndStateServices:
            nanoServices.makeTax { completion(.taxAndStateServices($0)) }
            
        case .transport:
            nanoServices.makeTransport { completion(.transport($0)) }
        }
    }
}
