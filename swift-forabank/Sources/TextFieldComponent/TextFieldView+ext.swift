//
//  TextFieldView+ext.swift
//  
//
//  Created by Igor Malyarov on 21.05.2023.
//

import SwiftUI

extension ReducerTextFieldViewModel: TextFieldViewModel
where Toolbar == ToolbarViewModel,
      Keyboard == KeyboardType {
    
}

extension ReducerTextFieldViewModel: ConfigurableTextFieldViewModel
where Toolbar == ToolbarViewModel,
      Keyboard == KeyboardType {
    
    public var textFieldState: Binding<TextFieldState> {
        .init(
            get: { self.state },
            set: { _ in }
        )
    }
    
    public func send(_ action: TextFieldAction) {
        
        reduce(action)
    }
}
 
extension TextFieldView {
    
    public typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>
    
    #warning("move to the app")
    // MARK: Support Existing API
    @available(*, deprecated, message: "Use `init(viewModel:textFieldConfig:)`")
    public init(
        viewModel: ViewModel,
        font: UIFont = .systemFont(ofSize: 19, weight: .regular),
        backgroundColor: Color = .clear,
        placeholderColor: Color = .gray,
        tintColor: Color = .black,
        textColor: Color
    ) {
        
        self.init(
            viewModel: viewModel,
            textFieldConfig: .init(
                font: font,
                textColor: textColor,
                tintColor: tintColor,
                backgroundColor: backgroundColor,
                placeholderColor: placeholderColor
            )
        )
    }
}
