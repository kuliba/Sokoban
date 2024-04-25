//
//  Composer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

final class Composer {}

extension Composer {
    
    func makeContentViewFactory(
    ) -> ContentViewFactory<RootView> {
        
        .init(makeRootView: makeRootView)
    }
}

extension Composer {
    
    typealias RootView = RootStateWrapperView<_MainTabView, SpinnerView>
    typealias _MainTabView = MainTabStateWrapperView<MainView, PaymentsView, ChatView>
    
    typealias MainView = Text
    typealias PaymentsView = Text
    typealias ChatView = Text
}

private extension Composer {
    
    func makeRootView(
        initialState: RootState = .init()
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
        initialState: MainTabState,
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> _MainTabView {
        
        .init(
            viewModel: .init(
                initialState: initialState,
                reduce: MainTabReducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ),
            factory: makeMainTabFactory()
        )
    }
    
    private func makeMainTabFactory(
    ) -> MainTabFactory<MainView, PaymentsView, ChatView> {
        
        .init(
            makeMainView: { Text("Main View") },
            makePaymentsView: { Text("Payments") },
            makeChatView: { Text("Chat here") }
        )
    }
}
