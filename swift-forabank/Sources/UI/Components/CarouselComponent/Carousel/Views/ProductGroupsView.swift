//
//  ProductGroupsView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

struct ProductGroupsView<ProductView: View, NewProductButton: View, StickerView: View>: View {
    
    var state: State
    let groups: Groups
    let event: (Event) -> Void
    
    let productView: (Product) -> ProductView
    let stickerView: () -> StickerView?
    let newProductButton: () -> NewProductButton?
    
    let config: CarouselConfig
    
    private let coordinateSpaceName = "scrollingEndedView_coordinateSpace"
    
    var body: some View {
        
        groupView(groups: groups)
    }
    
    private func groupView(groups: Groups) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            ScrollViewReader { scrollProxy in
                
                HStack(alignment: .top, spacing: config.productDimensions.spacing) {
                    
                    ForEach(groups) { group in
                        
                        visibleProducts(for: group)
                        
                        spoiler(for: group)
                        
                        sticker(for: group)
                        
                        productGroupSeparator(for: group)
                    }
                    
                    if state.needShowAddNewProduct {
                        newProductButton()
                            .frame(config.productDimensions, for: \.new)
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
    
    private func visibleProducts(for group: Group) -> some View {
        
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
    private func spoiler(for group: Group) -> some View {
                        
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
    private func sticker(for group: Group) -> some View {
        
        if state.needShowSticker, state.shouldAddSticker(for: group) {
            
            if !state.shouldAddSpoiler(for: group) { separator() }
            
            ZStack(alignment: .topTrailing) {
                
                stickerView()
                    .id(group.id)
                    .frame(config.productDimensions, for: \.product)
                    .accessibilityIdentifier("mainProduct")
                StickerCloseButtonView(action: { event(.closeSticker) })
            }
        }
    }
    
    @ViewBuilder
    private func productGroupSeparator(for group: Group) -> some View {
        
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

struct StickerCloseButtonView: View {
    
    let action: () -> Void
    
    var body: some View {
        
        Button {
            withAnimation { action() }
            
        } label: {
            
            ZStack {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
                
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
            }
            .frame(width: 20, height: 20)
        }
        .padding(4)
    }
}

extension ProductGroupsView {
    
    typealias State = CarouselState
    typealias Event = CarouselEvent
    
    typealias Group = ProductGroup
    typealias Groups = [Group]
}
