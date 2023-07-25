//
//  ManageSubscribeView.swift
//
//
//  Created by Дмитрий Савушкин on 19.07.2023.
//

import SwiftUI

public struct ManagingSubscriptionsView<P: Product, SearchView: View, EmptyListView: View>: View {
    
    private let products: [P]
    private let productView: (P) -> ProductView
    private let searchView: () -> SearchView
    private let emptyListView: () -> EmptyListView

    public init(
        products: [P],
        productView: @escaping (P) -> ProductView,
        searchView: @escaping () -> SearchView,
        emptyListView: @escaping () -> EmptyListView
    ) {    
        self.products = products
        self.productView = productView
        self.searchView = searchView
        self.emptyListView = emptyListView
    }
    
    public var body: some View {
    
        VStack(spacing: 24) {
            
            if products.isEmpty {
                
                emptyListView()
                
            } else {
                
                searchView()
                
                ProductListView(products: products, productView: productView)
            }
        }
        .navigationTitle("Управление подписками")
        .padding(.horizontal, 20)
    }
}
