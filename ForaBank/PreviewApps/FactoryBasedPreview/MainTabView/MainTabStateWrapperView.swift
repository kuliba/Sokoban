//
//  MainTabStateWrapperView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import RxViewModel
import SwiftUI

typealias MainTabViewModel = RxViewModel<MainTabState, MainTabEvent, Never>

struct MainTabStateWrapperView<MainView, PaymentsView, ChatView>: View
where MainView: View,
      PaymentsView: View,
      ChatView: View {
    
    @StateObject private var viewModel: MainTabViewModel
    
    private let factory: Factory
    
    init(
        viewModel: MainTabViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        MainTabView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory
        )
    }
}

extension MainTabStateWrapperView {
    
    typealias Factory = MainTabFactory<MainView, PaymentsView, ChatView>
}

struct MainTabStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview(.chat)
    }
    
    static func preview(
        _ initialState: MainTabState
    ) -> some View {
        
        MainTabStateWrapperView(
            viewModel: .init(
                initialState: initialState,
                reduce: MainTabReducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ),
            factory: makeFactory()
        )
    }
    
    private static func makeFactory(
    ) -> MainTabFactory<Text, Text, Text> {
        
        .init(
            makeMainView: { Text("Main View") },
            makePaymentsView: { Text("Payments") },
            makeChatView: { Text("Chat here") }
        )
    }
}
