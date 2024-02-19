//
//  ContentView.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import SwiftUI
import OperatorsListComponents

struct ContentView: View {
    
    var body: some View {
        
        ComposedOperatorsView(
            state: .init(operators: [], latestPayments: []),
            event: { _ in },
            lastPaymentView: { _ in EmptyView() },
            operatorView: { _ in EmptyView() },
            footerView: { EmptyView() },
            searchView: { EmptyView() }
        )
    }
}

#Preview {
    ContentView()
}
