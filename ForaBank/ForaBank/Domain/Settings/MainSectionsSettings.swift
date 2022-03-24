//
//  MainSectionsSettings.swift
//  ForaBank
//
//  Created by Max Gribov on 23.03.2022.
//

import Foundation

struct MainSectionSettings: Codable {
    
    var sectionsExpanded: [MainSectionType: Bool]
    
    mutating func update(isExpanded: Bool, sectionType: MainSectionType) {
        
        sectionsExpanded[sectionType] = isExpanded
    }
}

extension MainSectionSettings {
    
    static let initial: MainSectionSettings = {
       
        var sectionsExpanded = [MainSectionType: Bool]()
        for section in MainSectionType.allCases {
            
            sectionsExpanded[section] = true
        }
        
        return MainSectionSettings(sectionsExpanded: sectionsExpanded)
        
    }()
}
