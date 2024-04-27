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
    
    func makeContentView(
        appState: AppState
    ) -> ContentView<RootView> {
        
        .init(
            state: appState.rootState,
            factory: makeContentViewFactory(
                initialMainTabState: appState.tabState,
                initialPaymentsState: appState.paymentsState
            )
        )
    }
}

extension Composer {
    
    typealias MakePaymentsView = (PaymentsState, @escaping (RootActions) -> Void) -> PaymentsView
    
    typealias RootView = RootStateWrapperView<_MainTabView, SpinnerView>
    typealias _MainTabView = MainTabStateWrapperView<MainView, PaymentsView, ChatView>
    
    typealias MainView = MainMockView
    typealias PaymentsView = PaymentsStateWrapperView<_PaymentsDestinationView, PaymentButtonLabel>
    typealias ChatView = ChatMockView
    
    typealias _PaymentsDestinationView = PaymentView<UtilityPrepaymentPickerMockView>
}

private extension Composer {
    
    func makeContentViewFactory(
        initialMainTabState tabState: MainTabState,
        initialPaymentsState paymentsState: PaymentsState
    ) -> ContentViewFactory<RootView> {
        
        .init(
            makeRootView: makeRootView(
                initialMainTabState: tabState,
                initialPaymentsState: paymentsState
            )
        )
    }
    
    func makeRootView(
        initialMainTabState tabState: MainTabState,
        initialPaymentsState paymentsState: PaymentsState
    ) -> (RootState) -> RootView {
        
        return { [self] rootState in
            
            let reducer = RootReducer()
            let viewModel = RootViewModel(
                initialState: rootState,
                reduce: reducer.reduce(_:_:),
                handleEffect: { _,_ in }
            )
            let factory = RootViewFactory(
                makeContent: makeRootContent(
                    initialMainTabState: tabState,
                    initialPaymentsState: paymentsState,
                    spinnerEvent: { viewModel.event(.spinner($0)) }
                ),
                makeSpinner: SpinnerView.init
            )
            
            return .init(viewModel: viewModel, factory: factory)
        }
    }
    
    private func makeRootContent(
        initialMainTabState tab: MainTabState,
        initialPaymentsState paymentsState: PaymentsState,
        spinnerEvent: @escaping (SpinnerEvent) -> Void
    ) -> () -> _MainTabView {
        
        return { [self] in
            
            let reducer = MainTabReducer()
            let viewModel = MainTabViewModel(
                initialState: tab,
                reduce: reducer.reduce(_:_:),
                handleEffect: { _,_ in }
            )
            let factory = MainTabFactory(
                makeMainView: makeMainView(
                    event: {
                        
                        switch $0 {
                        case .chat:
                            viewModel.event(.switchTo(.chat))

                        case .payments:
                            viewModel.event(.switchTo(.payments))
                        }
                    }
                ),
                makePaymentsView: _makePaymentsView(
                    initialState: paymentsState,
                    rootActions: {
                        
                        switch $0 {
                        case let.spinner(spinner):
                            switch spinner {
                            case .hide:
                                spinnerEvent(.hide)
                            case .show:
                                spinnerEvent(.show)
                            }
                            
                        case let .tab(tab):
                            switch tab {
                            case .chat:
                                viewModel.event(.switchTo(.chat))
                            case .main:
                                viewModel.event(.switchTo(.main))
                            }
                        }
                    }
                ),
                makeChatView: makeChatView(
                    goToMain: { viewModel.event(.switchTo(.main)) }
                )
            )
            
            return .init(viewModel: viewModel, factory: factory)
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
    
    private func makeMainView(
        event: @escaping (MainMockView.Event) -> Void
    ) -> () -> MainView {
        
        return {
     
            .init(event: event)
        }
    }
    private func _makePaymentsView(
        initialState: PaymentsState,
        rootActions: @escaping (RootActions) -> Void
    ) -> () -> PaymentsView {
        
        return {
            
            self.makePaymentsView(initialState, rootActions)
        }
    }
}
