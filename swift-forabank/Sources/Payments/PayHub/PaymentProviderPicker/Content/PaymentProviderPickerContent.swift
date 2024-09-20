//
//  PaymentProviderPickerContent.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine

public final class PaymentProviderPickerContent<ProviderList, Search> {
    
    public let providerList: ProviderList
    public let search: Search?
    
    private let cancellables: Set<AnyCancellable>
    
    public init(
        providerList: ProviderList,
        search: Search?,
        cancellables: Set<AnyCancellable>
    ) {
        self.providerList = providerList
        self.search = search
        self.cancellables = cancellables
    }
}
