//
//  BannerPickerSectionContentView.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import PayHub
import SharedConfigs
import SwiftUI
import UIPrimitives

public struct BannerPickerSectionContentView<ItemView, ServiceBanner>: View
where ItemView: View,
      ServiceBanner: Equatable {
    
    private let state: State
    private let event: (Event) -> Void
    private let config: Config
    private let itemView: (State.Item) -> ItemView
    
    private let transition: AnyTransition = .opacity.combined(with: .scale)
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        config: Config,
        @ViewBuilder itemView: @escaping (State.Item) -> ItemView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.itemView = itemView
    }
    
    public var body: some View {
        
        if state.isLoadingFailed {
            Text("Failed to load banners")
                .foregroundColor(.red)
                .frame(maxHeight: .infinity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: config.spacing) {
                    
                    ForEach(state.suffix, content: itemView)
                        .animation(.easeInOut, value: state)
                }
            }
        }
    }
}

public extension BannerPickerSectionContentView {
    
    typealias State = BannerPickerSectionState<ServiceBanner>
    typealias Event = BannerPickerSectionEvent<ServiceBanner>
    typealias Config = BannerPickerSectionContentViewConfig
}

private extension BannerPickerSectionState {
    
    var isLoadingFailed: Bool {
        
        !isLoading && suffix.isEmpty
    }
}

private extension BannerPickerSectionContentView {
        
    @ViewBuilder
    func itemView(
        item: State.Item
    ) -> some View {
        
        let view = itemView(item)
            .contentShape(Rectangle())
            .transition(transition(for: item))
        
        switch item {
        case .placeholder:
            view
            
        case let .element(identified):
            Button(action: { event(.select(identified.element)) }) {
                view
            }
        }
    }
    
    func transition(
        for item: State.Item
    ) -> AnyTransition {
        
        switch item {
        case .placeholder:
            return transition
            
        case .element:
            return transition
        }
    }
}

struct BannerPickerSectionContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            bannerPickerSectionContentView(.placeholders(count: 5))
            bannerPickerSectionContentView(.preview)
            bannerPickerSectionContentView(.placeholders(count: 0))
        }
    }
    
    private static func bannerPickerSectionContentView(
        _ items: [BannerPickerSectionState<PreviewServiceBanner>.Item],
        _ event: @escaping (BannerPickerSectionEvent<PreviewServiceBanner>) -> Void =  {
            switch $0 {
            case .load:
                print("load")
            case let .loaded(items):
                print("loaded \(items.count)")
            case let .select(item):
                print("select \(String(describing: item))")
            }
        }
    ) -> some View {
        
        BannerPickerSectionContentView(
            state: .init(prefix: [], suffix: items),
            event: event,
            config: .init(spacing: 10),
            itemView: { item in
                switch item {
                    
                case .placeholder:
                    Image(systemName: "person.text.rectangle")
                        .renderingMode(.original)
                        .shimmering(gradient: .shimmerDefault)

                case let .element(identified):
                    
                    Button(action: { event(.select(identified.element)) }) {
                        Image(systemName: "person.text.rectangle")
                            .renderingMode(.original)
                    }
                }
            }
        )
    }
}

struct PreviewServiceBanner: Equatable {
    
}

extension Array where Element == BannerPickerSectionState<PreviewServiceBanner>.Item {
    
    static func placeholders(count: Int) -> Self {
        
        (0..<count).map { _ in .placeholder(.init()) }
    }
    
    static var preview: Self {
        
        [PreviewServiceBanner].preview.map { .element(.init(.banner($0))) }
    }
}

extension Array where Element == PreviewServiceBanner {
    
    static let preview: Self = [
        .init(), .init(), .init(), .init()
    ]
}
