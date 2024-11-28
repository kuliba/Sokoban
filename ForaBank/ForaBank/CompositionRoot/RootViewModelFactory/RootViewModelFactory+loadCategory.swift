//
//  RootViewModelFactory+loadCategory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func loadCategory(
        type: ServiceCategory.CategoryType,
        completion: @escaping (ServiceCategory?) -> Void
    ) {
        schedulers.interactive.schedule { [weak model] in
            
            guard let model else { return }
            
            completion(model.loadCategory(ofType: type))
        }
    }
}

private extension Model {
    
    func loadCategory(
        ofType type: ServiceCategory.CategoryType
    ) -> ServiceCategory? {
        
        guard let codable = localAgent.load(type: [CodableServiceCategory].self)
        else { return nil }
        
        let categories: [ServiceCategory] = .init(codable: codable)
        
        return categories.first { $0.type == type }
    }
}
