//
//  ComposedOperatorsView.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI

public struct ComposedOperatorsView<
    SearchView: View,
    LastPaymentView: View,
    OperatorView: View,
    FooterView: View>: View {
    
    let state: ComposedOperatorsState
    let event: (ComposedOperatorsEvent) -> Void
    
    let lastPaymentView: (LatestPayment) -> LastPaymentView
    let operatorView: (Operator) -> OperatorView
    let footerView: () -> FooterView
    let searchView: () -> SearchView
    
    public init(
        state: ComposedOperatorsState,
        event: @escaping (ComposedOperatorsEvent) -> Void,
        lastPaymentView: @escaping (LatestPayment) -> LastPaymentView,
        operatorView: @escaping (Operator) -> OperatorView,
        footerView: @escaping () -> FooterView,
        searchView: @escaping () -> SearchView
    ) {
        self.state = state
        self.event = event
        self.lastPaymentView = lastPaymentView
        self.operatorView = operatorView
        self.footerView = footerView
        self.searchView = searchView
    }
    
    public var body: some View {
        
        VStack(spacing: 16) {
            
            searchView()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    if let latestPayments = state.latestPayments,
                        !latestPayments.isEmpty {
                        
                        ScrollView(.horizontal) {
                            
                            LazyHStack {
                                
                                ForEach(latestPayments, content: lastPaymentView)
                            }
                        }
                    }
                    
                    if let operators = state.operators,
                       !operators.isEmpty {
                        
                        LazyVStack(alignment: .leading, spacing: 8) {
                            
                            ForEach(operators, content: _operatorView)
                        }
                    }
                    
                    footerView()
                        .onAppear { event(.utility(.initiate)) }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    private func _operatorView(
        operator: Operator
    ) -> some View {
        
        operatorView(`operator`)
            .onAppear { event(.utility(.didScrollTo(`operator`.id))) }
    }
}

public struct Operator: Equatable, Identifiable {
    
    public var id: String
    public let title: String
    let subtitle: String?
    let image: Image?
    
    public init(
        id: String,
        title: String,
        subtitle: String?,
        image: Image?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    public init(
        _operatorGroup: _OperatorGroup
    ) {
        
        self.id = _operatorGroup.id
        self.title = _operatorGroup.title
        self.subtitle = _operatorGroup.description
        self.image = nil
    }
}

public struct LatestPayment: Equatable, Identifiable {
    
    public var id: String { title }
    let image: Image?
    let title: String
    let amount: String
    
    public init(
        image: Image?,
        title: String,
        amount: String
    ) {
        self.image = image
        self.title = title
        self.amount = amount
    }
    
    public struct LatestPaymentConfig {
        
        let defaultImage: Image
        let backgroundColor: Color
        
        public init(
            defaultImage: Image,
            backgroundColor: Color
        ) {
            self.defaultImage = defaultImage
            self.backgroundColor = backgroundColor
        }
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        ComposedOperatorsView(
            state: .init(operators: [], latestPayments: []),
            event: { _ in },
            lastPaymentView: { _ in  EmptyView() },
            operatorView: { _ in  EmptyView() },
            footerView: { EmptyView() },
            searchView: { EmptyView() }
        )
    }
}
