//
//  OperationPickerStateItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

// app specific
public struct OperationPickerStateItemLabel<Latest, PlaceholderView>: View
where Latest: Named,
      PlaceholderView: View {
    
    private let item: Item
    private let config: Config
    private let placeholderView: () -> PlaceholderView
    
    public init(
        item: Item, 
        config: Config,
        placeholderView: @escaping () -> PlaceholderView
    ) {
        self.item = item
        self.config = config
        self.placeholderView = placeholderView
    }
    
    public var body: some View {
        
        switch item {
        case let .element(identified):
            switch identified.element {
            case .exchange:
                selectableLabel(systemName: "dollarsign.arrow.circlepath", title: "Exchange")
                
            case let .latest(latest):
                selectableLabel(systemName: "l.circle", title: latest.name)
                
            case .templates:
                selectableLabel(systemName: "star", title: "Templates")
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
        systemName: String,
        title: String
    ) -> some View {
        
        IconWithTitleLabelVertical(
            icon: { icon(systemName) },
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
        _ systemName: String
    ) -> some View {
        
        ZStack {
            
            Color.solidGrayBackground
                .opacity(0.2)
            
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
        .foregroundColor(.secondary)
    }
}

// MARK: - Previews

struct UIItemLabel_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HStack(spacing: 4) {
            
            Group {
                
                uiItemLabel(.placeholder(.init()))
                uiItemLabel(.element(.init(.exchange)))
                uiItemLabel(.element(.init(.latest(.preview()))))
                uiItemLabel(.element(.init(.templates)))
            }
            .border(.red)
        }
    }
    
    private static func uiItemLabel(
        _ item: OperationPickerState<PreviewLatest>.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(item: item, config: .preview) {
            
            Color.green.opacity(0.1)
        }
    }
}

struct PreviewLatest: Equatable, Named {
    
    let id: String
    
    var name: String { .init(id.prefix(12)) }
}

extension PreviewLatest {
    
    static func preview() -> Self {
        
        return .init(id: UUID().uuidString)
    }
}
