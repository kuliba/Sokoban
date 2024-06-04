//
//  UtilityPrepaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain
import ForaTools

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
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
    typealias NanoServices = UtilityPrepaymentNanoServices<Operator>
}

private extension UtilityPrepaymentMicroServicesComposer {
    
    func paginate(
        payload: PaginatePayload<Operator.ID>,
        completion: @escaping ([Operator]) -> Void
    ) {
        let duplicatesRemover = DuplicatesRemover()
        let decorated = duplicatesRemover(nanoServices.loadOperators)
        
        let throttler = ThrottleDecorator(delay: 0.3)
        
        let payload = Payload(
            afterOperatorID: payload.operatorID,
            searchText: payload.searchText,
            pageSize: pageSize
        )
        
        throttler { decorated(payload, completion) }
    }
    
    func search(
        searchText: String,
        completion: @escaping ([Operator]) -> Void
    ) {
        let duplicatesRemover = DuplicatesRemover()
        let decorated = duplicatesRemover(nanoServices.loadOperators)

        let debouncer = DebounceDecorator(delay: 0.3)

        let payload = Payload(
            afterOperatorID: nil,
            searchText: searchText,
            pageSize: pageSize
        )
        
        debouncer { decorated(payload, completion) }
    }
    
    typealias Payload = NanoServices.LoadOperatorsPayload
    typealias DuplicatesRemover = RemoveDuplicatesDecorator<Payload, [Operator]>
}
