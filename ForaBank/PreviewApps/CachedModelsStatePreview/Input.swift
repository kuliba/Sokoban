//
//  Input.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import Foundation
import RxViewModel

typealias InputViewModel = RxObservingViewModel<InputState, InputEvent, InputEffect>

// MARK: - Input Domain

struct InputState: Equatable {
    
    let title: String
    var text: String
}

enum InputEvent: Equatable {
    
    case setTo(String)
    case typed(String)
}

enum InputEffect: Equatable {
    
    case debounce(String)
}

// MARK: - InputReducer

final class InputReducer {}

extension InputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .setTo(text):
            state.text = text
            
        case let .typed(text):
            effect = .debounce(text)
        }
        
        return (state, effect)
    }
}

extension InputReducer {
    
    typealias State = InputState
    typealias Event = InputEvent
    typealias Effect = InputEffect
}

// MARK: - InputEffectHandler

final class InputEffectHandler {}

extension InputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .debounce(text):
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.3
            ) {
                dispatch(.setTo(text))
            }
        }
    }
}

extension InputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = InputEvent
    typealias Effect = InputEffect
}

// MARK: - InputWrapperView

import SwiftUI

struct InputWrapperView: View {
    
    @StateObject private var viewModel: InputViewModel
    
    init(viewModel: InputViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
       
        InputView(state: viewModel.state, event: viewModel.event(_:))
    }
}

struct InputView: View {
    
    let state: InputState
    let event: (InputEvent) -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(state.title)
                .foregroundColor(.secondary)
                .font(.caption.bold())
            
            TextField(
                state.title,
                text: .init(
                    get: { state.text },
                    set: { event(.typed($0)) }
                )
            )
        }
    }
}
