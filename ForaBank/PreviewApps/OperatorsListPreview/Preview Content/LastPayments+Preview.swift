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
            image: .init(systemName: "photo.artframe"),
            title: "ЖКУ Москвы (ЕИРЦ)",
            amount: "100 ₽"
        ),
        .init(
            image: .init(systemName: "photo.artframe"),
            title: "МОСОБЛГАЗ",
            amount: "1 780 ₽"
        ),
        .init(
            image: .init(systemName: "photo.artframe"),
            title: "ЖКУ Краснодара",
            amount: "1 680 ₽"
        )
    ]
}
