//
//  ProductGroupsView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

struct ProductGroupsView<ProductView: View, NewProductButton: View, StickerView: View>: View {
    
    var state: CarouselState
    let groups: CarouselState.ProductGroups
    let event: (CarouselEvent) -> Void
    
    let productView: (Product) -> ProductView
    let stickerView: (Product) -> StickerView?
    let newProductButton: () -> NewProductButton?
    
    let config: CarouselConfig
    
    private let coordinateSpaceName = "scrollingEndedView_coordinateSpace"
    
    var body: some View {
        
        groupView(groups: groups)
    }
    
    private func groupView(groups: CarouselState.ProductGroups) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            ScrollViewReader { scrollProxy in
                
                HStack(alignment: .top, spacing: config.productDimensions.spacing) {
                    
                    ForEach(groups) { group in
                        
                        visibleProducts(for: group)
                        
                        spoiler(for: group)
                        
                        sticker(for: group)
                        
                        productGroupSeparator(for: group)
                    }
                    
                    newProductButton()
                        .frame(config.productDimensions, for: \.new)
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
        
        ForEach(
            state.visibleProducts(for: group),
            content: { product in
                
                ZStack {
                    
                    shadow()
                    
                    productView(product)
                }
                .id(group.id)
                .frame(config.productDimensions, for: \.product)
                .accessibilityIdentifier("mainProduct")
                
                if state.shouldAddSeparator(for: product) { separator() }
            })
    }
    
    private func shadow() -> some View {
        
        RoundedRectangle(cornerRadius: 12)
            .frame(config.productDimensions, for: \.productShadow)
            .foregroundColor(config.group.shadowForeground)
            .opacity(0.15)
            .offset(x: 0, y: 13)
            .blur(radius: 8)
    }
    
    @ViewBuilder
    private func spoiler(for group: ProductGroup) -> some View {
                        
        if state.shouldAddSpoiler(for: group) {
            
            HStack {
                
                GeometryReader { geometry in
                    
                    spoilerInnerView(
                        isCollapsed: state.productGroupIsCollapsed(group),
                        spoilerTitle: state.spoilerTitle(for: group)
                    ) {
                        let xOffset = geometry.frame(in: .global).origin.x
                        let screenWidth = UIScreen.main.bounds.width
                        
                        event(.toggle(
                            id: group.id,
                            screenwidth: screenWidth,
                            xOffset: xOffset)
                        )
                    }
                }
                .frame(config.productDimensions, for: \.button)
            }
            .id("spoiler\(group.id)")
        }
    }
    
    @ViewBuilder
    private func sticker(for group: ProductGroup) -> some View {
        
        if let sticker = state.sticker, state.shouldAddSticker(for: group) {
            
            if !state.shouldAddSpoiler(for: group) { separator() }
            
            stickerView(sticker)
                .id(group.id)
                .frame(config.productDimensions, for: \.product)
                .accessibilityIdentifier("mainProduct")
        }
    }
    
    @ViewBuilder
    private func productGroupSeparator(for group: ProductGroup) -> some View {
        
        if state.shouldAddGroupSeparator(for: group) { separator() }
    }
    
    func separator() -> some View {
        
        Capsule(style: .continuous)
            .foregroundColor(config.separatorForeground)
            .frame(config.productDimensions, for: \.separator)
            // wrap in another frame to center align
            .frame(height: config.productDimensions.sizes.product.height)
    }
    
    func spoilerInnerView(
        isCollapsed: Bool,
        spoilerTitle: String?,
        onTap: @escaping() -> Void
    ) -> some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(config.group.buttonForegroundPrimary)
            
            if isCollapsed {
                
                Text(spoilerTitle ?? "")
                    .font(config.group.buttonFont)
                    .foregroundColor(config.group.buttonForegroundSecondary)
            } else {
                
                config.spoilerImage
                    .foregroundColor(config.group.buttonIconForeground)
            }
            
        }.onTapGesture {
            
            onTap()
        }
    }
}

private extension View {
    
    typealias Dimensions = CarouselConfig.ProductDimensions

    @ViewBuilder
    func frame(
        _ dimensions: Dimensions,
        for keyPath: KeyPath<Dimensions.Sizes, CGSize>
    ) -> some View {
        
        EmptyView()
        let size: CGSize = dimensions.sizes[keyPath: keyPath]
        self.frame(
            width: size.width,
            height: size.height
        )
    }
}
