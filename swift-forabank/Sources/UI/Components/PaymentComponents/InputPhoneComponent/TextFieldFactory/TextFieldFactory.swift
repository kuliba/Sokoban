//
//  TextFieldFactory.swift
//
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import Foundation
import TextFieldComponent
import UIKit

typealias RegularFieldViewModel = ReducerTextFieldViewModel<TextFieldUI.ToolbarViewModel, KeyboardType>

/// A namespace for factory methods used to create text input field.
enum TextFieldFactory {}

extension TextFieldFactory {
    
    /// Creates a view model for general purpose text field.
    static func makeTextField(
        placeholderText: String,
        transformer: Transformer,
        keyboardType: KeyboardType,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> RegularFieldViewModel {
        
        let initialState = TextFieldState.makeTextFieldState(
            placeholderText: placeholderText
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
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
            initialState: initialState,
            reducer: reducer,
            keyboardType: keyboardType,
            toolbar: toolbar,
            scheduler: scheduler
        )
    }
    
    /// Creates a view model for general purpose text field.
    static func makeTextField(
        text: String?,
        placeholderText: String,
        keyboardType: KeyboardType,
        limit: Int?,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> RegularFieldViewModel {
        
        let state = TextFieldState.makeTextFieldState(
            text: text,
            placeholderText: placeholderText
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText
        )
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: .image("Close Button"),
            closeButtonAction: {
                UIApplication.shared.endEditing()
            },
            doneButtonLabel: .title("Готово"),
            doneButtonAction: { UIApplication.shared.endEditing() }
        )
        
        return .init(
            initialState: state,
            reducer: reducer,
            keyboardType: keyboardType,
            toolbar: toolbar,
            scheduler: scheduler
        )
    }
    
    /// Creates a view model for phone number input text field.
    /// Uses `PhoneKit` to format and validate input.
    static func makePhoneKitTextField(
        initialPhoneNumber: String?,
        placeholderText: String,
        filterSymbols: [Character],
        countryCodeReplaces: [CountryCodeReplace],
        limit: Int? = 18,
        needCloseButton: Bool = true,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> RegularFieldViewModel {
        
        let initialState = TextFieldState.makeTextFieldState(
            text: initialPhoneNumber,
            placeholderText: placeholderText
        )
        let transformer = Transformers.phoneKit(
            filterSymbols: filterSymbols,
            substitutions: [],
            limit: limit
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
        )
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: needCloseButton ? .image("Close Button") : nil,
            closeButtonAction: { UIApplication.shared.endEditing() },
            doneButtonLabel: .title("Готово"),
            doneButtonAction: { UIApplication.shared.endEditing() }
        )
        
        return .init(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .number,
            toolbar: toolbar,
            scheduler: scheduler
        )
    }
}
