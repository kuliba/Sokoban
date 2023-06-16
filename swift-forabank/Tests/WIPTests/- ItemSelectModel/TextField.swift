//
//  TextField.swift
//  
//
//  Created by Igor Malyarov on 03.06.2023.
//

import Combine
import TextFieldDomain

protocol TextField<Item> {
    
    associatedtype Item: Equatable
    
    var textFieldStatePublisher: AnyPublisher<TextFieldState, Never> { get }
    
    func send(_ action: TextFieldAction<Item>)
}

extension TextField {
    
    func itemSelectStatePublisher<Item>(
        _ items: [Item],
        filterKeyPath: KeyPath<Item, String>
    ) -> AnyPublisher<ItemSelectModel<Item>.State, Never> {
        
        textFieldStatePublisher
            .map { state in
                
                switch state {
                case .placeholder:
                    return .collapsed
                    
                case let .noFocus(text):
                    guard let match = items.first(matching: text, keyPath: filterKeyPath)
                    else {
                        return .collapsed
                    }
                    return .selected(match, listState: .collapsed)
                    
                case let .editing(textState):
                    guard let match = items.first(matching: textState.text, keyPath: filterKeyPath)
                    else {
                        return .expanded(items.filtered(with: textState.text, keyPath: filterKeyPath))
                    }
                    
                    return .selected(match, listState: .expanded)
                }
            }
            .eraseToAnyPublisher()
    }
}

enum TextFieldAction<Item: Equatable>: Equatable {
    
    case startEditing, finishEditing
    case select(Item)
}

