//
//  Reducer.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

extension TextFieldRegularView.ViewModel {
    
    public struct Reducer {
        
        private let placeholderText: String
        private let transform: (String) -> String
        
        /// Create Text State `Reducer` with transformation.
        ///
        /// Validation, Masking, Length limitation in its simplest form
        /// could be considered as a closure that transforms one String
        /// into another String.
        /// - Parameter placeholderText: Text to set for state case `placeholder`
        /// - Parameter transform: String transformation that encapsulates validation, masking and length limitation. Default is no transformation.
        public init(
            placeholderText: String,
            transform: @escaping (String) -> String = { $0 }
        ) {
            self.placeholderText = placeholderText
            self.transform = transform
        }
    }
}

extension TextFieldRegularView.ViewModel.Reducer {
    
    typealias State = TextFieldRegularView.ViewModel.State
    typealias Action = TextFieldRegularView.ViewModel.Action
    
    func reduce(state: State, action: Action) -> State {
        
        var state = state
        
        switch (state, action) {
        case (.placeholder, .textViewDidBeginEditing):
            state = .focus(text: "", cursorPosition: 0)
            
        case (.placeholder, .textViewDidEndEditing):
            break

        case let (.placeholder, .setTextTo(.some(text))):
            state = .noFocus(text)
            
        case (.placeholder, .setTextTo(.none)):
            break
            
        case (.placeholder, .shouldChangeTextIn):
            break
            
        case let (.noFocus(text), .textViewDidBeginEditing):
            state = .focus(text: text, cursorPosition: text.count)
            
        case (.noFocus, .shouldChangeTextIn):
            break
            
        case (.noFocus, .textViewDidEndEditing):
            break
            
        case (.noFocus, .setTextTo(.none)):
            state = .placeholder(placeholderText)
            
        case let (.noFocus, .setTextTo(.some(text))):
            state = .noFocus(transform(text))
            
        case (.focus, .setTextTo(.none)):
            state = .placeholder(placeholderText)
            
        case let (.focus(text, _), .shouldChangeTextIn(range, replacementText)):
            
            let text = text.shouldChangeTextIn(range: range, with: replacementText)
            let transformed = transform(text)
            let cursorPosition = min(
                range.location + replacementText.count,
                transformed.count
            )
            state = .focus(
                text: transformed,
                cursorPosition: cursorPosition
            )
            
        case let (.focus, .setTextTo(.some(text))):
            
            let text = transform(text)
            state = .focus(
                text: text,
                cursorPosition: text.count
            )
            
        case (.focus, .textViewDidBeginEditing):
            break
            
        case let (.focus(text, _), .textViewDidEndEditing) where text.isEmpty:
            state = .placeholder(placeholderText)
            
        case let (.focus(text, _), .textViewDidEndEditing) where !text.isEmpty:
            state = .noFocus(text)
            
        case (.focus, .textViewDidEndEditing):
            break
        }
        
        return state
    }
}

// MARK: - Ergonomics

extension TextFieldRegularView.ViewModel.Reducer {
    
    init(placeholderText: String, limit: Int?) {
        
        if let limit = limit {
            
            self.init(placeholderText: placeholderText) { String($0.prefix(limit)) }
            
        } else {
            
            self.init(placeholderText: placeholderText)
            
        }
    }
    
    init(placeholderText: String, transformer: Transformer) {
        
        self.init(placeholderText: placeholderText, transform: transformer.transform)
    }
}
