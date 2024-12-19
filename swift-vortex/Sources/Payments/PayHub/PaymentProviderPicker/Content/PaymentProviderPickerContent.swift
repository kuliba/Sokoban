//
//  PaymentProviderPickerContent.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine

public final class PaymentProviderPickerContent<OperationPicker, ProviderList, Search> {
    
    public let title: String
    public let operationPicker: OperationPicker
    public let providerList: ProviderList
    public let search: Search?
    
    private let cancellables: Set<AnyCancellable>
    
    public init(
        title: String,
        operationPicker: OperationPicker,
        providerList: ProviderList,
        search: Search?,
        cancellables: Set<AnyCancellable>
    ) {
        self.title = title
        self.operationPicker = operationPicker
        self.providerList = providerList
        self.search = search
        self.cancellables = cancellables
    }
}
