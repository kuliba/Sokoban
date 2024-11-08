//
//  Optional+get.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

public extension Optional {
    
    func get(orThrow error: Error) throws -> Wrapped {
        
        guard let wrapped = self else { throw error }
        
        return wrapped
    }
}
