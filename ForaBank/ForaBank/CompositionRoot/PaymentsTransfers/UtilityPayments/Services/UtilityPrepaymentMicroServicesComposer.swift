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
        for categoryType: ServiceCategory.CategoryType
    ) -> MicroServices {
        
        let duplicatesRemover = DuplicatesRemover()
        let decorated = duplicatesRemover(self.nanoServices.loadOperators)
        
        return .init(
            paginate: makePaginate(for: categoryType, with: decorated),
            search: makeSearch(for: categoryType, with: decorated)
        )
    }
    
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
}

private extension UtilityPrepaymentMicroServicesComposer {
    
    typealias Load = (NanoServices.LoadOperatorsPayload, @escaping ([Operator]) -> Void) -> Void
    
    func makePaginate(
        for categoryType: ServiceCategory.CategoryType,
        with load: @escaping Load
    ) -> (PaginatePayload<Operator.ID>, @escaping ([Operator]) -> Void) -> Void {
        
        return { payload, completion in
            
            let throttler = ThrottleDecorator(delay: 0.3)
            
            let payload = Payload(
                afterOperatorID: payload.operatorID,
                for: categoryType,
                searchText: payload.searchText,
                pageSize: self.pageSize
            )
            
            throttler { load(payload, completion) }
        }
    }
    
    func makeSearch(
        for categoryType: ServiceCategory.CategoryType,
        with load: @escaping Load
    ) -> (String, @escaping ([Operator]) -> Void) -> Void {
        
        return { searchText, completion in
            
            let debouncer = DebounceDecorator(delay: 0.3)
            
            let payload = Payload(
                afterOperatorID: nil,
                for: categoryType,
                searchText: searchText,
                pageSize: self.pageSize
            )
            
            debouncer { load(payload, completion) }
        }
    }
    
    typealias Payload = NanoServices.LoadOperatorsPayload
    typealias DuplicatesRemover = RemoveDuplicatesDecorator<Payload, [Operator]>
}
