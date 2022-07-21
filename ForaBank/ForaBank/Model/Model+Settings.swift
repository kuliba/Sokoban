//
//  Model+Settings.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Settings {
        
        struct UpdateProductsHidden: Action {

            let productID: ProductData.ID
        }
        
        struct UpdateIsPaymentsTransfersOpened: Action {
            
            let value: Bool
        }
    }
}

//MARK: - Data Helpers

extension Model {
    
    var settingsLaunchedBefore: Bool {
        
        do {
            
            let launchedBefore: Bool = try settingsAgent.load(type: .general(.launchedBefore))
            return launchedBefore
            
        } catch {
            
            return false
        }
    }
    
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
    
    var isPaymentsTransfersOpened: Bool {
        
        do {
    
            let isPaymentsTransfersOpened: Bool = try settingsAgent.load(type: .general(.isPaymentsTransfersOpened))
            return isPaymentsTransfersOpened
        
        } catch {
            
            return false
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleUpdateIsPaymentsTransfersOpened(
        payload: ModelAction.Settings.UpdateIsPaymentsTransfersOpened) {
        
        do {
            
            try settingsAgent.store(payload.value,
                                    type: .general(.isPaymentsTransfersOpened))
        } catch {
            
            handleSettingsCachingError(error: error)
        }
    }
    
    
    func handleUpdateProductsHidden(_ productID: ProductData.ID) {

        var productsHidden = self.productsHidden.value

        if productsHidden.contains(productID) {

            guard let firstIndex = productsHidden.firstIndex(where: { $0 == productID }) else {
                return
            }

            productsHidden.remove(at: firstIndex)

        } else {

            productsHidden.append(productID)
        }

        self.productsHidden.value = productsHidden

        do {

            try settingsAgent.store(self.productsHidden.value, type: .interface(.productsHidden))

        } catch {

            handleSettingsCachingError(error: error)
        }
    }
}
