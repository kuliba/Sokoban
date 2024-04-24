//
//  MainTabView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct MainTabView<MainView, PaymentsView, ChatView>: View
where MainView: View,
      PaymentsView: View,
      ChatView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        TabView(
            selection: .init(
                get: { state },
                set: { event(.switchTo($0)) }
            )
        ) {
            navWrapped(factory.makeMainView, "Main", .main)
            navWrapped(factory.makePaymentsView, "Payments", .payments)
            navWrapped(factory.makeChatView, "Chat", .chat)
        }
    }
    
    private func navWrapped(
        _ content: @escaping () -> some View,
        _ title: String,
        _ tab: State
    ) -> some View {
        
        NavigationView(content: content)
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem { Text(title) }
            .tag(tab)
    }
}

extension MainTabView {
    
    typealias State = MainTabState
    typealias Event = MainTabEvent
    
    typealias Factory = MainTabFactory<MainView, PaymentsView, ChatView>
}

struct MainTabView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainTabView(
            state: .chat,
            event: { _ in },
            factory: .init(
                makeMainView: { Text("Main View") },
                makePaymentsView: { Text("Payments") },
                makeChatView: { Text("Chat here") }
            )
        )
    }
}
