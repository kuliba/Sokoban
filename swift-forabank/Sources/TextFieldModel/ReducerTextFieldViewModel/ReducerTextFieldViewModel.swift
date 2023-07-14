//
//  ReducerTextFieldViewModel.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Combine
import Foundation
import TextFieldDomain
import SwiftUI

public final class ReducerTextFieldViewModel<Toolbar, Keyboard>: ObservableObject {
    
    @Published public private(set) var state: TextFieldState
    
    public let toolbar: Toolbar?
    public let keyboardType: Keyboard
    
    private let reducer: Reducer
    private let setStateSubject = PassthroughSubject<TextFieldState, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        initialState state: TextFieldState,
        reducer: Reducer,
        keyboardType: Keyboard,
        toolbar: Toolbar? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = state
        self.reducer = reducer
        self.keyboardType = keyboardType
        self.toolbar = toolbar
        
        // MARK: pipeline
        
        setStateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension ReducerTextFieldViewModel {
    
    func reduce(_ action: TextFieldAction) {
        
        do {
            let newState = try reducer.reduce(self.state, with: action)
            self.setStateSubject.send(newState)
        } catch {
            // TODO: Log error
            #warning("add error logging")
        }
    }
    
    // MARK: convenience API
    
    func startEditing() {
        
        reduce(.startEditing)
    }
    
    func finishEditing() {
        
        reduce(.finishEditing)
    }
    
    func type(_ replacementText: String, in range: NSRange) {
        
        reduce(.changeText(replacementText, in: range))
    }
    
    func setText(to text: String?) {
        
        reduce(.setTextTo(text))
    }
}
