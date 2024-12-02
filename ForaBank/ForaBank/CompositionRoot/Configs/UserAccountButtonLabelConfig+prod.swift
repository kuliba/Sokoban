//
//  UserAccountButtonLabelConfig+prod.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.12.2024.
//

extension UserAccountButtonLabelConfig {
    
    static let prod: Self = .init(
        avatar: .init(
            color: .bgIconGrayLightest,
            frame: .init(width: 40, height: 40),
            image: .ic24User
        ),
        logo: .init(
            color: .iconWhite,
            frame: .init(width: 20, height: 20),
            image: .ic12LogoForaColor,
            offset: .init(width: 18, height: -14)
        ),
        name: .init(
            textFont: .textH4R16240(),
            textColor: .textSecondary
        )
    )
}
