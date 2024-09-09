//
//  ServiceItemsLoader.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.09.2024.
//

import Foundation

typealias ServiceItemsLoader = GenericLoaderOf<ItemsWithSerial>

struct ItemsWithSerial {
    
    let serial: String?
    let items: [Any]
}

extension ServiceItemsLoader {
    
    static var `default`: Self {
        
        return .init(store: InMemoryStore<ItemsWithSerial>())
    }
    
    // ignore errors
    func load(
        _ completion: @escaping (ItemsWithSerial) -> Void
    ) {
        self.load { completion((try? $0.get()) ?? .init(serial: "", items: [])) }
    }
    
    // ignore errors
    func save(
        _ itemsWithSerial: ItemsWithSerial,
        _ completion: @escaping () -> Void
    ) {
        self.save(itemsWithSerial, validUntil: .distantFuture) { _ in
            
            completion()
        }
    }
    
    func serial(
        _ completion: @escaping (String) -> Void
    ) {
        self.load { completion((try? $0.get())?.serial ?? "") }
    }
}
