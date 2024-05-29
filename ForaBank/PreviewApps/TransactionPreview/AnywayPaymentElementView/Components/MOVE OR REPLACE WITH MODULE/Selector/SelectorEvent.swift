//
//  SelectorEvent.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

enum SelectorEvent<T> {
    
    case toggleOptions
    case selectOption(T)
    case setSearchQuery(String)
}
