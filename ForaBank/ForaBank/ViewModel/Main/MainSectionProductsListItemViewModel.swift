//
//  MainSectionProductsListItemViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 04.03.2022.
//

import Foundation

class MainSectionProductsListItemViewModel: Identifiable {

    let id: UUID
    
    internal init(id: UUID = UUID()) {
        self.id = id
    }
}

