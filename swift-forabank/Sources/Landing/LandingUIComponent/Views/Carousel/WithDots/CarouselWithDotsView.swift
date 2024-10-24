//
//  CarouselWithDotsView.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import SwiftUI
import Combine
import UIPrimitives

public struct CarouselWithDotsView: View {
    
    let carousel: CarouselWithDots
    let actions: CarouselActions
    let factory: Factory
    let config: Config
    
    @State private var selection: Int = 0
    
    public init(
        carousel: CarouselWithDots,
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
            
            TabView(selection: $selection){
                ForEach(0..<carousel.list.count, id: \.self) {
                    itemView(item: carousel.list[$0])
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: carousel.size.newHeight(config.paddings.horizontal))
            
            if carousel.list.count > 1 {
                pageControl()
                    .frame(maxWidth: .infinity)
            }
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
            padding: config.paddings.horizontal
        )
    }
    
    private func pageControl() -> some View {
        
        HStack {
            ForEach(0..<carousel.list.count, id: \.self) { index in
                Circle()
                    .frame(widthAndHeight: config.pageControls.widthAndHeight)
                    .foregroundColor(index == selection ? config.pageControls.active : config.pageControls.inactive )
                    .onTapGesture(perform: { selection = index })
            }
        }
    }
}

extension CarouselWithDotsView {
    
    struct ItemView: View {
        
        let item: Item
        let config: Config
        let factory: Factory
        let action: () -> Void
        let padding: CGFloat
        
        var body: some View {
            
            Button(action: action) {
                
                factory.makeBannerImageView(item.imageLink)
                    .cornerRadius(config.cornerRadius)
                    .accessibilityIdentifier("CarouselWithDotsImage")
            }
            .padding(.horizontal, padding)
        }
    }
}

public extension CarouselWithDotsView {
    
    typealias CarouselWithDots = UILanding.Carousel.CarouselWithDots
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselWithDots.ListItem
    typealias Config = UILanding.Carousel.CarouselWithDots.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = Size
}

struct CarouselWithDotsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselWithDotsView(
            carousel: .default,
            actions: .default,
            factory: .default,
            config: .default
        )
    }
}
