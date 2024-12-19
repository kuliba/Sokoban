//
//  PaymentProviderSegmentsViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.07.2024.
//

extension PaymentProviderSegmentsViewConfig {
    
    static let iVortex: Self = .init(
        background: .mainColorsGrayLightest,
        cornerRadius: 12,
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        )
    )
}
