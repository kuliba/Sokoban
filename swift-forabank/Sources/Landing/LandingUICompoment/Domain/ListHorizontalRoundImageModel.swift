//
//  ListHorizontalRoundImageViewModel.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct ListHorizontalRoundImageViewModel {
    
    let title: String?
    let items: [Item]
    
    struct SubInfo {
        
        let text: String
    }
    
    struct Details {
        
        let detailsGroupId: String
        let detailViewId: String
    }
    
    struct Item: Identifiable {
        
        let id: String
        let title: String?
        let image: Image
        let subInfo: SubInfo?
        let details: Details?
    }
}
