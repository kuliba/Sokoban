//
//  AmountToolbarViewModel.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 21.03.2025.
//

public struct AmountToolbarViewModel {
    
    let doneButton: ButtonViewModel
    let closeButton: ButtonViewModel?
    
    public init(
        doneButton: ButtonViewModel,
        closeButton: ButtonViewModel? = nil
    ) {
        self.doneButton = doneButton
        self.closeButton = closeButton
    }
    
    public struct ButtonViewModel {
        
        let label: Label
        let action: () -> Void
        
        public init(label: Label, action: @escaping () -> Void) {
            
            self.label = label
            self.action = action
        }
        
        public enum Label: Equatable {
            
            case title(String)
            case image(String)
        }
    }
}
