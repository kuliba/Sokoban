//
//  UtilityPrepaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentDomain

final class UtilityPrepaymentMicroServicesComposer<Operator>
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

extension UtilityPrepaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(paginate: paginate, search: search)
    }
}

extension UtilityPrepaymentMicroServicesComposer {
    
    typealias MicroServices = UtilityPrepaymentMicroServices<Operator>
    typealias NanoServices = UtilityPrepaymentNanoServices<Operator>
}

private extension UtilityPrepaymentMicroServicesComposer {
    
    func paginate(
        payload: PaginatePayload<Operator.ID>,
        completion: @escaping ([Operator]) -> Void
    ) {
        nanoServices.loadOperators(.init(afterOperatorID: payload.operatorID, searchText: payload.searchText, pageSize: pageSize), completion)
    }
    
    func search(
        searchText: String,
        completion: @escaping ([Operator]) -> Void
    ) {
        nanoServices.loadOperators(.init(afterOperatorID: nil, searchText: searchText, pageSize: pageSize), completion)
    }
}
