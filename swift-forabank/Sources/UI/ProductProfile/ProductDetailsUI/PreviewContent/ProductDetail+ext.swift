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
        copyValue: "Получатель Константин Войцехов",
        event: .longPress("copyValue", "for informer")
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        title: "Номер счета",
        subtitle: "408178810888 005001137",
        copyValue: "Номер счета 408178810888 005001137",
        event: .longPress("valueForCopy", "for informer")
    )
    static let bic: Self = .init(
        id: .bic,
        title: "БИК",
        subtitle: "044525341",
        copyValue: "БИК 044525341",
        event: .longPress("valueForCopy", "for informer")
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        title: "Кореспондентский счет",
        subtitle: "301018103000000000341",
        copyValue: "Кореспондентский счет 301018103000000000341",
        event: .longPress("valueForCopy", "for informer")
    )
    static let inn: Self = .init(
        id: .inn,
        title: "ИНН",
        subtitle: "7704113772",
        copyValue: "ИНН 7704113772",
        event: .longPress("valueForCopy", "for informer")
    )
    static let kpp: Self = .init(
        id: .kpp,
        title: "КПП",
        subtitle: "770401001",
        copyValue: "КПП 770401001",
        event: .longPress("valueForCopy", "for informer")
    )
    static let holder: Self = .init(
        id: .holderName,
        title: "Держатель",
        subtitle: "Константин Войцехов",
        copyValue: "Держатель Константин Войцехов",
        event: .longPress("valueForCopy", "for informer")
    )
    static let numberMasked: Self = .init(
        id: .numberMasked,
        title: "Номер карты",
        subtitle: "**** **** **** 0500",
        copyValue: "Номер карты 1111 1111 1111 0500",
        event: .longPress("valueForCopy", "for informer")
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        title: "Карта действует до",
        subtitle: "01/01",
        copyValue: "Карта действует до 01/01",
        event: .longPress("valueForCopy", "for informer")
    )
    static let cvvMasked: Self = .init(
        id: .cvvMasked,
        title: .cvvTitle,
        subtitle: "111",
        copyValue: "",
        event: .longPress("valueForCopy", "for informer")
    )
    static let info: Self = .init(
        id: .info,
        title: .cvvTitle,
        subtitle: "Недоступно",
        copyValue: "",
        event: .iconTap(.info)
    )
}
