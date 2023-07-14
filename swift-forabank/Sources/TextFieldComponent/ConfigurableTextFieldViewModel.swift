//
//  ConfigurableTextFieldViewModel.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

public protocol ConfigurableTextFieldViewModel: TextFieldViewModel {
    
    var keyboardType: KeyboardType { get }
    var toolbar: ToolbarViewModel? { get }
}

public extension TextFieldView {
    
    init(
        viewModel: any ConfigurableTextFieldViewModel,
        textFieldConfig: TextFieldConfig
    ) {
        self.init(
            viewModel: viewModel,
            keyboardType: viewModel.keyboardType,
            toolbar: viewModel.toolbar,
            textFieldConfig: textFieldConfig
        )
    }
}
