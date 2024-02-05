//
//  ConsentListState.Expanded.SelectableBank+ext.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

public extension Array where Element == ConsentList.SelectableBank {
    
    static let empty: Self = []
    
    static let preview: Self = ["Сбербанк", "Альфа-банк", "ВТБ", "Тинькофф банк", "Открытие", "Сургутнефтегазбанк"].map {
        
        .init(
            bank: .init(id: .init($0.lowercased()), name: $0),
            isSelected: false
        )
    }
    
    static let many: Self = [Bank].many.map {
        
        .init(bank: $0, isSelected: false)
    }
    
    static var consented: Self {
        
        Self.preview.map {
            
            .init(
                bank: $0.bank,
                isSelected: Consent.preview.contains($0.bank.id)
            )
        }
    }
}
