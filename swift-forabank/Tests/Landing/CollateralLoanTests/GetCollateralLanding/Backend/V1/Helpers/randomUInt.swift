//
//  File.swift
//  
//
//  Created by Valentin Ozerov on 04.12.2024.
//

import Foundation

extension UInt {
    
    static var random: Self {
        
        .random(in: (0...UInt.max))
    }
}
