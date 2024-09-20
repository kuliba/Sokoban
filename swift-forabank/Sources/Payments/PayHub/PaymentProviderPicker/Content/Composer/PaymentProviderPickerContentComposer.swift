//
//  PaymentProviderPickerContentComposer.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine

public final class PaymentProviderPickerContentComposer<ProviderList, Search> {
    
    public init() {}
}

public extension PaymentProviderPickerContentComposer {
    
    /// - Note: debouncing is the responsibility of `search witness`, not composer.
    func compose(
        providerList: Receiving<ProviderList, String>,
        search: Emitting<Search, String>?
    ) -> Content {
        
        return .init(
            providerList: providerList.model,
            search: search?.model,
            cancellables: bind(providerList, search)
        )
    }
    
    typealias Content = PaymentProviderPickerContent<ProviderList, Search>
}

private extension PaymentProviderPickerContentComposer {
    
    func bind(
        _ providerList: Receiving<ProviderList, String>,
        _ search: Emitting<Search, String>?
    ) -> Set<AnyCancellable> {
        
        var set = Set<AnyCancellable>()
        
        let searchToProviderList = search.map {
            $0.makePublisher($0.model)
                .sink(receiveValue: providerList.makeReceive(providerList.model))
        }
        
        if let searchToProviderList { set.insert(searchToProviderList) }
        
        return set
    }
}
