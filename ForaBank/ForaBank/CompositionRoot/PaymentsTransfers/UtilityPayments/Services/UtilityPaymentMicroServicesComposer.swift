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
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
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
    
    typealias InitiateUtilityPaymentCompletion = PrepaymentFlowEffectHandler.InitiateUtilityPaymentCompletion
    
    // MARK: - startPayment
    
    func startPayment(
    ) -> PrepaymentFlowEffectHandler.StartPayment {
        
        return nanoServices.startAnywayPayment
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
