//
//  PaymentSticker+iVortex.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.02.2025.
//

import PaymentSticker
import SwiftUI

extension PaymentSticker.OperationViewConfiguration {
    
    static let iVortex: Self = .init(
        tipViewConfig: .init(
            titleFont: .textBodyMR14200(),
            titleForeground: .textSecondary,
            backgroundView: .mainColorsGrayLightest
        ), stickerViewConfig: .init(
            rectangleColor: .mainColorsGrayLightest,
            configHeader: .init(
                titleFont: .textH3Sb18240(),
                titleColor: .mainColorsBlack,
                descriptionFont: .textBodySR12160(),
                descriptionColor: .textPlaceholder
            ),
            configOption: .init(
                titleFont: .textBodySR12160(),
                titleColor: .textPlaceholder,
                iconColor: .systemColorActive,
                descriptionFont: .textH4M16240(),
                descriptionColor: .secondary,
                optionFont: .textH4M16240(),
                optionColor: .textSecondary
            )),
        selectViewConfig: .init(
            selectOptionConfig: .init(
                titleFont: .textBodyMR14180(),
                titleForeground: .textPlaceholder,
                placeholderForeground: .textTertiary,
                placeholderFont: .textBodyMR14180()
            ),
            optionsListConfig: .init(
                titleFont: .textH4M16240(),
                titleForeground: .textSecondary
            ),
            optionConfig: .init(
                nameFont: .textH4M16240(),
                nameForeground: .textSecondary
            ),
            textFieldConfig: .init(
                font: .textH4M16240(),
                textColor: .textSecondary,
                tintColor: .textSecondary,
                backgroundColor: .clear,
                placeholderColor: .textTertiary
            )
        ),
        productViewConfig: .init(
            headerTextColor: .textPlaceholder,
            headerTextFont: .textBodyMR14180(),
            textColor: .textSecondary,
            textFont: .textH4M16240(),
            optionConfig: .init(
                numberColor: .textWhite,
                numberFont: .textBodyXsR11140(),
                nameColor: .textWhite.opacity(0.4),
                nameFont: .textBodyXsR11140(),
                balanceColor: .textWhite,
                balanceFont: .textBodyXsSb11140()
            ),
            background: .init(color: .mainColorsGrayLightest)
        ),
        inputViewConfig: .init(
            titleFont: .textBodyMR14180(),
            titleColor: .textPlaceholder,
            iconColor: .iconGray,
            iconName: "ic24SmsCode",
            warningFont: .textBodySR12160(),
            warningColor: .systemColorError,
            textFieldFont: .body,
            textFieldColor: .textSecondary,
            textFieldTintColor: .textSecondary,
            textFieldBackgroundColor: .clear,
            textFieldPlaceholderColor: .textPlaceholder
        ),
        amountViewConfig: .init(
            amountFont: .textH2Sb20282(),
            amountColor: .textWhite,
            buttonTextFont: .buttonMediumM14160(),
            buttonTextColor: .textWhite,
            buttonColor: .mainColorsRed,
            hintFont: .textBodySR12160(),
            hintColor: .textPlaceholder,
            background: .mainColorsBlackMedium
        ),
        resultViewConfiguration: .init(
            colorSuccess: Color.systemColorActive,
            colorWait: Color.systemColorWarning,
            colorFailed: Color.systemColorError,
            titleColor: Color.textSecondary,
            titleFont: .textH3Sb18240(),
            descriptionColor: .textPlaceholder,
            descriptionFont: .textBodyMR14200(),
            amountColor: .textSecondary,
            amountFont: .textH1Sb24322(),
            mainButtonColor: .textWhite,
            mainButtonFont: .textH3Sb18240(),
            mainButtonBackgroundColor: .buttonPrimary
        ),
        continueButtonConfiguration: .init(
            activeColor: .buttonPrimary,
            inActiveColor: .buttonPrimaryDisabled,
            textFont: .textH3Sb18240(),
            textColor: .textWhite
        ),
        spinnerIcon: "ic24LogoVortexWhiteElipse"
    )
}
