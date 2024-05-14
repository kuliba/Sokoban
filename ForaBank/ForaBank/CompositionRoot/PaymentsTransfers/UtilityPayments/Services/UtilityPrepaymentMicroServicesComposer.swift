//
//  UtilityPrepaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

final class UtilityPrepaymentMicroServicesComposer {
    
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

extension UtilityPrepaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            paginate: paginate(pageSize: pageSize),
            search: search(pageSize: pageSize)
        )
    }
}

extension UtilityPrepaymentMicroServicesComposer {
    
    typealias PageSize = Int
    typealias MicroServices = UtilityPrepaymentMicroServices<UtilityPaymentOperator>
    typealias NanoServices = UtilityPrepaymentNanoServices<UtilityPaymentOperator>
}

private extension UtilityPrepaymentMicroServicesComposer {
    
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
