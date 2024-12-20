//
//  ToolbarFactory.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

import UIKit
import UIKitHelpers

public enum ToolbarFactory {}

public extension ToolbarFactory {
    
    static func makeToolbar(
        color: UIColor = .init(hexString: "#1C1C1C"),
        font: UIFont = .systemFont(ofSize: 18, weight: .bold),
        width: CGFloat = UIScreen.main.bounds.width,
        height: CGFloat = 44,
        doneButton: UIBarButtonItem,
        closeButton: UIBarButtonItem?
    ) -> UIToolbar {
        
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: width, height: height))
        
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var items: [UIBarButtonItem] = [flexibleSpace, doneButton]
        
        if let closeButton {
            
            closeButton.tintColor = color
            items.insert(closeButton, at: 0)
        }
        
        toolbar.items = items
        toolbar.setItems(items, animated: true)
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        
        return toolbar
    }
    
    static func makeToolbarViewModel(
        closeButtonLabel: ToolbarViewModel.ButtonViewModel.Label? = nil,
        closeButtonAction: @escaping () -> Void,
        doneButtonLabel: ToolbarViewModel.ButtonViewModel.Label,
        doneButtonAction: @escaping () -> Void
    ) -> ToolbarViewModel {
        
        return .init(
            doneButton: .init(
                label: doneButtonLabel,
                action: doneButtonAction
            ),
            closeButton: closeButtonLabel.map {
                .init(
                    label: $0,
                    action: closeButtonAction
                )
            }
        )
    }
}

// private
public extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
