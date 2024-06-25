//
//  ComponentsConfigurations.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 23.05.2024.
//

import Foundation
import PaymentComponents
import SwiftUI

extension PaymentComponents.CodeInputConfig {
    
    static let iFora: Self = .init(
        icon: .ic24SmsCode,
        button: .init(active: .inactive, inactive: .inactive),
        digitModel: .init(digitConfig: .secondary, rectColor: .mainColorsWhite),
        resend: .init(backgroundColor: .mainColorsWhite, text: .secondary),
        subtitle: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
        timer: .init(textFont: .textBodyMR14180(), textColor: .textRed),
        title: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)
    )
}

extension PaymentComponents.CheckBoxConfig {
    
    static let iFora: Self = .init(
        title: "",
        titleConfig: .init(textFont: .body, textColor: .black),
        lineWidth: 2,
        strokeColor: .green,
        dashPhase: 70
    )
}

extension PaymentComponents.InputPhoneConfig {
    
    static let iFora: Self = .init(
        icon: .ic24Smartphone,
        iconForeground: .iconGray,
        placeholder: "Номер телефона",
        placeholderConfig: .init(textFont: .textH4M16240(), textColor: .textPlaceholder),
        title: "Номер телефона",
        titleConfig: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
        buttonIcon: .ic24User,
        buttonForeground: .iconGray,
        textFieldConfig: .init(
            font: .textH4M16240(),
            textColor: .textSecondary,
            tintColor: .textSecondary,
            backgroundColor: .clear,
            placeholderColor: .textPlaceholder
        )
    )
}

extension PaymentComponents.InputConfig {
    
    static let iFora: Self = .init(
        titleConfig: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
        textFieldFont: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
        placeholder: "Введите значение",
        hintConfig: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        backgroundColor: .clear,
        imageSize: 24.0
    )
}

extension PaymentComponents.FooterConfig {
    
    static let iForaConfig: Self = .init(
        title: .init(textFont: .textH3M18240(), textColor: .textSecondary),
        description: .init(textFont: .textBodyMR14200(), textColor: .textPlaceholder),
        subtitle: .init(textFont: .textBodyMR14200(), textColor: .textPlaceholder),
        background: .clear,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(
            titleFont: .textH3Sb18240(),
            titleForeground: .textSecondary,
            backgroundColor: .buttonSecondary
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .textH3Sb18240(),
            titleForeground: .textSecondary,
            backgroundColor: .buttonSecondary
        )
    )
}
