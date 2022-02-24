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
    
    init(sections: [MainSectionViewModel]) {
        
        self.sections = sections
    }
}

