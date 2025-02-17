//
//  OtherConfigs.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.05.2024.
//

import OperatorsListComponents
import PrePaymentPicker
import FooterComponent
import SwiftUI
import UtilityServicePrepaymentUI

// MARK: - Static helpers

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterState.Footer {
    
    static let iVortex: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию"
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterState.Failure {
    
    static let iVortex: Self = .init(
        image: .ic24Search,
        description: "Что-то пошло не так.\nПопробуйте позже или воспользуйтесь другим способом оплаты."
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterView.Config {
    
    static let iVortex: Self = .init(
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        ),
        description: .init(
            textFont: .textH4R16240(),
            textColor: .textPlaceholder
        ),
        subtitle: .init(
            textFont: .textBodyMM14200(),
            textColor: .textPlaceholder
        ),
        background: .mainColorsGrayLightest,
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

#warning("move to the call site and make private")
/*private*/ extension LastPaymentLabelConfig {
    
    static let iVortex: Self = .init(
        amount: .init(
            textFont: .textBodySR12160() ,
            textColor: .textRed
        ),
        frameHeight: 80,
        iconSize: 40,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textSecondary
        )
    )
    
    static let primary: Self = .init(
        amount: .init(
            textFont: .textBodySR12160() ,
            textColor: .textRed
        ),
        frameHeight: 96,
        iconSize: 56,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textSecondary
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension OperatorLabelConfig {
    
    static func iVortex(
        chevron: ChevronConfig? = nil,
        height: CGFloat = 46,
        subtitleFont: Font = .textBodyMR14180(),
        spacing: CGFloat = 16
    ) -> Self {
        
        return .init(
            chevron: chevron,
            height: height,
            title: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            ),
            subtitle: .init(
                textFont: subtitleFont,
                textColor: .textPlaceholder
            ),
            spacing: spacing
        )
    }
}

extension OperatorLabelConfig.ChevronConfig {
    
    static let iVortex: Self = .init(
        color: .iconGray,
        icon: .ic24ChevronRight,
        size: .init(width: 40, height: 40)
    )
}
