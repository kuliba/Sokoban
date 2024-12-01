//
//  UserAccountButtonLabelConfig+prod.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.12.2024.
//

extension UserAccountButtonLabelConfig {
    
    static let prod: Self = .init(
        avatarForegroundColor: .bgIconGrayLightest,
        avatarImage: .ic24User,
        avatarFrame: .init(width: 40, height: 40),
        logo: .ic12LogoForaColor,
        logoFrame: .init(width: 20, height: 20),
        logoForegroundColor: .iconWhite,
        logoOffset: .init(width: 18, height: -14),
        name: .init(
            textFont: .textH4R16240(),
            textColor: .textSecondary
        )
    )
}
