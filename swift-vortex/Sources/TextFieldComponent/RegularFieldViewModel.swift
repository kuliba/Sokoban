//
//  RegularFieldViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 12.07.2024.
//

import Foundation
import TextFieldUI
import UIKit

public typealias RegularFieldViewModel = ReducerTextFieldViewModel<TextFieldUI.ToolbarViewModel, KeyboardType>

public extension RegularFieldViewModel {
    
    static func make(
        keyboardType: Keyboard,
        text: String?,
        placeholderText: String,
        limit: Int
    ) -> RegularFieldViewModel {
        
        let transformer = Transform(build: {
            
            Transformers.limiting(limit)
        })
        
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: transformer.transform(_:)
        )
        
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: .image("Close Button"),
            closeButtonAction: {
                UIApplication.shared.endEditing()
            },
            doneButtonLabel: .title("Готово"),
            doneButtonAction: {
                UIApplication.shared.endEditing()
            }
        )
        
        if let text {
            
            return .init(
                initialState: .noFocus(text),
                reducer: reducer,
                keyboardType: keyboardType,
                toolbar: toolbar
            )
            
        } else {
            
            return .init(
                initialState: .placeholder(placeholderText),
                reducer: reducer,
                keyboardType: keyboardType,
                toolbar: toolbar
            )
        }
    }
}
