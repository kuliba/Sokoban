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
            
           /* TabView(selection: $selection){
                ForEach(0..<carousel.tabs.count, id: \.self) { tabIndex in
                    ForEach(0..<carousel.tabs[tabIndex].list.count, id: \.self) { itemIndex in
                        itemView(item: carousel.tabs[tabIndex].list[itemIndex])
                            .tag("\(tabIndex):\(itemIndex)")
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: CGFloat(carousel.size.height))*/
            ScrollView {
                ScrollViewReader { proxy in
                    ForEach(0..<carousel.tabs.count, id: \.self) { tabIndex in
                        ForEach(0..<carousel.tabs[tabIndex].list.count, id: \.self) { itemIndex in
                            itemView(item: carousel.tabs[tabIndex].list[itemIndex])
                                .tag("\(tabIndex):\(itemIndex)")
                        }
                    }
                }
                .onScrolled { point in
                    print("Point: \(point)")
                }
            }
            .trackScrolling()
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

public extension ScrollView {

    // NB: CaptureScrollingOffset.EnvironmentKey is a class, so the value can be "shared" between Views,
    //     allowing both GeometryReader and Environment to participate in the same view.
    func trackScrolling() -> some View {
        let coordinateSpace = UUID()
        let environmentKey = CaptureScrollingOffset.EnvironmentKey(coordinateSpace: coordinateSpace)

        return self
            .coordinateSpace(name: coordinateSpace)
            .background(
                GeometryReader { geometry -> Color in
                    environmentKey.bounds = geometry.frame(in: .local)
                    return Color.clear
                }
            )
            .environment(\.captureScrollingOffset, environmentKey)
    }
    
}


public extension ScrollViewReader {

    func onScrolled(_ perform: @escaping (UnitPoint) -> Void) -> some View {
        return ModifiedContent(content: self, modifier: CaptureOffsetViewModifier())
            .onPreferenceChange(CaptureScrollingOffset.PreferenceKey.self) {
                var x: CGFloat = $0.content.origin.x
                var y: CGFloat = $0.content.origin.y

                if $0.content.width != $0.bounds.width {
                    x = x / ($0.content.width - $0.bounds.width)
                }

                if $0.content.height != $0.bounds.height {
                    y = y / ($0.content.height - $0.bounds.height)
                }

                x = (x * 10000).rounded() / 10000
                y = (y * 10000).rounded() / 10000

                x = min(max(x, 0), 1)
                y = min(max(y, 0), 1)

                perform(UnitPoint(x: x, y: -y))
            }
    }
}


fileprivate struct CaptureOffsetViewModifier: ViewModifier {

    @Environment(\.captureScrollingOffset) private var captureScrollingOffset

    func body(content: Content) -> some View {
        assert(captureScrollingOffset != nil, "Unexpected state, coordinate space not set for tracking offset changes")
        return captureScrollingOffset == nil ? ViewBuilder.buildEither(first: content) :
            ViewBuilder.buildEither(second: content.background(
                GeometryReader { geometry in
                    return Color.clear.preference(key: CaptureScrollingOffset.PreferenceKey.self,
                                                  value: CaptureScrollingOffset.KeyData(bounds: captureScrollingOffset!.bounds, content: geometry.frame(in: .named(captureScrollingOffset!.coordinateSpace))))
                }
            ))
    }
    
}


fileprivate struct CaptureScrollingOffset {

    class EnvironmentKey: SwiftUI.EnvironmentKey {
        let coordinateSpace: AnyHashable
        var bounds: CGRect

        static var defaultValue: CaptureScrollingOffset.EnvironmentKey? = nil

        init(coordinateSpace: AnyHashable, bounds: CGRect = .zero) {
            self.coordinateSpace = coordinateSpace
            self.bounds = bounds
        }

    }

    struct KeyData: Equatable {
        
        static var `default` = KeyData(bounds: .zero, content: .zero)
        
        let bounds: CGRect
        let content: CGRect

        static func == (lhs: CaptureScrollingOffset.KeyData, rhs: CaptureScrollingOffset.KeyData) -> Bool {
            return lhs.bounds == rhs.bounds && lhs.content == rhs.content
        }
    }

    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CaptureScrollingOffset.KeyData = .default

        static func reduce(value: inout CaptureScrollingOffset.KeyData, nextValue: () -> CaptureScrollingOffset.KeyData) {
        }
    }
    
}


fileprivate extension EnvironmentValues {
    
    var captureScrollingOffset: CaptureScrollingOffset.EnvironmentKey? {
        get { self[CaptureScrollingOffset.EnvironmentKey.self] }
        set { self[CaptureScrollingOffset.EnvironmentKey.self] = newValue }
    }
}
