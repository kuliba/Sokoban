//
//  TemplatesListFlowEffectHandlerMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.08.2024.
//

import Foundation
import PayHub

final class TemplatesListFlowEffectHandlerMicroServicesComposer<Legacy, V1> {
    
    private let initiatePayment: InitiatePayment
    private let makeLegacyPayment: MakeLegacyPayment
    private let paymentsTransfersFlag: PaymentsTransfersFlag
    private let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    
    init(
        initiatePayment: @escaping InitiatePayment,
        makeLegacyPayment: @escaping MakeLegacyPayment,
        paymentsTransfersFlag: PaymentsTransfersFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    ) {
        self.initiatePayment = initiatePayment
        self.makeLegacyPayment = makeLegacyPayment
        self.paymentsTransfersFlag = paymentsTransfersFlag
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
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
        
        return .init(makePayment: { payload, completion in
            
            strategy.compose(
                isLegacy: self.isLegacy(templateType: payload.0.type),
                payload: payload
            ) {
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

private extension TemplatesListFlowEffectHandlerMicroServicesComposer {
    
    enum Output {
        
        case legacy, v1
        
        var isLegacy: Bool { self == .legacy }
    }
    
    func output(
        for templateType: PaymentTemplateData.Kind
    ) -> Output {
        
        switch (paymentsTransfersFlag.rawValue, utilitiesPaymentsFlag.rawValue) {
        case (.active, _):
            return .v1
            
        case (.inactive, .inactive):
            return .legacy
            
        case (.inactive, .active):
            switch templateType {
            case .housingAndCommunalService:
                return .v1
                
            default:
                return .legacy
            }
        }
    }
    
    func isLegacy(
        templateType: PaymentTemplateData.Kind
    ) -> Bool {
        
        output(for: templateType).isLegacy
    }
    
    private func makeV1Payment(
        _ payload: MicroServices.MakePaymentPayload,
        _ completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        initiatePayment(payload.0) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(v1):
                completion(.success(.v1(v1)))
            }
        }
    }
}
