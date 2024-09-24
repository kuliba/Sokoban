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
    
    typealias NanoServices = UtilityPrepaymentNanoServices<Operator>
}

extension UtilityPrepaymentMicroServicesComposer {
    
    func compose(
        for category: ServiceCategory
    ) -> MicroServices {
        
        return .init(
            paginate: makePaginate(for: category),
            search: makeSearch(for: category)
        )
    }
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
}

private extension UtilityPrepaymentMicroServicesComposer {
    
    func makePaginate(
        for category: ServiceCategory
    ) -> (PaginatePayload<Operator.ID>, @escaping ([Operator]) -> Void) -> Void {
        
        return { payload, completion in
            
            let duplicatesRemover = DuplicatesRemover()
            let decorated = duplicatesRemover(self.nanoServices.loadOperators)
            
            let throttler = ThrottleDecorator(delay: 0.3)
            
            let payload = Payload(
                afterOperatorID: payload.operatorID,
                for: category,
                searchText: payload.searchText,
                pageSize: self.pageSize
            )
            
            throttler { decorated(payload, completion) }
        }
    }
    
    func makeSearch(
        for category: ServiceCategory
    ) -> (String, @escaping ([Operator]) -> Void) -> Void {
        
        return { searchText, completion in
            
            let duplicatesRemover = DuplicatesRemover()
            let decorated = duplicatesRemover(self.nanoServices.loadOperators)
            
            let debouncer = DebounceDecorator(delay: 0.3)
            
            let payload = Payload(
                afterOperatorID: nil,
                for: category,
                searchText: searchText,
                pageSize: self.pageSize
            )
            
            debouncer { decorated(payload, completion) }
        }
    }
    
    typealias Payload = NanoServices.LoadOperatorsPayload
    typealias DuplicatesRemover = RemoveDuplicatesDecorator<Payload, [Operator]>
}
