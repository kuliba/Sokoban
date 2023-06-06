//
//  TextFieldSpy.swift
//  
//
//  Created by Igor Malyarov on 04.06.2023.
//

import Combine
import TextFieldDomain

final class TextFieldSpy<Item: Equatable>: TextField {
    
    private(set) var messages = [TextFieldAction<Item>]()
    
    private let textFieldStateSubject = PassthroughSubject<TextFieldState, Never>()
    
    var textFieldStatePublisher: AnyPublisher<TextFieldState, Never> {
        
        textFieldStateSubject.eraseToAnyPublisher()
    }
    
    func send(_ action: TextFieldAction<Item>) {
        
        messages.append(action)
    }
    
    func setState(to state: TextFieldState) {
        
        textFieldStateSubject.send(state)
    }
}
