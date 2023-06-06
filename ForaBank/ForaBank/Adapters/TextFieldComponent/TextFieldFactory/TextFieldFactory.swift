//
//  TextFieldFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation
import TextFieldComponent

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
            doneButtonLabel: .title("Готово")
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
            placeholderText: placeholderText,
            limit: limit
        )
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: .image("Close Button"),
            doneButtonLabel: .title("Готово")
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
            substitutions: countryCodeReplaces.map(\.substitution),
            limit: limit
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
        )
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: needCloseButton ? .image("Close Button") : nil,
            doneButtonLabel: .title("Готово")
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
