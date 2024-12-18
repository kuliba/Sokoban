//
//  nilIfEmpty.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension Array {
    
    var nilIfEmpty: Array? {
        
        isEmpty ? nil : self
    }
}
