//
//  CarouselWithTabsView.swift
//
//
//  Created by Andryusina Nataly on 09.10.2024.
//

import SwiftUI
import Combine
import UIPrimitives

public struct CarouselWithTabsView: View {
    
    let carousel: CarouselWithTabs
    let actions: CarouselActions
    let factory: Factory
    let config: Config
    
    @State private var selection: String = "0:0"
    
    public init(
        carousel: CarouselWithTabs,
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
            
            categories()
            
            TabView(selection: $selection){
                ForEach(0..<carousel.tabs.count, id: \.self) { tabIndex in
                    ForEach(0..<carousel.tabs[tabIndex].list.count, id: \.self) { itemIndex in
                        itemView(item: carousel.tabs[tabIndex].list[itemIndex])
                            .tag("\(tabIndex):\(itemIndex)")
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: CGFloat(carousel.size.height))
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
    
    private func categories() -> some View {
        
        HStack {
            ForEach(0..<carousel.tabs.count, id: \.self) { index in
                Capsule()
                    .fill(index == selection.sectionIndex() ? config.pageControls.active : config.pageControls.inactive)
                    .overlay(
                        carousel.tabs[index].name.text(withConfig: config.category)
                    )
                    .frame(height: 24)
                    .onTapGesture(perform: { selection = "\(index):0" })
            }
        }
    }
}

extension CarouselWithTabsView {
    
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
                    .accessibilityIdentifier("CarouselWithTabsImage")
            }
            .padding(.horizontal, padding)
        }
    }
}

public extension CarouselWithTabsView {
    
    typealias CarouselWithTabs = UILanding.Carousel.CarouselWithTabs
    typealias Event = LandingEvent
    
    typealias Item = UILanding.Carousel.CarouselWithTabs.ListItem
    typealias Config = UILanding.Carousel.CarouselWithTabs.Config
    typealias Factory = ImageViewFactory
    typealias ItemSize = Size
}

struct CarouselWithTabsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CarouselWithTabsView(
            carousel: .default,
            actions: .default,
            factory: .default,
            config: .default
        )
    }
}

private extension String {
    
    func sectionIndex() -> Int {
        
        let info = components(separatedBy: ":")
        
        return Int(info.first ?? "0") ?? 0
    }
}
