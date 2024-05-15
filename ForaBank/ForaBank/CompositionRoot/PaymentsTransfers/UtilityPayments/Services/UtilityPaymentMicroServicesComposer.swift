//
//  UtilityPaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation
import UtilityServicePrepaymentDomain

final class UtilityPaymentMicroServicesComposer<LastPayment, Operator>
where Operator: Identifiable {
    
    #warning("move flag to nano services")
    private let flag: Flag
    private let nanoServices: NanoServices
    
    init(
        flag: Flag,
        nanoServices: NanoServices
    ) {
        self.flag = flag
        self.nanoServices = nanoServices
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment,
            startPayment: startPayment()
        )
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    enum Flag {
        
        case live
        case stub((Select) -> StartPaymentResult)
        
        typealias Select = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.Select
        typealias StartPaymentResult = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>.StartPaymentResult
    }
    
    typealias MicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
}

private extension UtilityPaymentMicroServicesComposer {
    
    // MARK: - initiateUtilityPayment
    
    func initiateUtilityPayment(
        completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getOperatorsListByParam { [weak self] in
            
            self?.getAllLatestPayments($0, completion)
        }
    }
    
    private func getAllLatestPayments(
        _ operators: [Operator],
        _ completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getAllLatestPayments { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(lastPayments: $0, operators: operators, searchText: ""))
        }
    }
    
    // MARK: - startPayment
    
    func startPayment(
    ) -> PrepaymentFlowEffectHandler.StartPayment {
        
        switch flag {
        case .live:
            fatalError("unimplemented live")
            
        case let .stub(stub):
            
            return { payload, completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(stub(payload))
                }
            }
        }
    }
    
    typealias InitiateUtilityPaymentCompletion = PrepaymentFlowEffectHandler.InitiateUtilityPaymentCompletion
    
    typealias StartPaymentCompletion = PrepaymentFlowEffectHandler.StartPaymentCompletion
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
