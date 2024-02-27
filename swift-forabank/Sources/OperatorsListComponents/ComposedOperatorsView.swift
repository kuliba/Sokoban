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
        
        ScrollView(.vertical, showsIndicators: false) {
            
            searchView()
            
            LazyVStack(spacing: 16) {
                
                if let latestPayments = state.latestPayments {
                    
                    ScrollView(.horizontal) {
                        
                        LazyHStack {
                            
                            ForEach(latestPayments, content: lastPaymentView)
                        }
                    }
                }
                
                if let operators = state.operators {
                    
                    LazyVStack(alignment: .leading, spacing: 8) {
                        
                        ForEach(operators, content: _operatorView)
                    }
                }
                
                footerView()
                    .onAppear { 
                        
                        event(.utility(.initiate))
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

extension ComposedOperatorsView {
    
    private func lastPaymentView(
        latestPayment: LatestPayment,
        latestPaymentConfigView: LatestPayment.LatestPaymentConfig
    ) -> some View {
        
        Button {
            
            event(.selectLastOperation(latestPayment.id))
            
        } label: {
            
            VStack {
             
                if let image = latestPayment.image {
                    
                    image
                        .resizable()
                        .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                } else {
                    
                    Image.defaultIcon(
                        backgroundColor: latestPaymentConfigView.backgroundColor,
                        icon: latestPaymentConfigView.defaultImage
                    )
                }
                
                VStack(spacing: 8) {

                    Text(latestPayment.title)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        
                        Text(latestPayment.amount)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                }
            }
            .frame(width: 80, height: 80, alignment: .center)
        }
        .contentShape(Rectangle())
    }
    
    public func operatorView(
        _ operator: Operator
    ) -> some View {
        
        Button {
            event(.selectOperator(`operator`.id))
        } label: {
            
            HStack {
             
                `operator`.image
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                VStack(spacing: 8) {

                    Text(`operator`.title)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .lineLimit(1)
                    
                    if let subtitle = `operator`.subtitle {
                        
                        Text(subtitle)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
            .frame(height: 56)
        }
        .contentShape(Rectangle())
    }
}

extension ComposedOperatorsView {
    
    public struct Configuration {
        
        let noCompanyListConfiguration: NoCompanyInListViewConfig
        
        public init(
            noCompanyListConfiguration: NoCompanyInListViewConfig
        ) {
            self.noCompanyListConfiguration = noCompanyListConfiguration
        }
    }
}

public struct Operator: Equatable, Identifiable {
    
    public var id: String
    let title: String
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
