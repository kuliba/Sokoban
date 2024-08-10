//
//  TemplatesListFlowEffectHandlerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

final class TemplatesListFlowEffectHandlerNanoServicesComposer {
    
}

extension TemplatesListFlowEffectHandlerNanoServicesComposer {
        
    func compose() -> NanoServices {
        
        return .init(initiatePayment: initiatePayment)
    }
    
    typealias NanoServices = TemplatesListFlowEffectHandlerNanoServices
}

private extension TemplatesListFlowEffectHandlerNanoServicesComposer {
    
    func initiatePayment(
        payload: NanoServices.InitiatePaymentPayload,
        completion: @escaping NanoServices.InitiatePaymentCompletion
    ) {
        
    }
}
