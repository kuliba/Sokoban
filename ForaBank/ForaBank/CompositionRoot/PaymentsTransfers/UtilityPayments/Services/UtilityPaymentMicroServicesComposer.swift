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
    
    private let pageSize: PageSize
    private let nanoServices: NanoServices
    
    init(
        pageSize: PageSize,
        nanoServices: NanoServices
    ) {
        self.pageSize = pageSize
        self.nanoServices = nanoServices
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment(pageSize: pageSize)
        )
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    typealias MicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
    
    typealias PageSize = Int
}

private extension UtilityPaymentMicroServicesComposer {
    
    func initiateUtilityPayment(
        pageSize: PageSize
    ) -> (@escaping InitiateUtilityPaymentCompletion) -> Void {
        
        return { [weak self] in self?.getOperatorsListByParam(pageSize, $0) }
    }
    
    private func getOperatorsListByParam(
        _ pageSize: PageSize,
        _ completion: @escaping InitiateUtilityPaymentCompletion
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
            
            completion(($0, operators))
        }
    }
    
    typealias InitiateUtilityPaymentCompletion = MicroServices.InitiateUtilityPaymentCompletion
}
