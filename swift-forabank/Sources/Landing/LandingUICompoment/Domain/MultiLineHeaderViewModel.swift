//
//  MultiLineHeaderViewModel.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiLineHeaderViewModel {
    
    let regularTextItems: [Item]?
    let boldTextItems: [Item]?
    
    struct Item: Identifiable {
        
        let id: String
        let name: String
    }
}
