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
    typealias PaymentsView = PaymentsStateWrapperView<PaymentsDestinationView, PaymentButtonLabel>
    typealias ChatView = Text
}

private extension Composer {
    
    func makeRootView(
        initialState: RootState
    ) -> RootView {
        
        let reducer = RootReducer()
        let viewModel = RootViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        let factory = RootViewFactory(
            makeContent: makeRootContent,
            makeSpinner: SpinnerView.init
        )
        
        return .init(viewModel: viewModel, factory: factory)
    }
    
    private func makeRootContent(
        rootState: RootState,
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> _MainTabView {
        
        let viewModel = MainTabViewModel(
            initialState: rootState.tab,
            reduce: MainTabReducer().reduce(_:_:),
            handleEffect: { _,_ in }
        )
        let factory = MainTabFactory(
            makeMainView: makeMainView,
            makePaymentsView: _makePaymentsView(
                initialState: rootState.payments,
                spinner: spinner
            ),
            makeChatView: makeChatView
        )
        
        return .init(viewModel: viewModel, factory: factory)
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
