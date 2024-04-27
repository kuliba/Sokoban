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
    
    typealias MakePaymentsView = (PaymentsState, @escaping (RootEvent) -> Void) -> PaymentsView
    
    typealias RootView = RootStateWrapperView<_MainTabView, SpinnerView>
    typealias _MainTabView = MainTabStateWrapperView<MainView, PaymentsView, ChatView>
    
    typealias MainView = Text
    typealias PaymentsView = PaymentsStateWrapperView<_PaymentsDestinationView, PaymentButtonLabel>
    typealias ChatView = ChatMockView
    
    typealias _PaymentsDestinationView = PaymentView<UtilityPrepaymentPickerMockView>
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
            makeContent: makeRootContent(rootEvent: viewModel.event(_:)),
            makeSpinner: SpinnerView.init
        )
        
        return .init(viewModel: viewModel, factory: factory)
    }
    
    private func makeRootContent(
        rootEvent: @escaping (RootEvent) -> Void
    ) -> (RootState) -> _MainTabView {
        
        return { [self] rootState in
            
            let reducer = MainTabReducer()
            let viewModel = MainTabViewModel(
                initialState: rootState.tab,
                reduce: reducer.reduce(_:_:),
                handleEffect: { _,_ in }
            )
            let factory = MainTabFactory(
                makeMainView: makeMainView,
                makePaymentsView: _makePaymentsView(
                    initialState: rootState.payments,
                    rootEvent: rootEvent
                ),
                makeChatView: makeChatView(
                    goToMain: { rootEvent(.tab(.switchTo(.main))) }
                )
            )
            
            return .init(viewModel: viewModel, factory: factory)
        }
    }
    
    private func makeMainView(
    ) -> MainView {
        
        Text("Main View")
    }
    
    private func _makePaymentsView(
        initialState: PaymentsState,
        rootEvent: @escaping (RootEvent) -> Void
    ) -> () -> PaymentsView {
        
        return {
            
            self.makePaymentsView(initialState, rootEvent)
        }
    }
    
    private func makeChatView(
        goToMain: @escaping () -> Void
    ) -> () -> ChatView {
        
        return {
            
            ChatMockView(event: {
                
                switch $0 {
                case .goToMain:
                    goToMain()
                }
            })
        }
    }
}
