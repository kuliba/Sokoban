//
//  ToolbarViewModel.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Foundation

public struct ToolbarViewModel {
    
    let doneButton: ButtonViewModel
    let closeButton: ButtonViewModel?
    
    class ButtonViewModel: ObservableObject {
        
        @Published public var isEnabled: Bool
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
