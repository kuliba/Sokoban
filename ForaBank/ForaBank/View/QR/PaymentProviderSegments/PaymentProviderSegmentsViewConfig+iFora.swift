//
//  PaymentProviderSegmentsViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

extension PaymentProviderSegmentsViewConfig {
    
    static let iFora: Self = .init(
        background: .mainColorsGrayLightest,
        cornerRadius: 16,
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        )
    )
}
