//
//  Operators+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import OperatorsListComponents

extension Array where Element == Operator {
    
    static func initial(count: Int = 20) -> Self {
        .init(Self.preview.prefix(count))
    }
    
    static func next1(count: Int = 20) -> Self {
        .init(Self.preview.dropFirst(count).prefix(count))
    }
    
    static let preview: Self = [
        .init(
            id: "1",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "2",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "3",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "4",
            title: "ЖКУ Краснодара",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "5",
            title: "ГАЗПРОМ МЕЖРЕГИОН ГАЗ ЯРОСЛАВЛЬ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "6",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "7",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "8",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "9",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "10",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "11",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "12",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "13",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "14",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "15",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "16",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "17",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "18",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "19",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "20",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "21",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "22",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "23",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "24",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "25",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "26",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "27",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "21",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        ),
        .init(
            id: "28",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe")
        )
    ]
}
