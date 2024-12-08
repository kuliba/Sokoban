//
//  RangeReplaceableCollection+isNilOrEmpty.swift
//
//
//  Created by Igor Malyarov on 05.11.2024.
//

public extension Optional 
where Wrapped == any RangeReplaceableCollection {
    
    var isNilOrEmpty: Bool {
        
        guard let collection = self else { return true }
        
        return collection.isEmpty
    }
}
