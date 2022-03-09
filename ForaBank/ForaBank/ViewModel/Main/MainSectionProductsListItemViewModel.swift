//
//  MainSectionProductsListItemViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 04.03.2022.
//

import Foundation

class MainSectionProductsListItemViewModel: Identifiable {

    let id: String
    
    internal init(id: String = UUID().uuidString) {
        
        self.id = id
    }
}

