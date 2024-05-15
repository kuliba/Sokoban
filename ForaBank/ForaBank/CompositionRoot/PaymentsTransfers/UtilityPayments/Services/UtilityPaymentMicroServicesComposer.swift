//
//  UtilityPaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import OperatorsListComponents
import UtilityServicePrepaymentDomain

final class UtilityPaymentMicroServicesComposer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let pageSize: Int
    private let nanoServices: NanoServices
    
    init(
        pageSize: Int,
        nanoServices: NanoServices
    ) {
        self.pageSize = pageSize
        self.nanoServices = nanoServices
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment
        )
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    typealias MicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
}

private extension UtilityPaymentMicroServicesComposer {
    
    func initiateUtilityPayment(
        completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getOperatorsListByParam(pageSize) { [weak self] in
            
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
    
    typealias InitiateUtilityPaymentCompletion = MicroServices.InitiateUtilityPaymentCompletion
}
