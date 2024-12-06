//
//  PlainClientInformBottomSheetConfig+iFora.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 14.10.2024.
//

import ClientInformList

extension ClientInformListConfig {
    
    static let iFora: Self = .init(
        colors: .init(
            bgIconRedLight: .bgIconRedLight
        ),
        strings: .init(
            titlePlaceholder: "Информация",
            foraBankLink: "https://www.forabank.ru"
        ),
        titleConfig: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        ),
        textConfig: .init(
            textFont: .textBodyMR14200(),
            textColor: .textSecondary
        ),
        sizes: .init(
            iconSize: 40,
            iconBackgroundSize: 64,
            rowIconSize: 40,
            navBarHeight: 59,
            navBarMaxWidth: 48,
            spacing: 24, 
            bigSpacing: 32
        ),
        paddings: .init(
            topImage: 20,
            horizontal: 20,
            vertical: 12,
            bottom: 80
        ),
        image: .ic24Info
    )
}
