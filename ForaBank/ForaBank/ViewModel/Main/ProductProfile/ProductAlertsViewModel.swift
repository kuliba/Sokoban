//
//  ProductAlertsViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import Foundation

struct ProductAlertsViewModel {
    
    let title: String
    let blockAlertText: String
    let additionalAlertText: String
    let serviceOnlyMainCard: String
    let serviceOnlyOwnerCard: String
    let transferAdditionalOther: String
    let unblockCard: String
    let serviceOnlyIndividualCard: String
    let disableForCorCard: String
}

extension ProductAlertsViewModel {
    
    static let `default`: Self = .init(
        title: "Информация",
        blockAlertText: "Для просмотра CVV и смены PIN карта должна быть активна.",
        additionalAlertText: "CVV может увидеть только человек,\nна которого выпущена карта.\nЭто мера предосторожности во избежание мошеннических операций.",
        serviceOnlyMainCard: "Эта услуга доступна только для основной карты",
        serviceOnlyOwnerCard: "Данной услугой может воспользоваться человек, на которого выпущена карта",
        transferAdditionalOther: "Переводы  с помощью карты может проводить только человек, на которого выпущена карта.\nДля перевода воспользуйтесь картой, которая выпущена на вас.",
        unblockCard: "Карту можно будет разблокировать в приложении или в колл-центре", 
        serviceOnlyIndividualCard: "Данная операция не доступна для сотрудника/держателя корпоративной карты. Обратитесь к своему работодателю. Пополнение и перевод доступны через «Фора Бизнес».",
        disableForCorCard: "Данная операция не доступна для сотрудника/держателя корпоративной карты.\nОбратитесь к своему работодателю. Пополнение и перевод доступны в приложении «Фора Бизнес»"
    )
}
