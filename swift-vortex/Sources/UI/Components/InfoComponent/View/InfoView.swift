//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 22.05.2024.
//

import SwiftUI

public struct InfoView<Icon: View>: View {
    
    let info: Info
    let config: InfoConfig
    let icon: () -> Icon
    
    public init(
        info: Info,
        config: InfoConfig,
        icon: @escaping () -> Icon
    ) {
        self.info = info
        self.config = config
        self.icon = icon
    }
    
    public var body: some View {
        
        switch info.style {
        case .expanded:
            HStack(alignment: .customAlignment, spacing: 12) {
                
                iconView()
                    .alignmentGuide(.customAlignment, computeValue: { d in d[VerticalAlignment.bottom] })
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    titleView()
                    valueView()
                        .alignmentGuide(.customAlignment, computeValue: { d in d[VerticalAlignment.firstTextBaseline] })
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        case .compressed:
            HStack(spacing: 12) {
                
                iconView()
         
                HStack {
                    
                    titleView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    valueView()
                }
            }
        }
    }
}

public extension InfoView where Icon == EmptyView {
    
    init(
        info: Info,
        config: InfoConfig
    ) {
        self.info = info
        self.config = config
        self.icon = EmptyView.init
    }
}

extension VerticalAlignment {
    
    private enum CustomAlignment : AlignmentID {
    
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            
            return d[.top]
        }
    }
    static let customAlignment = VerticalAlignment(CustomAlignment.self)
}

private extension InfoView {
    
    func iconView() -> some View {
        
        icon()
            .frame(info.size)
            .frame(width: 32, height: 32)
    }
    
    func titleView() -> some View {
        
        info.title.text(withConfig: config.title)
    }
    
    func valueView() -> some View {
        
        info.value.text(withConfig: config.value)
    }
}

private extension Info {
    
    var size: CGSize {
        
        switch id {
        case .amount:
            return .init(width: 24, height: 24)
            
        case .brandName, .recipientBank, .other:
            return .init(width: 32, height: 32)
        }
    }
}

// MARK: - Previews

#Preview {
    
    VStack(spacing: 32) {
        
        Group {
            
            InfoView(info: .amountCompressed, config: .preview)
            InfoView(info: .amountCompressed, config: .preview) { EmptyView() }
            InfoView(info: .amountCompressed, config: .preview) { Color.orange }
            
            InfoView(info: .amount, config: .preview) { Color.orange }
            InfoView(info: .brandName, config: .preview) { Color.orange }
            InfoView(info: .recipientBank, config: .preview) { Color.orange }
            
            InfoView(info: .init(id: .amount, title: "Some Title", value: .long, style: .expanded), config: .preview) { Color.orange }
            InfoView(info: .init(id: .other("other"), title: "Some Title", value: .long, style: .expanded), config: .preview) { Color.orange }
        }
        .border(.red.opacity(0.2))
    }
    .previewLayout(.sizeThatFits)
}

private extension String {
    
    static let long = "Pretty long text that does not fit into one string and has to continue on the second and event to the third line"
}
