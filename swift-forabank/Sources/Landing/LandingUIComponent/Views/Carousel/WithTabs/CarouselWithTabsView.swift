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
            
            ScrollViewReader { proxy in
                
                        categories(proxy)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        ForEach(0..<carousel.tabs.count, id: \.self) { tabIndex in
                            ForEach(0..<carousel.tabs[tabIndex].list.count, id: \.self) { itemIndex in
                                itemView(item: carousel.tabs[tabIndex].list[itemIndex], 
                                         index: "\(tabIndex):\(itemIndex)"
                                )
                                    .id("\(tabIndex):\(itemIndex)")
                            }
                        }
                    }
                    .padding(.horizontal, config.paddings.horizontal)

                }
                .padding(.vertical, config.paddings.vertical)
            }
        }
    }
    
    private func itemView (item: Item, index: String) -> some View {
        
        ItemView(
            item: item,
            config: config,
            factory: factory,
            action: UILanding.Carousel.action(
                itemAction: item.action,
                link: item.link,
                actions: actions
            ),
            padding: config.paddings.horizontal,
            width: widthForItem()
        )
    }
    
    private func categories(
        _ proxy: ScrollViewProxy
    ) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                ForEach(0..<carousel.tabs.count, id: \.self) { index in
                    category(index, proxy)
                        .id("\(index)")
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
        }
    }
    
    private func category(
        _ index: Int,
        _ proxy: ScrollViewProxy
    ) -> some View {
        
        carousel.tabs[index].name.text(withConfig: config.category)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .frame(height: config.pageControls.height)
            .background(index == selection.sectionIndex() ? config.pageControls.active : config.pageControls.inactive)
            .clipShape(RoundedRectangle(cornerRadius: 90))
            .onTapGesture(perform: {
                selection = "\(index):0"
                withAnimation {
                    proxy.scrollTo(selection, anchor: .center)
                    proxy.scrollTo("\(index)", anchor: .center)

                }
            })
    }
    
    private func widthForItem() -> CGFloat {
        
        let screenWidth = UIScreen.main.bounds.width
        if carousel.tabs.count == 1, carousel.tabs.first?.list.count == 1 {
            let paddings = config.paddings.horizontal * 2
            return (screenWidth - paddings).rounded(.toNearestOrEven)
        } else {
            return ((screenWidth - config.paddings.horizontal - config.spacing) / 2 + config.offset).rounded(.toNearestOrEven)
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
        let width: CGFloat

        var body: some View {
            
            Button(action: action) {
                
                factory.makeBannerImageView(item.imageLink)
                    .scaledToFit()
                    .cornerRadius(config.cornerRadius)
                    .accessibilityIdentifier("CarouselWithTabsImage")
            }
            .frame(width: width)
            .scaledToFit()
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
