//
//  ToolbarViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.01.2023.
//

import Foundation

struct ToolbarViewModel {
    
    let doneButton: ButtonViewModel
    let closeButton: ButtonViewModel?
    
    class ButtonViewModel: ObservableObject {
        
        @Published var isEnabled: Bool
        let action: () -> Void
        
        init(isEnabled: Bool, action: @escaping () -> Void) {
            
            self.isEnabled = isEnabled
            self.action = action
        }
    }
    
    init(doneButton: ButtonViewModel, closeButton: ButtonViewModel? = nil) {
        
        self.doneButton = doneButton
        self.closeButton = closeButton
    }
}
