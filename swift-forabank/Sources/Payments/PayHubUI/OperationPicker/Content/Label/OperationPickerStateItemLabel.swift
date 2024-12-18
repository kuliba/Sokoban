//
//  OperationPickerStateItemLabel.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

public struct OperationPickerStateItemLabel<Latest, LatestView, PlaceholderView>: View
where LatestView: View,
      PlaceholderView: View {
    
    private let item: Item
    private let config: Config
    private let latestView: (Latest) -> LatestView
    private let placeholderView: () -> PlaceholderView
    
    public init(
        item: Item,
        config: Config,
        @ViewBuilder latestView: @escaping (Latest) -> LatestView,
        @ViewBuilder placeholderView: @escaping () -> PlaceholderView
    ) {
        self.item = item
        self.config = config
        self.latestView = latestView
        self.placeholderView = placeholderView
    }
    
    public var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case .exchange:
                selectableLabel(config.exchange)
                
            case let .latest(latest):
                latestView(latest)
                    .frame(config.latestPlaceholder.label.frame)
                
            case .templates:
                selectableLabel(config.templates)
            }
            
        case .placeholder:
            placeholderView()
                ._shimmering()
        }
    }
}

public extension OperationPickerStateItemLabel {
    
    typealias Item = OperationPickerState<Latest>.Item
    typealias Config = OperationPickerStateItemLabelConfig
}

private extension OperationPickerStateItemLabel {
    
    func selectableLabel(
        _ config: Config.IconConfig
    ) -> some View {
        
        selectableLabel(image: config.icon, title: config.title)
            .foregroundColor(config.color)
    }
    
    func selectableLabel(
        image: Image,
        title: String
    ) -> some View {
        
        IconWithTitleLabelVertical(
            icon: { icon(image) },
            title: {
                
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            },
            config: config.latestPlaceholder.label
        )
    }
    
    func icon(
        _ image: Image
    ) -> some View {
        
        ZStack {
            
            Color.solidGrayBackground
                .opacity(0.2)
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(config.iconSize)
        }
    }
}

// MARK: - Previews

struct UIItemLabel_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HStack(spacing: 4) {
            
            Group {
                
                uiItemLabel(.placeholder(.init()))
                uiItemLabel(.element(.init(.exchange)))
                uiItemLabel(.element(.init(.templates)))
                uiItemLabel(.element(.init(.latest(.preview))))
            }
            .border(.red)
        }
    }
    
    private static func uiItemLabel(
        _ item: OperationPickerState<PreviewLatest>.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .preview,
            latestView: { _ in
                
                Color.red.opacity(0.8)
                    .frame(width: 84, height: 96)
            },
            placeholderView: {
                
                Color.green.opacity(0.4)
                    .frame(width: 84, height: 96)
            }
        )
    }
}

struct PreviewLatest: Equatable {
    
    let id: String
}

extension PreviewLatest {
    
    static let preview: Self = .init(id: UUID().uuidString)
}
