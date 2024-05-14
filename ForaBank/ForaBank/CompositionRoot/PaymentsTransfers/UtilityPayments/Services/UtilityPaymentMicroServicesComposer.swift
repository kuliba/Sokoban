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
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    func compose(pageSize: PageSize) -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment(pageSize: pageSize),
            paginate: paginate(pageSize: pageSize),
            search: search(pageSize: pageSize)
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

private extension UtilityPaymentMicroServicesComposer {
    
    func paginate(
        pageSize: PageSize
    ) -> MicroServices.Paginate {
        
        return { [weak self] payload, completion in
            
            self?.nanoServices.loadOperators(.init(afterOperatorID: payload.operatorID, searchText: payload.searchText, pageSize: pageSize), completion)
        }
    }
    
    func search(
        pageSize: PageSize
    ) -> MicroServices.Search {
        
        return { [weak self] searchText, completion in
            
            self?.nanoServices.loadOperators(.init(afterOperatorID: nil, searchText: searchText, pageSize: pageSize), completion)
        }
    }
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
}
