//
//  [Bank]+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import FastPaymentsSettings

public extension Array where Element == Bank {
    
    static let preview: Self = ["Сбербанк", "Альфа-банк", "ВТБ", "Тинькофф банк", "Открытие", "Сургутнефтегазбанк"].map {
        
        .init(id: .init($0.lowercased()), name: $0)
    }
}
