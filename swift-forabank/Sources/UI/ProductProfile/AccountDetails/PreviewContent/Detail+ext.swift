//
//  Detail+ext.swift
//
//
//  Created by Andryusina Nataly on 09.03.2024.
//

import Foundation

public extension Detail {
    
    static let payee : Self = .init(
        id: .payeeName,
        title: "Получатель",
        informerTitle: "Получатель",
        subtitle: "Константин Войцехов",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        title: "Номер счета",
        informerTitle: "Номер счета",
        subtitle: "408178810888 005001137",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let bic: Self = .init(
        id: .bic,
        title: "БИК",
        informerTitle: "БИК",
        subtitle: "044525341",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        title: "Кореспондентский счет",
        informerTitle: "Кореспондентский счет",
        subtitle: "301018103000000000341",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let inn: Self = .init(
        id: .inn,
        title: "ИНН",
        informerTitle: "ИНН",
        subtitle: "7704113772",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let kpp: Self = .init(
        id: .kpp,
        title: "КПП",
        informerTitle: "КПП",
        subtitle: "770401001",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let holder: Self = .init(
        id: .holderName,
        title: "Держатель",
        informerTitle: "Держатель",
        subtitle: "Константин Войцехов",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let numberMasked: Self = .init(
        id: .numberMasked,
        title: "Номер карты",
        informerTitle: "Номер карты",
        subtitle: "**** **** **** 0500",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        title: "Карта действует до",
        informerTitle: "Срок действия карты",
        subtitle: "01/01",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let cvvMasked: Self = .init(
        id: .cvvMasked,
        title: .cvvTitle,
        informerTitle: .cvvTitle,
        subtitle: "111",
        valueForCopy: "",
        event: .longPress("valueForCopy", "for informer")
    )
}
