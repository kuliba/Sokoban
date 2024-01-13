//
//  ConsentListState.Expanded.SelectableBank+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

extension Array where Element == ConsentListState.Expanded.SelectableBank {
    
    static let empty: Self = []
    
    static let preview: Self = ["Сбербанк", "Альфа-банк", "ВТБ", "Тинькофф банк", "Открытие", "Сургутнефтегазбанк"].map {
        
        .init(
            bank: .init(id: .init($0.lowercased()), name: $0),
            isSelected: false
        )
    }
}
