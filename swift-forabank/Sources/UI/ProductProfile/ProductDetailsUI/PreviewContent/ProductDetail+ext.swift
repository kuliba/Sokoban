//
//  ProductDetail+ext.swift
//
//
//  Created by Andryusina Nataly on 09.03.2024.
//

import Foundation

public extension ProductDetail {
    
    static let payee : Self = .init(
        id: .payeeName,
        title: "Получатель",
        subtitle: "Константин Войцехов",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        title: "Номер счета",
        subtitle: "408178810888 005001137",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let bic: Self = .init(
        id: .bic,
        title: "БИК",
        subtitle: "044525341",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        title: "Кореспондентский счет",
        subtitle: "301018103000000000341",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let inn: Self = .init(
        id: .inn,
        title: "ИНН",
        subtitle: "7704113772",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let kpp: Self = .init(
        id: .kpp,
        title: "КПП",
        subtitle: "770401001",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let holder: Self = .init(
        id: .holderName,
        title: "Держатель",
        subtitle: "Константин Войцехов",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let numberMasked: Self = .init(
        id: .numberMasked,
        title: "Номер карты",
        subtitle: "**** **** **** 0500",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        title: "Карта действует до",
        subtitle: "01/01",
        copyValue: "valueForCopy",
        event: .longPress("valueForCopy", "for informer")
    )
    static let cvvMasked: Self = .init(
        id: .cvvMasked,
        title: .cvvTitle,
        subtitle: "111",
        copyValue: "",
        event: .longPress("valueForCopy", "for informer")
    )
}
