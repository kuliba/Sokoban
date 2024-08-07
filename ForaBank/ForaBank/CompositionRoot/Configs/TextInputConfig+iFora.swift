//
//  TextInputConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.08.2024.
//

import PaymentComponents

extension TextInputConfig {
    
    static let iFora: Self = .init(
        hint: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        imageWidth: 24,
        textField: .black16,
        title: .init(
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
