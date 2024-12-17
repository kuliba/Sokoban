//
//  MyProductsOnboadingSettings.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 24.10.2022.
//

import Foundation

class MyProductsOnboardingSettings: Codable {
    
    var isOpenedView: Bool
    var isOpenedReorder: Bool
    var isHideOnboardingShown: Bool
    
    init(isOpenedView: Bool, isOpenedReorder: Bool, isHideOnboardingShown: Bool) {
        
        self.isOpenedView = isOpenedView
        self.isOpenedReorder = isOpenedReorder
        self.isHideOnboardingShown = isHideOnboardingShown
    }
    
}
