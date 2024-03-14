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
        value: .value("Получатель Константин Войцехов"),
        event: .longPress("copyValue", "for informer")
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        title: "Номер счета",
        value: .value("408178810888 005001137"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let bic: Self = .init(
        id: .bic,
        title: "БИК",
        value: .value("044525341"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        title: "Кореспондентский счет",
        value: .value("301018103000000000341"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let inn: Self = .init(
        id: .inn,
        title: "ИНН",
        value: .value("7704113772"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let kpp: Self = .init(
        id: .kpp,
        title: "КПП",
        value: .value("770401001"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let holder: Self = .init(
        id: .holderName,
        title: "Держатель",
        value: .value("Константин Войцехов"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let number: Self = .init(
        id: .number,
        title: "Номер карты",
        value: .valueWithMask(.init(
            value: "4897 2525 1111 7654",
            maskedValue: "4897 25** **** 7654")),
        event: .longPress("valueForCopy", "for informer")
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        title: "Карта действует до",
        value: .value("01/01"),
        event: .longPress("valueForCopy", "for informer")
    )
    static let cvvMasked: Self = .init(
        id: .cvv,
        title: .cvvTitle,
        value: .valueWithMask(.init(value: "*1*", maskedValue: "***")),
        event: .longPress("valueForCopy", "for informer")
    )
    static let info: Self = .init(
        id: .info,
        title: .cvvTitle,
        value: .value("Недоступно"),
        event: .iconTap(.info)
    )
}
