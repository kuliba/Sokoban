//
//  MainSectionsSettings.swift
//  ForaBank
//
//  Created by Max Gribov on 23.03.2022.
//

import Foundation

struct MainSectionsSettings: Codable {
    
    var collapsed: [MainSectionType: Bool]
    
    mutating func update(sectionType: MainSectionType, isCollapsed: Bool) {
        
        collapsed[sectionType] = isCollapsed
    }
}

