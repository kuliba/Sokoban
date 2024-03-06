//
//  Array+preview.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

extension Array where Element == ItemForList {
    
    static let preview: Self = [
        .single(
            .init(
                id: .payeeName,
                title: "Получатель",
                titleForInformer: "Получатель",
                subtitle: "Константин Войцехов",
                valueForCopy: "valueForCopy"
            )
        ),
        .single(
            .init(
                id: .accountNumber,
                title: "Номер счета",
                titleForInformer: "Номер счета",
                subtitle: "408178810888 005001137",
                valueForCopy: "valueForCopy"
            )
        ),
        .single(
            .init(
                id: .bic,
                title: "БИК",
                titleForInformer: "БИК",
                subtitle: "044525341",
                valueForCopy: "valueForCopy"
            )
        ),
        .single(
            .init(
                id: .corrAccount,
                title: "Кореспондентский счет",
                titleForInformer: "Кореспондентский счет",
                subtitle: "301018103000000000341",
                valueForCopy: "valueForCopy"
            )
        ),
        .multiple(
            [
                .init(
                    id: .inn,
                    title: "ИНН",
                    titleForInformer: "ИНН",
                    subtitle: "7704113772",
                    valueForCopy: "valueForCopy"
                ),
                .init(
                    id: .kpp,
                    title: "КПП",
                    titleForInformer: "КПП",
                    subtitle: "770401001",
                    valueForCopy: "valueForCopy"
                )
            ]
        )
    ]
    
    static let cardItems: Self = [
        .single(
            .init(
                id: .holderName,
                title: "Держатель",
                titleForInformer: "Держатель",
                subtitle: "Константин Войцехов",
                valueForCopy: "valueForCopy"
            )
        ),
        .single(
            .init(
                id: .numberMasked,
                title: "Номер карты",
                titleForInformer: "Номер карты",
                subtitle: "**** **** **** 0500",
                valueForCopy: "valueForCopy"
            )
        ),
        .multiple(
            [
                .init(
                    id: .expirationDate,
                    title: "Карта действует до",
                    titleForInformer: "Срок действия карты",
                    subtitle: "01/01",
                    valueForCopy: "valueForCopy"
                ),
                .init(
                    id: .cvvMasked,
                    title: .cvvTitle,
                    titleForInformer: .cvvTitle,
                    subtitle: "111",
                    valueForCopy: ""
                )
            ]
        )
    ]
}
