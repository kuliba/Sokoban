//
//  StatefulButtonConfig+iVortex.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.02.2025.
//

import PaymentComponents

extension StatefulButtonConfig {
    
    static func iVortex(
        title: String = "На главный"
    ) -> Self {
        
        .init(
            active: .active(title: title),
            inactive: .inactive(title: title)
        )
    }
}

private extension _ButtonStateConfig {
    
    static func active(title: String) -> Self {
        
        .init(
            backgroundColor: .mainColorsRed,
            title: .init(
                text: title,
                config: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textWhite
                )
            )
        )
    }
    
    static func inactive(title: String) -> Self {
        
        .init(
            backgroundColor: .mainColorsGrayMedium,
            title: .init(
                text: title,
                config: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .mainColorsWhite
                )
            )
        )
    }
}

