//
//  TextFieldRegularViewModel.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Combine
import CombineSchedulers
import Foundation
import SwiftUI

extension TextFieldRegularView {
    
    public final class ViewModel: ObservableObject {
        
        @Published public private(set) var state: State
        
        let toolbar: ToolbarViewModel
        let keyboardType: KeyboardType
        
        private let reducer: Reducer
        private let setStateSubject = PassthroughSubject<State, Never>()
        private var cancellables = Set<AnyCancellable>()
        
        // MARK: - Support Existing API
        
        @available(*, deprecated, message: "Use `$state`")
        @Published public private(set) var text: String?
        @available(*, deprecated, message: "Use `$state`")
        @Published public private(set) var isEditing: Bool
        
        init(
            state: State,
            keyboardType: KeyboardType,
            reducer: Reducer,
            needCloseButton: Bool,
            scheduler: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.state = state
            self.keyboardType = keyboardType
            self.reducer = reducer
            
            let closeButton: ToolbarViewModel.ButtonViewModel = .init(
                isEnabled: true,
                action: {  UIApplication.shared.endEditing() }
            )
            self.toolbar = .init(
                doneButton: .init(
                    isEnabled: true,
                    action: {  UIApplication.shared.endEditing() }
                ),
                closeButton: needCloseButton ? closeButton : nil
            )
            
            // MARK: Support Existing API
            
            self.text = state.text
            self.isEditing = state.isEditing
            
            // MARK: pipeline
            
            setStateSubject
                .removeDuplicates()
                .receive(on: scheduler)
                .assign(to: &$state)
            
            // MARK: Support Existing API
            
            // TODO: Remove after clients updated to use `state`
            $state
                .map(\.text)
                .removeDuplicates()
                .receive(on: scheduler)
                .assign(to: &$text)
            
            // TODO: Remove after clients updated to use `state`
            $state
                .map(\.isEditing)
                .removeDuplicates()
                .receive(on: scheduler)
                .assign(to: &$isEditing)
        }
    }
}

private extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: Support Existing API

extension TextFieldRegularView.ViewModel {
    
    public convenience init(
        text: String? = nil,
        cursorPosition: Int? = nil,
        placeholder: String,
        keyboardType: KeyboardType,
        limit: Int? = nil,
        needCloseButton: Bool = false,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        let state = State(text: text, cursorPosition: cursorPosition, placeholderText: placeholder)
        let reducer = Reducer(placeholderText: placeholder, limit: limit)
        
        self.init(
            state: state,
            keyboardType: keyboardType,
            reducer: reducer,
            needCloseButton: needCloseButton,
            scheduler: scheduler
        )
    }
}

public extension TextFieldRegularView.ViewModel {
    
    func setText(to text: String?) {
        
        reduce(.setTextTo(text))
    }
    
    var hasValue: Bool { text != "" && text != nil }
    
    func textViewDidBeginEditing() {
        
        reduce(.textViewDidBeginEditing)
    }
    
    func textViewDidEndEditing() {
        
        reduce(.textViewDidEndEditing)
    }
    
    func shouldChangeTextIn(range: NSRange, replacementText: String) {
        
        reduce(.shouldChangeTextIn(range, replacementText))
    }
}

private extension TextFieldRegularView.ViewModel {
    
    func reduce(_ action: Action) {
        
        let newState = reducer.reduce(state: self.state, action: action)
        self.setStateSubject.send(newState)
    }
}
