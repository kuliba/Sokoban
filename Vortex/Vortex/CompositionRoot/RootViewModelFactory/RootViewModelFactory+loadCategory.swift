//
//  RootViewModelFactory+loadServiceCategory.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

// TODO: - Switch to ephemeralServiceCategoryStore query after extracting Infra/EphemeralInfra (as of now this store is hidden behind composed `load/reload` closures)
extension RootViewModelFactory {
    
    @inlinable
    func loadServiceCategory(
        ofType type: ServiceCategory.CategoryType,
        completion: @escaping (ServiceCategory?) -> Void
    ) {
        schedulers.interactive.schedule { [weak model] in
            
            guard let model else { return }
            
            completion(model.loadServiceCategory(ofType: type))
        }
    }
    
    @inlinable
    func loadServiceCategory(
        ofType type: String,
        completion: @escaping (ServiceCategory?) -> Void
    ) {
        schedulers.interactive.schedule { [weak model] in
            
            guard let model else { return }
            
            completion(model.loadServiceCategory(ofType: type))
        }
    }
}

private extension Model {
    
    func loadServiceCategory(
        ofType type: ServiceCategory.CategoryType
    ) -> ServiceCategory? {
        
        return loadServiceCategories()?.first { $0.type == type }
    }
    
    func loadServiceCategory(
        ofType type: String
    ) -> ServiceCategory? {
        
        return loadServiceCategories()?.first { $0.type.name == type }
    }
    
    func loadServiceCategories() -> [ServiceCategory]? {
        
        guard let codable = localAgent.load(type: [CodableServiceCategory].self)
        else { return nil }
        
        return .init(codable: codable)
    }
}
