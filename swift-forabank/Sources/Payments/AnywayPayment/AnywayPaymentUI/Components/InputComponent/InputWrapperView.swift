//
//  InputWrapperView.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import CombineSchedulers
import Foundation
import RxViewModel
import SwiftUI

typealias InputViewModel<Icon> = RxViewModel<InputState<Icon>, InputEvent, InputEffect>

struct InputWrapperView<Icon, IconView: View>: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let config: InputViewConfig
    private let iconView: () -> IconView
    
    init(
        initialState: State,
        onInput: @escaping (String) -> Void,
        config: InputViewConfig,
        iconView: @escaping () -> IconView,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self._viewModel = .init(wrappedValue: .decorated(
            initialState: initialState,
            decorate: { if case let .edit(value) = $0 { onInput(value) }},
            scheduler: scheduler
        ))
        self.config = config
        self.iconView = iconView
    }
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: config,
            iconView: iconView
        )
    }
}

extension InputWrapperView {
    
    typealias ViewModel = InputViewModel<Icon>
    
    typealias State = InputState<Icon>
    typealias Event = InputEvent
}

private extension InputViewModel {
    
    static func decorated<Icon>(
        initialState: InputState<Icon>,
        decorate: @escaping (InputEvent) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> InputViewModel<Icon> {
        
        let reducer = InputReducer<Icon>()
        
        return .init(
            initialState: initialState,
            reduce: { state, event in
                
                decorate(event)
                return reducer.reduce(state, event)
            },
            handleEffect: { _,_ in },
            scheduler: scheduler
        )
    }
}

// MARK: - Previews

struct InputWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InputWrapperView(
            initialState: .preview,
            onInput: { _ in },
            config: .preview,
            iconView: { Text("Icon view") },
            scheduler: .main
        )
    }
}
