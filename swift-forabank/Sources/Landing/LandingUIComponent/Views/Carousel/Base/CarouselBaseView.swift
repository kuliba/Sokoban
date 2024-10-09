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
    
    let model: Model
    let actions: CarouselActions
    let factory: Factory
    let config: Config
    
    public init(
        model: Model,
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: config.spacing) {
                    ForEach(model.list, id: \.imageLink, content: itemView)
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
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
    
    typealias Model = UILanding.Carousel.CarouselBase
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
    typealias Config = UILanding.Carousel.CarouselBase.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = UILanding.Carousel.CarouselBase.Size
}

struct CarouselBaseView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselBaseView(
            model: .default,
            actions: .default,
            factory: .default,
            config: .default
        )
    }
}
