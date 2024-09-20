//
//  TextInputConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.08.2024.
//

import PaymentComponents
import TextFieldUI

extension TextInputConfig {
    
    static func iFora(
        keyboard: KeyboardType, 
        title: String
    ) -> Self {
        
        return .init(
            hint: .init(
                textFont: .textBodySR12160(),
                textColor: .textPlaceholder
            ),
            imageWidth: 24,
            keyboard: keyboard,
            placeholder: "Введите значение",
            textField: .black16,
            title: title,
            titleConfig: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            ),
            toolbar: .init(
                closeImage: "Close Button",
                doneTitle: "Готово"
            ),
            warning: .init(
                textFont: .textBodySR12160(),
                textColor: .systemColorError
            )
        )
    }
}
