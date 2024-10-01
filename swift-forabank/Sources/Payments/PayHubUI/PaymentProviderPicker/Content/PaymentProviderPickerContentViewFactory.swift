//
//  PaymentProviderPickerContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 19.09.2024.
//

public struct PaymentProviderPickerContentViewFactory<OperationPicker, ProviderList, Search, OperationPickerView, ProviderListView, SearchView> {
    
    public let makeOperationPickerView: MakeOperationPickerView
    public let makeProviderList: MakeProviderList
    public let makeSearchView: MakeSearchView
    
    public init(
        makeOperationPickerView: @escaping MakeOperationPickerView,
        makeProviderList: @escaping MakeProviderList,
        makeSearchView: @escaping MakeSearchView
    ) {
        self.makeOperationPickerView = makeOperationPickerView
        self.makeProviderList = makeProviderList
        self.makeSearchView = makeSearchView
    }
}

public extension PaymentProviderPickerContentViewFactory {
    
    typealias MakeOperationPickerView = (OperationPicker) -> OperationPickerView
    typealias MakeProviderList = (ProviderList) -> ProviderListView
    typealias MakeSearchView = (Search) -> SearchView
}
