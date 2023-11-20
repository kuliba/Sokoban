//
//  SelectViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct SelectViewModel {
    
    public typealias ParameterSelect = Operation.Parameter.Select
    public typealias OptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel.ID
    
    let parameter: ParameterSelect
    let icon: ImageData
    let tapAction: () -> Void
    let select: (OptionID) -> Void
    
    public init(
        parameter: SelectViewModel.ParameterSelect,
        icon: ImageData,
        tapAction: @escaping () -> Void,
        select: @escaping (SelectViewModel.OptionID) -> Void
    ) {
        self.parameter = parameter
        self.icon = icon
        self.tapAction = tapAction
        self.select = select
    }
    
    public enum TapAction {
        
        case chevronButtonTapped
        case openBranch
    }
}

extension SelectViewModel {
    
//    private static func textField() -> TextFieldView {
//
//        let textFieldConfig: TextFieldView.TextFieldConfig = .init(
//            font: .systemFont(ofSize: 19, weight: .regular),
//            textColor: .orange,
//            tintColor: .black,
//            backgroundColor: .clear,
//            placeholderColor: .gray
//        )
//
//        return .init(
//            state: .constant(.placeholder("Выберите значение")),
//            keyboardType: .default,
//            toolbar: nil,
//            send: { _ in },
//            textFieldConfig: textFieldConfig
//        )
//    }
}
