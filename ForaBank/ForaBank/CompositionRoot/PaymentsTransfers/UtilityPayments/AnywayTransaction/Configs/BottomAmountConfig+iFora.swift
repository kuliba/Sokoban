//
//  BottomAmountConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.06.2024.
//

import AmountComponent

extension BottomAmountConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .white
        ),
        amountFont: .boldSystemFont(ofSize: 24),
        backgroundColor: .mainColorsBlackMedium,
        button: .iFora,
        buttonSize: .init(width: 114, height: 40),
        dividerColor: .bordersDivider,
        title: "Продолжить",
        titleConfig: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}
