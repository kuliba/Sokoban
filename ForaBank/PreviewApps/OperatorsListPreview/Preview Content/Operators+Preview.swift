//
//  Operators+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import OperatorsListComponents

extension Array where Element == Operator {
    
    static func initial(count: Int = 10) -> Self {
        .init(Self.preview.prefix(count))
    }
    
    static func next1(count: Int = 10) -> Self {
        .init(Self.preview.dropFirst(count).prefix(count))
    }
    
    static let preview: Self = [
        .init(
            id: "1",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "2",
            title: "МОСОБЛГАЗ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "3",
            title: "ПИК-Комфорт",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "4",
            title: "ЖКУ Краснодара",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "5",
            title: "ГАЗПРОМ МЕЖРЕГИОН ГАЗ ЯРОСЛАВЛЬ",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "6",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "7",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "8",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "9",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "10",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        ),
        .init(
            id: "11",
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            image: .init(systemName: "photo.artframe"),
            action: { _ in }
        )
    ]
}
