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
            size: carousel.size
        )
        .padding(.leading, config.paddings.horizontal)
    }
}

extension CarouselBaseView {
    
    struct ItemView: View {
        
        let item: Item
        let config: Config
        let factory: Factory
        let action: () -> Void
        let size: ItemSize
        
        var body: some View {
            
            Button(action: action) {
                
                factory.makeBannerImageView(item.imageLink)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(config.cornerRadius)
                    .accessibilityIdentifier("CarouselBaseImage")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

public extension CarouselBaseView {
    
    typealias CarouselBase = UILanding.Carousel.CarouselBase
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
    typealias Config = UILanding.Carousel.CarouselBase.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = UILanding.Carousel.CarouselBase.Size
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
