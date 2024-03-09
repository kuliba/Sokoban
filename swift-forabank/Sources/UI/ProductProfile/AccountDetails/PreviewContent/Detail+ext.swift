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
        titleForInformer: "Получатель",
        subtitle: "Константин Войцехов",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        title: "Номер счета",
        titleForInformer: "Номер счета",
        subtitle: "408178810888 005001137",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let bic: Self = .init(
        id: .bic,
        title: "БИК",
        titleForInformer: "БИК",
        subtitle: "044525341",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        title: "Кореспондентский счет",
        titleForInformer: "Кореспондентский счет",
        subtitle: "301018103000000000341",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let inn: Self = .init(
        id: .inn,
        title: "ИНН",
        titleForInformer: "ИНН",
        subtitle: "7704113772",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let kpp: Self = .init(
        id: .kpp,
        title: "КПП",
        titleForInformer: "КПП",
        subtitle: "770401001",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let holder: Self = .init(
        id: .holderName,
        title: "Держатель",
        titleForInformer: "Держатель",
        subtitle: "Константин Войцехов",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let numberMasked: Self = .init(
        id: .numberMasked,
        title: "Номер карты",
        titleForInformer: "Номер карты",
        subtitle: "**** **** **** 0500",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        title: "Карта действует до",
        titleForInformer: "Срок действия карты",
        subtitle: "01/01",
        valueForCopy: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let cvvMasked: Self = .init(
        id: .cvvMasked,
        title: .cvvTitle,
        titleForInformer: .cvvTitle,
        subtitle: "111",
        valueForCopy: "",
        event: .longPress("valueForCopy", "for informer")
    )
}
