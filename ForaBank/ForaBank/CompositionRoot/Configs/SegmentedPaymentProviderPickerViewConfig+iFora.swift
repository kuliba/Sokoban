//
//  SegmentedPaymentProviderPickerViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

extension SegmentedPaymentProviderPickerViewConfig {
    
    static let iFora: Self = .init(
        background: .mainColorsGrayLightest,
        cornerRadius: 12,
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        )
    )
}
