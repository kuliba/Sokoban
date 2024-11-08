//
//  SectionState.swift
//
//
//  Created by Дмитрий Савушкин on 24.07.2024.
//

import Foundation

struct SectionState {
    
    let items: [Item]
    
    struct Item: Identifiable {
        
        var id: String { title }
        let title: String
        let isSelected: Bool
    }
}
