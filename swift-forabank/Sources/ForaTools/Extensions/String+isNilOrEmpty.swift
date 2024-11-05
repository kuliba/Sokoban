//
//  String+isNilOrEmpty.swift
//
//
//  Created by Igor Malyarov on 05.11.2024.
//

public extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        
        guard let string = self else { return true }
        
        return string.isEmpty
    }
}
