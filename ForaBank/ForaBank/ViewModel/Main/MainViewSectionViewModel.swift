//
//  MainViewSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation

class MainSectionViewModel {}

class MainSectionCollapsableViewModel: MainSectionViewModel {
    
    @Published var isCollapsed: Bool
    
    init(isCollapsed: Bool) {
        
        self.isCollapsed = isCollapsed
        super.init()
    }
}
