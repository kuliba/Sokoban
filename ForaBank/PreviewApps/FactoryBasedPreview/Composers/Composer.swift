//
//  Composer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

final class Composer {
    
    private let makePaymentsView: MakePaymentsView
    
    init(
        makePaymentsView: @escaping MakePaymentsView
    ) {
        self.makePaymentsView = makePaymentsView
    }
}

extension Composer {
    
    func makeContentViewFactory(
    ) -> ContentViewFactory<RootView> {
        
        .init(makeRootView: makeRootView)
    }
}

extension Composer {
    
    typealias MakePaymentsView = (PaymentsState, @escaping (SpinnerEvent) -> Void) -> PaymentsView
    
    typealias RootView = RootStateWrapperView<_MainTabView, SpinnerView>
    typealias _MainTabView = MainTabStateWrapperView<MainView, PaymentsView, ChatView>
    
    typealias MainView = Text
    typealias PaymentsView = PaymentsStateWrapperView
    typealias ChatView = Text
}

private extension Composer {
    
    func makeRootView(
        initialState: RootState
    ) -> RootView {
        
        let viewModel = RootViewModel(
            initialState: initialState,
            reduce: RootReducer().reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        return .init(
            viewModel: viewModel,
            factory: makeRootViewFactory()
        )
    }
    
    private func makeRootViewFactory(
    ) -> RootViewFactory<_MainTabView, SpinnerView> {
        
        .init(
            makeContent: makeRootContent,
            makeSpinner: SpinnerView.init
        )
    }
    
    private func makeRootContent(
        rootState: RootState,
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> _MainTabView {
        
        .init(
            viewModel: .init(
                initialState: rootState.tab,
                reduce: MainTabReducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ),
            factory: .init(
                makeMainView: makeMainView,
                makePaymentsView: _makePaymentsView(
                    initialState: rootState.payments,
                    spinner: spinner
                ),
                makeChatView: makeChatView
            )
        )
    }
    
    private func makeMainView(
    ) -> MainView {
        
        Text("Main View")
    }
    
    private func _makePaymentsView(
        initialState: PaymentsState,
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> () -> PaymentsView {
        
        return {
            
            self.makePaymentsView(initialState, spinner)
        }
    }
    
    private func makeChatView(
    ) -> MainView {
        
        Text("Chat here")
    }
}
