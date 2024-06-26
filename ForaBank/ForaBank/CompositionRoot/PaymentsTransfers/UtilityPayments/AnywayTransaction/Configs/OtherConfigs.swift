//
//  OtherConfigs.swift
//  ForaBank
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
    
    static let iFora: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию"
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterState.Failure {
    
    static let iFora: Self = .init(
        image: .ic24Search,
        description: "Что-то пошло не так.\nПопробуйте позже или воспользуйтесь другим способом оплаты.."
    )
}

#warning("move to the call site and make private")
/*private*/ extension FooterComponent.FooterView.Config {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .body,
            textColor: .black
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
            titleFont: .body,
            titleForeground: .textSecondary,
            backgroundColor: .buttonSecondary
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .textSecondary,
            backgroundColor: .buttonSecondary
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension LastPaymentLabelConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textBodySR12160() ,
            textColor: .textRed
        ),
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textSecondary
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension OperatorLabelConfig {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        ),
        subtitle: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        )
    )
}
