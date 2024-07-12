//
//  ReducerTextFieldViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.07.2024.
//

import Foundation
import TextFieldDomain
import TextFieldComponent
import Combine

extension ReducerTextFieldViewModel {
    
    var text: String? { state.text }
    
    func textPublisher(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> AnyPublisher<String?, Never> {
        
        $state
            .map(\.text)
            .eraseToAnyPublisher()
    }
    
    func isEditing(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> AnyPublisher<Bool, Never> {
        
        $state
            .map(\.isEditing)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Support existing API
    
    var hasValue: Bool { text != "" && text != nil }
}

extension TextFieldState {
    
    var isEditing: Bool {
        
        switch self {
        case .placeholder, .noFocus:
            return false
            
        case .editing:
            return true
        }
    }
    
    var text: String? {
        
        switch self {
        case .placeholder:
            return nil
            
        case let .noFocus(text):
            return text
            
        case let .editing(state):
            return state.text
        }
    }
}
