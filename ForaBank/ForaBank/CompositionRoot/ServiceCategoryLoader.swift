//
//  ServiceCategoryLoader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation

typealias ServiceCategoryLoader = GenericLoaderOf<[ServiceCategory]>

extension ServiceCategoryLoader {
    
    static var `default`: Self {
        
        return .init(store: InMemoryStore<[ServiceCategory]>())
    }
    
    // ignore errors
    func load(
        _ completion: @escaping ([ServiceCategory]) -> Void
    ) {
        self.load { completion((try? $0.get()) ?? []) }
    }
    
    // ignore errors
    func save(
        _ categories: [ServiceCategory],
        _ completion: @escaping () -> Void
    ) {
        self.save(categories, validUntil: .distantFuture) { _ in
            
            completion()
        }
    }
}
