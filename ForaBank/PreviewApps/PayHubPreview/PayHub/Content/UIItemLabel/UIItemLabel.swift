//
//  UIItemLabel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

// app specific
struct UIItemLabel: View {
    
    let item: Item
    let config: Config
    
    var body: some View {
        
        switch item {
        case .placeholder:
            LatestPlaceholder(
                opacity: 1,
                config: config.latestPlaceholder
            )
            ._shimmering()
            
        case .selectable(.exchange):
            selectableLabel(systemName: "dollarsign.arrow.circlepath", title: "Exchange")
            
        case let .selectable(.latest(latest)):
            selectableLabel(systemName: "l.circle", title: latest.name)
            
        case .selectable(.templates):
            selectableLabel(systemName: "star", title: "Templates")
        }
    }
}

extension UIItemLabel {
    
    typealias Item = UIItem<Latest>
    typealias Config = UIItemLabelConfig
}

private extension Latest {
    
    var name: String { .init(id.prefix(12)) }
}

private extension UIItemLabel {
    
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
                .aspectRatio(contentMode: .fill)
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
                uiItemLabel(.selectable(.exchange))
                uiItemLabel(.selectable(.latest(.preview())))
                uiItemLabel(.selectable(.templates))
            }
            .border(.red)
        }
    }
    
    private static func uiItemLabel(
        _ item: UIItemLabel.Item
    ) -> some View {
        
        UIItemLabel(item: item, config: .preview)
    }
}

extension Latest {
    
    static func preview() -> Self { return .init(id: UUID().uuidString) }
}

extension UIItemLabelConfig {
    
    static let preview: Self = .init(
        latestPlaceholder: .preview
    )
}
