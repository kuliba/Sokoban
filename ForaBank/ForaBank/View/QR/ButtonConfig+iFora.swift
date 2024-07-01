//
//  ButtonConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.02.2024.
//

import UIPrimitives

extension ButtonConfig {
    
    static let iForaFooter: Self = .init(
        active: .init(
            backgroundColor: .mainColorsRed,
            text: .init(
                textFont: .textH4R16240(),
                textColor: .textWhite
            )
        ),
        inactive: .init(
            backgroundColor: .mainColorsGrayMedium.opacity(0.1),
            text: .init(
                textFont: .textH4R16240(),
                textColor: .mainColorsWhite.opacity(0.5)
            )
        ),
        buttonHeight: 56
    )
    
    static let iForaMain: Self = .init(
        active: .init(
            backgroundColor: .mainColorsRed,
            text: .init(
                textFont: .textH3Sb18240(),
                textColor: .textWhite
            )
        ),
        inactive: .init(
            backgroundColor: .mainColorsGrayMedium.opacity(0.1),
            text: .init(
                textFont: .textH3Sb18240(),
                textColor: .mainColorsWhite.opacity(0.5)
            )
        ),
        buttonHeight: 56
    )
}
