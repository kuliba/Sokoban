//
//  TemplatesListFlowEffectHandlerMicroServicesComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.08.2024.
//

import Foundation
import PayHub

final class TemplatesListFlowEffectHandlerMicroServicesComposer<Legacy, V1> {
    
    private let initiatePayment: InitiatePayment
    private let makeLegacyPayment: MakeLegacyPayment
    private let paymentsTransfersFlag: PaymentsTransfersFlag
    
    init(
        initiatePayment: @escaping InitiatePayment,
        makeLegacyPayment: @escaping MakeLegacyPayment,
        paymentsTransfersFlag: PaymentsTransfersFlag
    ) {
        self.initiatePayment = initiatePayment
        self.makeLegacyPayment = makeLegacyPayment
        self.paymentsTransfersFlag = paymentsTransfersFlag
    }
    
    typealias InitiatePaymentCompletion = (Result<V1, ServiceFailureAlert.ServiceFailure>) -> Void
    typealias InitiatePayment = (PaymentTemplateData, @escaping InitiatePaymentCompletion) -> Void
    typealias MakeLegacyPayment = (MicroServices.MakePaymentPayload) -> Legacy
}

extension TemplatesListFlowEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        let strategy = LegacyV1Strategy(
            makeLegacy: makeLegacyPayment,
            makeV1: makeV1Payment
        )
        
        return .init(makePayment: { [paymentsTransfersFlag] payload, completion in
            
            let isLegacy = payload.0.isLegacy(flag: paymentsTransfersFlag)
            
            strategy.compose(isLegacy: isLegacy, payload: payload) {
                
                switch $0 {
                case let .legacy(legacy):
                    completion(.success(.legacy(legacy)))
                    
                case let .v1(v1):
                    completion(v1)
                }
            }
        })
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices<Legacy, V1>
}

private extension PaymentTemplateData {
    
    func isLegacy(flag: PaymentsTransfersFlag) -> Bool {
        
        switch flag.rawValue {
        case .active:
            return paymentFlow == nil
            
        case .inactive:
            return type != .housingAndCommunalService
        }
    }
}

private extension TemplatesListFlowEffectHandlerMicroServicesComposer {
    
    private func makeV1Payment(
        _ payload: MicroServices.MakePaymentPayload,
        _ completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        initiatePayment(payload.0) { [weak self] in
            
            guard self != nil else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(v1):
                completion(.success(.v1(v1)))
            }
        }
    }
}
