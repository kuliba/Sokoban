//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    
    @Published var sections: [MainSectionViewModel]
    @Published var isRefreshing: Bool
    
    init(sections: [MainSectionViewModel], isRefreshing: Bool) {
        
        self.sections = sections
        self.isRefreshing = isRefreshing
    }
}

