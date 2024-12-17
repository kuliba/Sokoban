//
//  ProductsSectionsSettings.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 07.08.2022.
//

import Foundation

struct ProductsSectionsSettings: Codable {
    
    var collapsed: [MyProductsSectionViewModel.ID: Bool]
    
    mutating func update(sectionType: MyProductsSectionViewModel.ID, isCollapsed: Bool) {
        
        collapsed[sectionType] = isCollapsed
    }
}
