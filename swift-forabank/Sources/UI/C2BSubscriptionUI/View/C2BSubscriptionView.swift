//
//  C2BSubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SearchBarComponent
import SwiftUI
import Tagged
import TextFieldComponent
import UIPrimitives

public struct C2BSubscriptionView<Footer: View, Search: View>: View {
    
    public typealias SearchView = (TextFieldState, @escaping (TextFieldAction) -> Void) -> Search
    
    private let state: C2BSubscriptionState
    private let event: (C2BSubscriptionEvent) -> Void
    private let footerView: () -> Footer
    private let searchView: SearchView
    private let config: C2BSubscriptionConfig
    
    public init(
        state: C2BSubscriptionState,
        event: @escaping (C2BSubscriptionEvent) -> Void,
        footerView: @escaping () -> Footer,
        searchView: @escaping SearchView,
        config: C2BSubscriptionConfig
    ) {
        self.state = state
        self.event = event
        self.footerView = footerView
        self.searchView = searchView
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            switch state.filteredList {
            case .none:
                emptyView()
                
            case let .some(filteredList):
                listView(filteredList)
            }
            
            footerView()
        }
        .alert(
            item: .init(
                get: { state.tapAlert },
                set: { if $0 == nil { event(.alertTap(.cancel)) }}
            ),
            content: { .init(with: $0, event: { event(.alertTap($0))}) }
        )
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.destination(.dismiss)) }}
            ),
            content: destinationView
        )
    }
    
    private func emptyView() -> some View {
        
        Text("TBD: Empty view")
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private typealias ProductSubscription = GetC2BSubResponse.Details.ProductSubscription
    
    private func listView(
        _ list: [ProductSubscription]
    ) -> some View {
        
        VStack(spacing: 24) {
            
            searchView(state.textFieldState, { event(.textField($0)) })
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(list, content: productSubscriptionView)
                }
            }
        }
    }
    
    private func productSubscriptionView(
        _ productSubscription: ProductSubscription
    ) -> some View {
        
        ProductSubscriptionView(
            productSubscription: productSubscription,
            event: { event(.subscriptionTap($0)) },
            config: config.product
        )
    }
    
    @ViewBuilder
    private func destinationView(
        _ destination: Destination
    ) -> some View {
        
        switch destination {
        case let .subscriptionCancelConfirm(confirm):
            Text("TBD: subscriptionCancelConfirm: \(String(describing: confirm))")
            
        case let .subscriptionDetail(detail):
            Text("TBD: subscriptionDetail: \(String(describing: detail))")
        }
    }
}

private extension C2BSubscriptionState {
    
    var destination: Destination? {
        
        switch status {
        case let .cancelled(confirmation):
            return .subscriptionCancelConfirm(confirmation)
            
        case let .detail(detail):
            return .subscriptionDetail(detail)
            
        default:
            return nil
        }
    }
}

private enum Destination {
    
    case subscriptionCancelConfirm(CancelC2BSubscriptionConfirmation)
    case subscriptionDetail(C2BSubscriptionDetail)
    
}

extension Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .subscriptionCancelConfirm:
            return .subscriptionCancelConfirm
            
        case .subscriptionDetail:
            return .subscriptionDetail
        }
    }
    
    enum ID {
        
        case subscriptionCancelConfirm
        case subscriptionDetail
    }
}

private extension C2BSubscriptionState {
    
    var filteredList: [GetC2BSubResponse.Details.ProductSubscription]? {
        
        guard case let .list(list) = getC2BSubResponse.details
        else { return nil }
        
        return list.compactMap { $0.filtered(searchText: searchTest) }
    }
    
    private var searchTest: String {
        
        switch textFieldState {
        case .placeholder:
            return ""
            
        case let .noFocus(text):
            return text
            
        case let .editing(textState):
            return textState.text
        }
    }
    
    var tapAlert: TapAlert? {
        
        guard case let .tapAlert(tapAlert) = status
        else { return nil }
        
        return tapAlert
    }
}

private extension GetC2BSubResponse.Details.ProductSubscription {
    
    func filtered(searchText: String) -> Self? {
        
        let filteredSubscriptions = subscriptions.filtered(
            with: searchText,
            keyPath: \.brandName
        )
        
        guard !filteredSubscriptions.isEmpty else { return nil }
        
        return .init(
            product: product,
            subscriptions: filteredSubscriptions
        )
    }
}

extension GetC2BSubResponse.Details.ProductSubscription: Identifiable {
    
    public var id: Product.ID { product.id }
}

extension GetC2BSubResponse.Details.ProductSubscription.Subscription: Identifiable {
    
    public var id: Token { token }
}

struct C2BSubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        C2BSubscriptionView_Demo(state: .control)
        C2BSubscriptionView_Demo(state: .empty)
    }
}
