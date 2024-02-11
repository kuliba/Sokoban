//
//  C2BSubscriptionState.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

struct C2BSubscriptionState {
    
    let getC2BSubResponse: GetC2BSubResponse
    var searchTest: String
    
    init(
        getC2BSubResponse: GetC2BSubResponse,
        searchTest: String = ""
    ) {
        self.getC2BSubResponse = getC2BSubResponse
        self.searchTest = searchTest
    }
}

extension C2BSubscriptionState {
    
    var filteredList: [GetC2BSubResponse.Details.ProductSubscription]? {
        
        guard case let .list(list) = getC2BSubResponse.details
        else { return nil }
        
        return list.compactMap { $0.filtered(searchText: searchTest) }
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
