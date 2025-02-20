//
//  DetailsCell.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

enum DetailsCell: Equatable {
    
    case field(Field)
    case product(Product)
    
    struct Field: Equatable {
        
        let image: Image?
        let title: String
        let value: String
    }
    
    struct Product: Equatable {
        
        let title: String
    }
}
