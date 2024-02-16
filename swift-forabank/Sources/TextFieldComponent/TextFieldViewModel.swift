//
//  TextFieldViewModel.swift
//  
//
//  Created by Igor Malyarov on 21.05.2023.
//

import TextFieldModel
import TextFieldUI
import SwiftUI

public protocol TextFieldViewModel: ObservableObject {
    
    var textFieldState: Binding<TextFieldState> { get }
    func send(_ action: TextFieldAction) -> Void
}

extension TextFieldView {
    
    public init(
        viewModel: any TextFieldViewModel,
        keyboardType: KeyboardType,
        toolbar: ToolbarViewModel?,
        textFieldConfig: TextFieldConfig
    ) {
        self.init(
            state: viewModel.textFieldState,
            keyboardType: keyboardType.uiKeyboardType,
            toolbar: toolbar,
            send: viewModel.send(_:),
            textFieldConfig: textFieldConfig
        )
    }
}

public extension KeyboardType {
    
    var uiKeyboardType: UIKeyboardType {
        
        switch self {
        case .default:  return .default
        case .number:   return .numberPad
        case .decimal:  return .decimalPad
        }
    }
}
