//
//  CreateDraftCollateralLoanApplicationConfig+default.swift
//  Vortex
//
//  Created by Valentin Ozerov on 20.03.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import InputComponent
import OTPInputComponent
import SwiftUI
import TextFieldUI

extension CreateDraftCollateralLoanApplicationConfig {
    
    static let `default` = Self(
        fonts: .init(
            title: .init(textFont: Font.system(size: 14), textColor: .title),
            value: .init(textFont: Font.system(size: 16), textColor: .primary)
        ),
        colors: .init(
            background: .background,
            selected: .red,
            unselected: .secondary
        ),
        layouts: .init(
            iconSize: .init(width: 27, height: 27),
            cornerRadius: 12,
            contentHorizontalSpacing: 12,
            contentVerticalSpacing: 4,
            shimmeringHeight: 150,
            panelHeight: 40,
            paddings: .init(
                stack: .init(
                    top: 10,
                    leading: 15,
                    bottom: 0,
                    trailing: 12
                ),
                contentStack: .init(
                    top: 13,
                    leading: 12,
                    bottom: 13,
                    trailing: 16
                )
            )
        ),
        icons: .init(
            selectedItem: Image(systemName: "record.circle"),
            unselectedItem: Image(systemName: "circle")
        ),
        elements: .init(
            header: .default,
            amount: .default,
            period: .default,
            percent: .default,
            city: .default,
            otp: .default,
            consent: .default,
            button: .default,
            result: .default
        )    )
}

extension CreateDraftCollateralLoanApplicationConfig.Header {
    
    static let `default` = Self(title: "Наименование кредита")
}

extension CreateDraftCollateralLoanApplicationConfig.Amount {
    
    static let `default` = Self(
        title: "Сумма кредита",
        inputComponentConfig: .default
    )
}

extension AmountInputConfig {
    
    static let `default` = Self(
        hint: .init(textFont: .footnote, textColor: .red),
        imageWidth: 24,
        keyboard: .number,
        placeholder: "Введите сумму кредита",
        textField: .init(
            font: .systemFont(ofSize: 16),
            textColor: .primary,
            tintColor: .accentColor,
            backgroundColor: .clear,
            placeholderColor: .clear
        ),
        title: "Сумма кредита",
        titleConfig: .init(textFont: Font.system(size: 14), textColor: .title),
        toolbar: .default,
        warning: .init(textFont: .footnote, textColor: .red)
    )
}

extension AmountToolbarConfig {
    
    static let `default` = Self(
        closeImage: "closeImage",
        doneTitle: "Готово"
    )
}
extension CreateDraftCollateralLoanApplicationConfig.Period {
    
    static let `default` = Self(
        title: "Срок кредита",
        periodConfig: .init(
            chevron: .init(color: .secondary, image: Image(systemName: "chevron.down"), size: 12),
            selector: .init(
                title: .init(
                    text: "Срок кредита",
                    config: .init(textFont: Font.system(size: 14), textColor: .title)
                ),
                search: .init(textFont: Font.system(size: 14), textColor: .primary),
                searchPlaceholder: ""
            )
        )
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Percent {
    
    static let `default` = Self(title: "Процентная ставка")
}

extension CreateDraftCollateralLoanApplicationConfig.City {
    
    static let `default` = Self(
        title: "Город получения кредита",
        cityConfig: .init(
            chevron: .init(color: .secondary, image: Image(systemName: "chevron.down"), size: 12),
            selector: .init(
                title: .init(
                    text: "Город получения кредита",
                    config: .init(textFont: Font.system(size: 14), textColor: .title)
                ),
                search: .init(textFont: Font.system(size: 14), textColor: .primary),
                searchPlaceholder: "Поиск по городам"
            )
        )
    )
}

extension CreateDraftCollateralLoanApplicationConfig.OTP {
    
    static let `default` = Self(
        otpLength: 6,
        smsIcon: .smsImage,
        iconColor: .iconGray,
        timerDuration: 60,
        warningText: .init(textFont: Font.system(size: 14), textColor: .red),
        view: .default
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Consent {
    
    static let `default` = Self(
        checkboxSize: .init(width: 24, height: 24),
        horizontalSpacing: 8,
        images: .init(
            checkOn: Image("Checkbox_active"),
            checkOff: Image("Checkbox_normal")
        ),
        imageColor: .greenIcon,
        textConfig: .init(textFont: Font.system(size: 14), textColor: .title)
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Button {
    
    static let `default` = Self(
        continueTitle: "Продолжить",
        createTitle: "Оформить заявку",
        colors: .init(
            foreground: .white,
            background: .red,
            disabled: .unselected,
            fillBackground: .white
        ),
        font: .init(Font.system(size: 16).bold()),
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 12, leading: 16, bottom: 0, trailing: 15)
        )
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result {

    static let `default` = Self(
        titles: .default,
        icons: .default
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Titles {

    static let `default` = Self(
        productName: "Наименование кредита",
        period: "Срок кредита",
        percent: "Процентная ставка",
        amount: "Сумма кредита",
        collateralType: "Тип залога",
        city: "Город получения кредита"
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Icons {

    static let `default` = Self(
        more: .ic24MoreHorizontal,
        car: .ic24Car,
        home: .ic24Home
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let background: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let shimmering: Self = .init(red: 0.77, green: 0.77, blue: 0.77)
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let unselected: Self = .init(red: 0.92, green: 0.92, blue: 0.92)
    static let greenIcon: Self = .init(red: 0.133, green: 0.757, blue: 0.514)
}

extension CreateDraftCollateralLoanApplicationConfig {
    
    var shimmeringGradient: Gradient { .init(colors: [.shimmering, .clear]) }
}

extension Image {
    
    static var smsImage: Image {
        Image("ic24SmsCode")
    }
}

extension TimedOTPInputViewConfig {
    
    static let `default` = Self(
        otp: .init(
            textFont: .headline,
            textColor: .primary
        ),
        resend: .default,
        timer: .default,
        title: .init(
            text: "Введите код",
            config: .init(
                textFont: .subheadline,
                textColor: .secondary
            )
        )
    )
}

extension TimedOTPInputViewConfig.ResendConfig {
    
    static let `default` = Self(
        text: "Отправить повторно",
        backgroundColor: .white,
        config: .init(
            textFont: .caption,
            textColor: .primary
        )
    )
}

extension TimedOTPInputViewConfig.TimerConfig {
    
    static let `default` = Self(
        backgroundColor: .clear,
        config: .init(
            textFont: .subheadline.bold(),
            textColor: .red
        )
    )
}
