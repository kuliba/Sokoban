//
//  C2BSubscriptionState.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain

public struct C2BSubscriptionState {
    
    public let getC2BSubResponse: GetC2BSubResponse
    public var textFieldState: TextFieldState
    
    public init(
        getC2BSubResponse: GetC2BSubResponse,
        textFieldState: TextFieldState = .placeholder("Поиск")
    ) {
        self.getC2BSubResponse = getC2BSubResponse
        self.textFieldState = textFieldState
    }
}

public extension C2BSubscriptionState {
    
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
}

private extension GetC2BSubResponse.Details.ProductSubscription {
    
    func filtered(searchText: String) -> Self? {
        
        let filteredSubscriptions = subscriptions.filtered(
            with: searchText,
            keyPath: \.brandName
        )
        
        guard !filteredSubscriptions.isEmpty else { return nil }
        
        return .init(
            productID: productID,
            productType: productType,
            productTitle: productTitle,
            subscriptions: filteredSubscriptions
        )
    }
}
