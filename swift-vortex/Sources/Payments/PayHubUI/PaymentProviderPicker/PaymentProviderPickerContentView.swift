//
//  PaymentProviderPickerContentView.swift
//
//
//  Created by Igor Malyarov on 19.09.2024.
//

import Combine
import PayHub
import SwiftUI

public struct PaymentProviderPickerContentView<OperationPicker, ProviderList, Search, OperationPickerView, ProviderListView, SearchView>: View
where OperationPickerView: View,
      ProviderListView: View,
      SearchView: View {
    
    @State private var isSearchActive = false
    
    private let content: Content
    private let isSearchActivePublisher: AnyPublisher<Bool, Never>
    private let factory: Factory
    
    public init(
        content: Content,
        isSearchActivePublisher: AnyPublisher<Bool, Never>,
        factory: Factory
    ) {
        self.content = content
        self.isSearchActivePublisher = isSearchActivePublisher
        self.factory = factory
    }
    
    public var body: some View {
        
        VStack(spacing: 8) {
            
            content.search.map(factory.makeSearchView)
            
            List {
                
                if !isSearchActive {
                    
                    factory.makeOperationPickerView(content.operationPicker)
                        .transition(.opacity.combined(with: .slide))
                        .opacity(isSearchActive ? 0 : 1)
                        .frame(height: isSearchActive ? 0.01 : nil, alignment: .bottom)
                        .plainListRow()
                }
                
                factory.makeProviderList(content.providerList)
            }
            .listRowSpacing(13)
            .listStyle(.plain)
        }
        .onReceive(isSearchActivePublisher) { isSearchActive = $0 }
        .animation(.bouncy, value: isSearchActive)
    }
}

public extension PaymentProviderPickerContentView {
    
    typealias Content = PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    typealias Factory = PaymentProviderPickerContentViewFactory<OperationPicker, ProviderList, Search, OperationPickerView, ProviderListView, SearchView>
}
