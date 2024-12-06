//
//  RootViewModelFactory+decorate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

extension RootViewModelFactory {
    
    typealias ServiceCategoryBatchService = ([ServiceCategory], @escaping ([ServiceCategory]) -> Void) -> Void
    
    @inlinable
    func decorate(
        _ decoratee: @escaping Load<[ServiceCategory]>,
        with decoration: @escaping ServiceCategoryBatchService
    ) -> Load<[ServiceCategory]> {
        
        return { [log = logger.log] completion in
            
            decoratee {
                
                switch $0 {
                case .none:
                    completion(nil)
                    
                case .some([]):
                    completion([])
                    
                case let .some(categories):
                    decoration(categories) { failedCategories in
                        
                        if !failedCategories.isEmpty {
                            
                            log(.error, .network, "Fail to load categories named: \(failedCategories.map(\.name)).", #fileID, #line)
                        }
                    }
                    
                    completion(categories)
                }
            }
        }
    }
}
