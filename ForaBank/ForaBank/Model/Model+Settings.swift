//
//  Model+Settings.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

extension Model {
    
    var settingsMainSections: MainSectionSettings {
        
        do {
            
            let settings: MainSectionSettings = try settingsAgent.load(type: .interface(.mainSections))
            return settings
            
        } catch {
            
            return .initial
        }
    }
    
    func settingsUpdate(_ settings: MainSectionSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.mainSections))
            
        } catch {
            
            //TODO: log
            print(error.localizedDescription)
        }
    }
}
