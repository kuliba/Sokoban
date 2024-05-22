//
//  LayoutInfo.swift
//  
//
//  Created by Igor Malyarov on 22.05.2024.
//

struct LayoutInfo: Equatable {
    
    let id: ID
    let title: String
    let value: String
    let style: Style
}

extension LayoutInfo {
    
    enum ID: Equatable {
        
        case amount, brandName, recipientBank
    }

    enum Style {
        
        case expanded
        case compressed
    }
}
