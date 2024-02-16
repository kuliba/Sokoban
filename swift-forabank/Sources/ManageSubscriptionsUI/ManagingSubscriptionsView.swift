//
//  ManageSubscribeView.swift
//
//
//  Created by Дмитрий Савушкин on 19.07.2023.
//

import SwiftUI

public struct ViewConfigurator {
    
    let backgroundColor: Color
    
    public init(backgroundColor: Color) {
        
        self.backgroundColor = backgroundColor
    }
}

public struct ManagingSubscriptionsView<P: Product, SearchView: View, EmptyListView: View>: View {
    
    private let products: [P]
    private let productView: (P) -> ProductView
    private let searchView: () -> SearchView
    private let emptyListView: () -> EmptyListView
    private let configurator: ViewConfigurator
    private let footerImage: Image
    
    public init(
        products: [P],
        productView: @escaping (P) -> ProductView,
        searchView: @escaping () -> SearchView,
        emptyListView: @escaping () -> EmptyListView,
        footerImage: Image,
        configurator: ViewConfigurator
    ) {    
        self.products = products
        self.productView = productView
        self.searchView = searchView
        self.emptyListView = emptyListView
        self.footerImage = footerImage
        self.configurator = configurator
    }
    
    public var body: some View {
    
        VStack(spacing: 24) {
            
            if products.isEmpty {
                
                searchView()
                
                emptyListView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                
                searchView()
                
                VStack(spacing: 0) {
                 
                    ProductListView(
                        products: products,
                        productView: productView,
                        backgroundColor: configurator.backgroundColor
                    )
                    
                    HStack {
                     
                        footerImage
                            .renderingMode(.original)
                            .frame(width: 72, height: 36, alignment: .center)
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Управление подписками")
        .padding(.horizontal, 20)
    }
}
