//
//  PayHubPickerStateItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

// app specific
struct PayHubPickerStateItemLabel: View {
    
    let item: Item
    let config: Config
    
    var body: some View {
        
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
            LatestPlaceholder(
                opacity: 1,
                config: config.latestPlaceholder
            )
            ._shimmering()
        }
    }
}

extension PayHubPickerStateItemLabel {
    
    typealias Item = PayHubPickerState.Item
    typealias Config = PayHubPickerStateItemLabelConfig
}

private extension Latest {
    
    var name: String { .init(id.prefix(12)) }
}

private extension PayHubPickerStateItemLabel {
    
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
        _ item: PayHubPickerStateItemLabel.Item
    ) -> some View {
        
        PayHubPickerStateItemLabel(item: item, config: .preview)
    }
}

extension Latest {
    
    static func preview() -> Self {
        
        return .init(id: UUID().uuidString)
    }
}

extension PayHubPickerStateItemLabelConfig {
    
    static let preview: Self = .init(
        latestPlaceholder: .preview
    )
}
