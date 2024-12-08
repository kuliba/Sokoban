//
//  Publishers+combineLatestMany.swift
//  
//
//  Created by Igor Malyarov on 26.11.2024.
//

import Combine

extension Publishers {
    
    public static func combineLatestMany<T>(_ publishers: [AnyPublisher<T, Never>]) -> AnyPublisher<[T], Never> {
        
        guard !publishers.isEmpty else {
            
            return Just([]).eraseToAnyPublisher()
        }
        
        return publishers
            .reduce(Just([]).eraseToAnyPublisher()) { combined, publisher in
                
                combined.combineLatest(publisher) { existingValues, newValue in
                    
                    existingValues + [newValue]
                }
                .eraseToAnyPublisher()
            }
    }
}
