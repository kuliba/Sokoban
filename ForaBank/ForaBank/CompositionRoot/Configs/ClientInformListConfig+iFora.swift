//
//  PlainClientInformBottomSheetConfig+iFora.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 14.10.2024.
//

import ClientInformList

extension ClientInformListConfig {
    
    static let iFora: Self = .init(
        colors: .init(
            grayGrabber: .mainColorsGrayMedium,
            grayBackground: .mainColorsGrayLightest
        ),
        strings: .init(
            titlePlaceholder: "Информация"
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
            iconSize: 64,
            rowIconSize: 40,
            navBarHeight: 59,
            navBarMaxWidth: 48,
            grabberWidth: 48,
            grabberHeight: 5,
            grabberCornerRadius: 3,
            spacing: 24
        ),
        paddings: .init(
            topGrabber: 8,
            topImage: 20,
            horizontal: 20,
            vertical: 12
        ),
        image: nil,
        rowImage: nil
    )
}
