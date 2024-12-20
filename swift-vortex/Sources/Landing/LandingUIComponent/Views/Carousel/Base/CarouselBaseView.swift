//
//  CarouselBaseView.swift
//
//
//  Created by Andryusina Nataly on 07.10.2024.
//

import SwiftUI
import Combine
import UIPrimitives

public struct CarouselBaseView: View {
    
    let carousel: CarouselBase
    let actions: CarouselActions
    let factory: Factory
    let config: Config
    
    public init(
        carousel: CarouselBase,
        actions: CarouselActions,
        factory: Factory,
        config: Config
    ) {
        self.carousel = carousel
        self.actions = actions
        self.factory = factory
        self.config = config
    }

    public var body: some View {
            
        VStack(alignment: .leading) {
            
            carousel.title.map {
                
                $0.text(withConfig: config.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, config.paddings.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: config.spacing) {
                    ForEach(carousel.list, id: \.id, content: itemView)
                }
                .padding(.horizontal, config.paddings.horizontal)
            }
            .padding(.vertical, config.paddings.vertical)
        }
    }
    
    private func itemView (item: Item) -> some View {
        
        ItemView(
            item: item,
            config: config,
            factory: factory,
            action: UILanding.Carousel.action(
                itemAction: item.action,
                link: item.link,
                actions: actions
            ),
            width: widthForItem()
        )
    }
    
    private func widthForItem() -> CGFloat {
        
        if carousel.list.count == 1 {
            return CGFloat(carousel.size.width)
        } else {
            
            let screenWidth = UIScreen.main.bounds.width
            return ((screenWidth - config.paddings.horizontal - config.spacing) / 2 + config.offset).rounded(.toNearestOrEven)
        }
    }
}

extension CarouselBaseView {
    
    struct ItemView: View {
        
        let item: Item
        let config: Config
        let factory: Factory
        let action: () -> Void
        let width: CGFloat
        
        var body: some View {
            
            Button(action: action) {
                
                factory.makeBannerImageView(item.imageLink)
                    .scaledToFit()
                    .cornerRadius(config.cornerRadius)
                    .accessibilityIdentifier("CarouselBaseImage")
            }
            .frame(width: width)
            .scaledToFit()
        }
    }
}

public extension CarouselBaseView {
    
    typealias CarouselBase = UILanding.Carousel.CarouselBase
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
    typealias Config = UILanding.Carousel.CarouselBase.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = Size
}

struct CarouselBaseView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselBaseView(
            carousel: .default,
            actions: .default,
            factory: .default,
            config: .default
        )
    }
}
