//
//  RegularFieldViewModel+ext.swift
//  
//
//  Created by Дмитрий Савушкин on 09.07.2024.
//

import Foundation
import TextFieldComponent
import UIKit

typealias RegularFieldViewModel = ReducerTextFieldViewModel<TextFieldUI.ToolbarViewModel, KeyboardType>

extension RegularFieldViewModel {
    
    static func make(
        keyboardType: Keyboard,
        text: String?,
        placeholderText: String,
        limit: Int
    ) -> RegularFieldViewModel {
        
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: Transformers.limiting(limit).transform(_:)
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
