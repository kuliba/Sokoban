//
//  SelectViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct SelectViewModel {
    
    public typealias Parameter = Operation.Parameter.Select
    public typealias OptionID = Parameter.State.OptionsListViewModel.OptionViewModel.ID
    
    let parameter: Parameter
    let icon: Image
    let tapAction: TapAction
    let select: (OptionID) -> Void
    
    public init(
        parameter: SelectViewModel.Parameter,
        icon: Image,
        tapAction: TapAction,
        select: @escaping (SelectViewModel.OptionID) -> Void
    ) {
        self.parameter = parameter
        self.icon = icon
        self.tapAction = tapAction
        self.select = select
    }
    
    public enum TapAction {
        
        case chevronButtonTapped(() -> Void)
        case openBranch(() -> Void)
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
