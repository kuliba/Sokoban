//
//  AnywayPaymentViewFactory.swift
//
//
//  Created by Igor Malyarov on 20.04.2024.
//

import Combine
import CombineSchedulers
import Foundation
import SwiftUI
import UIPrimitives

final class AnywayPaymentViewFactory<Icon> {
    
    private let config: AnywayPaymentViewConfig
    private let makeImageSubject: MakeImageSubject
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        config: AnywayPaymentViewConfig,
        makeImageSubject: @escaping MakeImageSubject,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.config = config
        self.makeImageSubject = makeImageSubject
        self.scheduler = scheduler
    }
}

extension AnywayPaymentViewFactory {
    
    func makeAnywayPaymentView() -> MakeAnywayPaymentView {
        
        let factory = AnywayPaymentComponentFactory(
            makeInfoView: makeInfoView,
            makeInputView: makeInputView,
            makeProductPicker: makeProductPicker
        )
        
        return { state, event in
            
            AnywayPaymentView(state: state, event: event, factory: factory)
        }
    }
    
    private func makeInfoView(
        state: Info<Icon>
    ) -> AsyncInfoView {
        
        return .init(
            state: state,
            config: config.infoViewConfig,
            imageView: { [iconView] in iconView(state.icon) }
        )
    }
    
    private func makeInputView(
        state: InputState<Icon>,
        onInput: @escaping (String) -> Void
    ) -> AsyncInputView {
        
        return .init(
            initialState: state,
            onInput: onInput,
            config: config.inputViewConfig,
            iconView: { [iconView] in iconView(state.settings.icon) },
            scheduler: scheduler
        )
    }
    
    private func makeProductPicker(
        product: Product,
        onSelect: @escaping (Product) -> Void
    ) -> ProductPickerStateWrapperView {
        
        return .init(
            selected: product,
            onProductSelect: onSelect,
            config: config.productPickerConfig,
            scheduler: scheduler
        )
    }
    
    private func iconView(
        icon: Icon
    ) -> AsyncImage {
        
        let imageSubject = makeImageSubject(icon)
        
        return .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
}

extension AnywayPaymentViewFactory {
    
    typealias State = AnywayPaymentState<Icon>
    typealias Event = AnywayPaymentEvent
    
    typealias _AnywayPaymentView = AnywayPaymentView<Icon, AsyncInfoView, AsyncInputView, ProductPickerStateWrapperView>
    typealias MakeAnywayPaymentView = (State, @escaping (Event) -> Void) -> _AnywayPaymentView
    
    typealias AsyncImage = UIPrimitives.AsyncImage
    
    typealias AsyncInfoView = InfoView<Icon, AsyncImage>
    typealias AsyncInputView = InputWrapperView<Icon, AsyncImage>
    
    typealias ImageSubject = CurrentValueSubject<Image, Never>
    typealias MakeImageSubject = (Icon) -> ImageSubject
}
