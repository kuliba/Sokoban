//
//  ReducerTextFieldViewModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.05.2023.
//

import Combine
import TextFieldComponent

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
