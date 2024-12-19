//
//  RootViewModelFactory+decorate.swift
//  Vortex
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
        
        return { [weak self] completion in
            
            guard let self else { return completion(nil) }
            
            decoratee { [weak self] in
                
                guard let self else { return completion(nil) }
                
                switch $0 {
                case .none:
                    completion(nil)
                    
                case .some([]):
                    completion([])
                    
                case let .some(categories):
                    decoration(categories) { [weak self] failedCategories in
                        
                        guard let self else { return completion(categories) }
                        
                        if !failedCategories.isEmpty {
                            
                            errorLog(category: .network, message: "Fail to load categories named: \(failedCategories.map(\.name)).")
                        }
                        
                        completion(categories)
                    }
                }
            }
        }
    }
}
