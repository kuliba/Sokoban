//
//  TextInputValidator.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain

public final class TextInputValidator {
    
    private let hintText: String?
    private let warningText: String
    private let validate: (String) -> Bool
    
    public init(
        hintText: String?,
        warningText: String,
        validate: @escaping (String) -> Bool
    ) {
        self.hintText = hintText
        self.warningText = warningText
        self.validate = validate
    }
}

public extension TextInputValidator {
    
    func validate(
        _ state: TextFieldState
    ) -> TextInputState.Message? {
        
        switch state.text {
        case .none:
            return hintText.map { .hint($0) }
            
        case let .some(text):
            if validate(text) {
                return hintText.map { .hint($0) }
            } else {
                return .warning(warningText)
            }
        }
    }
}
