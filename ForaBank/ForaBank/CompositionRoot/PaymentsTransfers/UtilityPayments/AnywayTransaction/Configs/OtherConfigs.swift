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
        image: .init(systemName: "photo.artframe"),
        description: "Что-то пошло не так.\nПопробуйте позже."
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
            textFont: .footnote,
            textColor: .gray.opacity(0.3)
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .gray.opacity(0.3)
        ),
        background: .gray,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(
            titleFont: .body,
            titleForeground: .white,
            backgroundColor: .blue
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .white,
            backgroundColor: .green
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension LastPaymentLabelConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .caption2,
            textColor: .red
        ),
        title: .init(
            textFont: .caption2,
            textColor: .gray
        )
    )
}

#warning("move to the call site and make private")
/*private*/ extension OperatorLabelConfig {
    
    static let iFora: Self = .init(
        title: .init(
            textFont: .headline,
            textColor: .black
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: .gray
        )
    )
}
