//
//  MultiTextsWithIconsHorizontalViewModel.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiTextsWithIconsHorizontalViewModel {
    
    let lists: [Item]
}

extension MultiTextsWithIconsHorizontalViewModel {
    
    struct Item: Identifiable {
        
        let id: String
        let image: Image
        let title: TextItem?
    }
}

extension MultiTextsWithIconsHorizontalViewModel {
    
    struct TextItem {
        
        let title: String
    }
}
