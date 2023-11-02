//
//  SelectViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI


struct SelectViewModel {
    
    typealias Parameter = Operation.Parameter.Select
    typealias OptionID = Parameter.State.OptionsListViewModel.OptionViewModel.ID
    
    let parameter: Parameter
    let chevronButtonTapped: () -> Void
    let select: (OptionID) -> Void
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
