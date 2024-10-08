//
//  CarouselWithDotsView.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct CarouselWithDotsView: View {
    
    let state: CarouselState
    let event: (Event) -> Void
    let factory: Factory
    let config: Config

    @State private var selection: Int = 0
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
            state.data.title.map {
                Text($0)
                    .font(config.title.textFont)
                    .foregroundColor(config.title.textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, config.paddings.horizontal)
            }
            
            TabView(selection : $selection){
                ForEach(0..<state.data.list.count, id: \.self){ index in
                    ItemView(
                        item: state.data.list[index],
                        config: config,
                        factory: factory,
                        action: { /*model.itemAction(item: item)*/ },
                        size: state.data.size
                    )
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(
                .page(backgroundDisplayMode: .always)
            )
            .frame(height: CGFloat(state.data.size.height + 100))
        }
    }
    
    private func itemView (item: Item) -> some View {
        
        ItemView(
            item: item,
            config: config,
            factory: factory,
            action: state.action(item: item, event: event),
            size: state.data.size
        )
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
                
                VStack(spacing: config.spacing) {
                    factory.makeBannerImageView(item.imageLink)
                        .cornerRadius(config.cornerRadius)
                        .accessibilityIdentifier("CarouselWithDotsImage")
                }
            }
            .frame(width: CGFloat(size.width), height: CGFloat(size.height))
        }
    }
}

extension CarouselWithDotsView {
    
    typealias CarouselState = CarouselWithDotsState
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselWithDots.ListItem
    typealias Config = UILanding.Carousel.CarouselWithDots.Config
    typealias Factory = ViewFactory
    typealias ItemSize = UILanding.Carousel.CarouselWithDots.Size
}

struct CarouselWithDotsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselWithDotsView(
            state: .init(data: .default),
            event: { _ in },
            factory: .default,
            config: .default
        )
    }
}
