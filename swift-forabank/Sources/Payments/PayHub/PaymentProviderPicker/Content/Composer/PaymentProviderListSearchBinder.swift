//
//  PaymentProviderListSearchBinder.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine

public enum PaymentProviderListSearchBinder<ProviderList, Search> {}

public extension PaymentProviderListSearchBinder {
    
    /// - Note: debouncing is the responsibility of `search witness`, not composer.
    static func bind(
        providerList: Receiving<ProviderList, String>,
        search: Emitting<Search, String>
    ) -> Set<AnyCancellable> {
        
        let searchToProviderList = search.makePublisher(search.model)
            .sink(receiveValue: providerList.makeReceive(providerList.model))
        
        return [searchToProviderList]
    }
}
