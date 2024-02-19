//
//  ViewModel.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

class ViewModel: ObservableObject {
    
    @Published var state: SliderState
    
    init(state: SliderState) {
        
        self.state = state
    }
}

