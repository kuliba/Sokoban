//
//  CategoryPickerSectionContentViewConfig+iFora.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI

extension CategoryPickerSectionContentViewConfig {
    
    static let iFora: Self = .init(
        failure: .init(
            imageConfig: .init(
                color: .iconGray,
                image: .ic24Search,
                backgroundColor: .mainColorsGrayLightest,
                backgroundSize: .init(width: 64, height: 64),
                size: .init(width: 24, height: 24)
            ),
            spacing: 24,
            textConfig: .init(
                text: "Мы не смогли загрузить данные.\nПопробуйте позже.",
                alignment: .center,
                config: .secondary
            )
        ),
        headerHeight: 24,
        spacing: 16,
        title: .init(
            text: "Оплатить",
            config: .init(
                textFont: .textH2Sb20282(),
                textColor: .textSecondary
            ),
            leadingPadding: 20
        ),
        titlePlaceholder: .init(
            color: .gray.opacity(0.5),
            radius: 12,
            size: .init(width: 148, height: 18)
        )
    )
}
