//
//  ButtonStateConfig+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.06.2024.
//

import SharedConfigs

extension ButtonStateConfig {
    
    static let active: Self = .init(
        backgroundColor: .init(hex: "#FF3636"),
        text: .init(
            textFont: .textH4R16240(),
            textColor: .textWhite
        )
    )
    
    static let inactive: Self = .init(
        backgroundColor: .buttonPrimaryDisabled,
        text: .init(
            textFont: .textH4R16240(),
            textColor: .white
        )
    )

    static let tapped: Self = inactive
}
