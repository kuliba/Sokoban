//
//  LastPayments+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import OperatorsListComponents

extension Array where Element == LatestPayment {
    
    static let preview: Self = [
        .init(
            image: nil,
            title: "ЖКУ Москвы (ЕИРЦ)",
            amount: "100 ₽"
        ),
        .init(
            image: nil,
            title: "МОСОБЛГАЗ",
            amount: "1 780 ₽"
        ),
        .init(
            image: nil,
            title: "ЖКУ Краснодара",
            amount: "1 680 ₽"
        )
    ]
}
