//
//  BottomAmountConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.06.2024.
//

import AmountComponent

extension BottomAmountConfig {
    
    static let iVortex: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .white
        ),
        amountFont: .boldSystemFont(ofSize: 24),
        backgroundColor: .mainColorsBlackMedium,
        button: .iVortex,
        buttonSize: .init(width: 114, height: 40),
        dividerColor: .bordersDivider,
        title: "Сумма платежа",
        titleConfig: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ), heightOfElements: .init(
            titleHeight: 16,
            textFieldHeight: 24
        )
    )
}
