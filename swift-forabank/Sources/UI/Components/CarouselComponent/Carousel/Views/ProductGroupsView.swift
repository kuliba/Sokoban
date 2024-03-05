//
//  ProductGroupsView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

struct ProductGroupsView<ProductView: View>: View {
        
    var state: CarouselState
    let groups: CarouselState.ProductGroups
    let event: (CarouselEvent) -> Void
    let productView: (Product) -> ProductView
    
    private let coordinateSpaceName = "scrollingEndedView_coordinateSpace"
    
    var body: some View {
     
        groupView(groups: groups)
    }
    
    private func groupView(groups: CarouselState.ProductGroups) -> some View {
                
        ScrollView(.horizontal, showsIndicators: false) {
                        
            ScrollViewReader { scrollProxy in
                
                HStack {
                                        
                    ForEach(groups) { group in
                        
                        visibleProducts(for: group)
                        
                        spoiler(for: group)
                        
                        productGroupSeparator(for: group)
                    }
                }
                .onHorizontalScroll(in: .named(coordinateSpaceName), completion: { event(.didScrollTo($0)) })
                .onChange(of: state.selectedProductType) { productType in
                    
                    guard let productType else { return }
                    
                    withAnimation {
                        scrollProxy.scrollTo(productType, anchor: .leading)
                    }
                }
                .onChange(of: state.spoilerUnitPoints) { spoilerUnitPoints in
                    
                    guard let selected = state.selector.selected
                    else { return }
                    
                    withAnimation {
                        
                        scrollProxy.scrollTo("spoiler\(selected)", anchor: spoilerUnitPoints)
                    }
                }
            }
        }
        .animation(.easeInOut)
        .coordinateSpace(name: coordinateSpaceName)
    }
    
    private func visibleProducts(for group: ProductGroup) -> some View {
        
        ForEach(group.visibleProducts, content: { product in
            
            productView(product)
                .id(group.id)
            
            if state.shouldAddSeparator(for: product) {
                
                // TODO: - Отрисовка разделителей
                Divider()
                    .frame(width: 10, height: 100)
                    .overlay(Color.green)
            }
        })
    }
    
    @ViewBuilder
    private func spoiler(for group: ProductGroup) -> some View {
        
        if group.products.count > 3 {
                
            HStack {
                
                GeometryReader { geometry in
                    
                    Button(group.toggleTitle) {
                        
                        let xOffset = geometry.frame(in: .global).origin.x
                        let screenWidth = UIScreen.main.bounds.width
                                                                
                        event(.toggle(
                            id: group.id,
                            screenwidth: screenWidth,
                            xOffset: xOffset)
                        )
                    }
                }
            }
            // TODO: - Размеры кнопки в конфигурацию
            .frame(width: 30, height: 20)
            .id("spoiler\(group.id)")
        }
    }
    
    @ViewBuilder
    private func productGroupSeparator(for group: ProductGroup) -> some View {
        
        if state.shouldAddGroupSeparator(for: group) {
            // TODO: - Отрисовка разделителей
            Divider()
                .frame(width: 10, height: 100)
                .overlay(Color.blue)
        }
    }
}

extension ProductGroup {
    
    var visibleProducts: [Product] {
        
        switch state {
        case .collapsed:
            // TODO: - Перенести в конфигурацию
            return .init(products.prefix(3))
            
        case .expanded:
            return products
        }
    }
    
    #warning("Убрать при интеграции в основной таргет")
    var toggleTitle: String {
        
        switch state {
        case .collapsed:
            return "Exp"
            
        case .expanded:
            return "Col"
        }
    }
}
