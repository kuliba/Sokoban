//
//  CarouselBaseView.swift
//
//
//  Created by Andryusina Nataly on 07.10.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct CarouselBaseView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    let config: Config

    var body: some View {
            
        VStack(alignment: .leading) {
            
            state.data.title.map {
                Text($0)
                    .font(config.titleFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, config.paddings.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: config.spacing) {
                    ForEach(state.data.list, id: \.imageLink, content: itemView)
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
            action: action(item: item),
            size: state.data.size
        )
    }
    
    private func action(
        item: Item
    ) -> () -> Void {
        
        guard let link = item.link else { return {} }
        return {
            event(.card(.openUrl(link)))
        }

        switch item.action {
        case .none:
            
            guard let link = item.link else { return {} }
            return { event(.card(.openUrl(link))) }
            
        case let .some(action):
            
            if let type = LandingActionType(rawValue: action.type) {
                switch type {
                case .goToMain: return { event(.card(.goToMain)) }
                case .orderCard: return {}
                case .goToOrderSticker: return { event( .bannerAction(.landing))}
                }
            }
            
            return {}
        }
    }
}

extension CarouselBaseView {
    
    struct ItemView: View {
        
        let item: Item
        let config: Config
        let factory: Factory
        let action: () -> Void
        let size: UILanding.Carousel.CarouselBase.Size
        
        var body: some View {
            
            Button(action: action) {
                
                VStack(spacing: config.spacing) {
                    factory.makeBannerImageView(item.imageLink)
                        .frame(width: size.width, height: size.height)
                        .cornerRadius(config.cornerRadius)
                        .accessibilityIdentifier("CarouselBaseImage")
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

extension CarouselBaseView {
    
    typealias State = CarouselBaseState
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
    typealias Config = UILanding.Carousel.CarouselBase.Config
    typealias Factory = ViewFactory
}

struct CarouselBaseView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselBaseView(
            state: .init(data: .default),
            event: { _ in },
            factory: .default,
            config: .default
        )
    }
}
