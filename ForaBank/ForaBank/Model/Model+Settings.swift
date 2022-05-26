//
//  Model+Settings.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

//MARK: - Data Helpers

extension Model {
    
    var settingsMainSections: MainSectionsSettings {
        
        do {
    
            let settings: MainSectionsSettings = try settingsAgent.load(type: .interface(.mainSections))
            return settings
        
        } catch {
            
            return MainSectionsSettings(collapsed: [:])
        }
    }
    
    func settingsMainSectionsUpdate(_ settings: MainSectionsSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.mainSections))
            
        } catch {
            
            //TODO: log
            print(error.localizedDescription)
        }
    }
}
