//
//  AlertViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 22.02.2022.
//

import Foundation
import SwiftUI
import UIPrimitives

extension Alert.ViewModel {
    
    static func techError(
        message: String = "Возникла техническая ошибка",
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

extension Alert.ViewModel {
    
    static func dataUpdateFailure(
        message: String = .updateInfoText,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

extension Alert.ViewModel {
    
    static func disableForCorporateCard(
        message: String = .disableForCorporateCard,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Информация",
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

extension Alert.ViewModel {
    
    static func needOrderCard(
        title: String = .noCard,
        message: String = .needOrderCard,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primary: .init(
                type: .default,
                title: .cancel,
                action: {}),
            secondary: .init(
                type: .default,
                title: .continue,
                action: primaryAction
            ))
    }
}

extension String {
    
    static let disableForCorporateCard: Self = "Данный функционал не доступен\nдля корпоративных карт.\nОткройте продукт как физ. лицо,\nчтобы использовать все\nвозможности приложения."
    
    static let noCard: Self = "Нет карты"
    static let cancel: Self = "Отмена"
    static let `continue`: Self = "Продолжить"
    static let needOrderCard: Self = "Сначала нужно заказать карту."
}
