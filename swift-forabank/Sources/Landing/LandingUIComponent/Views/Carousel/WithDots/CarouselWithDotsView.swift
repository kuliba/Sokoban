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
    
    let model: CarouselWithDots
    let actions: CarouselActions
    let factory: Factory
    let config: Config
    
    @State private var selection: Int = 0
    
    public init(
        model: CarouselWithDots,
        actions: CarouselActions,
        factory: Factory,
        config: Config
    ) {
        self.model = model
        self.actions = actions
        self.factory = factory
        self.config = config
    }
    
    public var body: some View {
            
        VStack(alignment: .leading) {
            
            model.title.map {
                $0.text(withConfig: config.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, config.paddings.horizontal)
            }
            
            TabView(selection: $selection){
                ForEach(0..<model.list.count, id: \.self) {
                    itemView(item: model.list[$0])
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: CGFloat(model.size.height))
            
            pageControl()
                .frame(maxWidth: .infinity)
        }
    }
    
    private func itemView (item: Item) -> some View {
        
        ItemView(
            item: item,
            config: config,
            factory: factory,
            action: model.action(item: item, actions: actions),
            size: model.size
        )
    }
    
    private func pageControl() -> some View {
        
        HStack {
            ForEach(0..<model.list.count, id: \.self) { index in
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
        let size: ItemSize
        
        var body: some View {
            
            Button(action: action) {
                
                factory.makeBannerImageView(item.imageLink)
                    .cornerRadius(config.cornerRadius)
                    .frame(width: CGFloat(size.width), height: CGFloat(size.height))
                    .accessibilityIdentifier("CarouselWithDotsImage")
            }
        }
    }
}

public extension CarouselWithDotsView {
    
    typealias CarouselWithDots = UILanding.Carousel.CarouselWithDots
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselWithDots.ListItem
    typealias Config = UILanding.Carousel.CarouselWithDots.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = UILanding.Carousel.CarouselWithDots.Size
}

struct CarouselWithDotsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselWithDotsView(
            model: .default,
            actions: .default,
            factory: .default,
            config: .default
        )
    }
}
