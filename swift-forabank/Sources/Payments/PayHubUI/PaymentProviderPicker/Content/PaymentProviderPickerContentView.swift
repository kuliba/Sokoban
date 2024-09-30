//
//  PaymentProviderPickerContentView.swift
//
//
//  Created by Igor Malyarov on 19.09.2024.
//

import PayHub
import SwiftUI

public struct PaymentProviderPickerContentView<OperationPicker, ProviderList, Search, OperationPickerView, ProviderListView, SearchView>: View
where OperationPickerView: View,
      ProviderListView: View,
      SearchView: View {
    
    private let content: Content
    private let factory: Factory
    
    public init(
        content: Content,
        factory: Factory
    ) {
        self.content = content
        self.factory = factory
    }
    
    public var body: some View {
        
        VStack {
            
            content.search.map(factory.makeSearchView)
            factory.makeOperationPickerView(content.operationPicker)
            factory.makeProviderList(content.providerList)
        }
    }
}

public extension PaymentProviderPickerContentView {
    
    typealias Content = PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    typealias Factory = PaymentProviderPickerContentViewFactory<OperationPicker, ProviderList, Search, OperationPickerView, ProviderListView, SearchView>
}
