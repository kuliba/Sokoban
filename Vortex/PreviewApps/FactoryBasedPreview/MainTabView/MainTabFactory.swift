//
//  MainTabFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct MainTabFactory<MainView, PaymentsView, ChatView>
where MainView: View,
      PaymentsView: View,
      ChatView: View {
    
    let makeMainView: MakeMainView
    let makePaymentsView: MakePaymentsView
    let makeChatView: MakeChatView
}

extension MainTabFactory {
    
    typealias MakeMainView = () -> MainView
    typealias MakePaymentsView = () -> PaymentsView
    typealias MakeChatView = () -> ChatView
}
