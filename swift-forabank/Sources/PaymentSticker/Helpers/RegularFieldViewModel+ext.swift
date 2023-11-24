//
//  RegularFieldViewModel+ext.swift
//  
//
//  Created by Дмитрий Савушкин on 24.11.2023.
//

import Foundation
import TextFieldComponent
import UIKit

typealias RegularFieldViewModel = ReducerTextFieldViewModel<TextFieldUI.ToolbarViewModel, KeyboardType>

extension RegularFieldViewModel {
    
    static func make(
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
        
        return .init(
            initialState: .placeholder(placeholderText),
            reducer: reducer,
            keyboardType: .number,
            toolbar: toolbar
        )
    }
}
