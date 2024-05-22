//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

public struct InfoView: View {
    
    let info: PublishingInfo
    let config: InfoConfig
    
    @State private var image: Image
    
    public init(
        info: PublishingInfo,
        config: InfoConfig
    ) {
        self.info = info
        self.config = config
        self.image = info.image.value
    }
    
    public var body: some View {
        
        InfoLayoutView(
            info: info.layoutInfo,
            config: config,
            icon: icon
        )
        .onReceive(info.image, perform: { self.image = $0 })
    }
    
    @ViewBuilder
    private func icon() -> some View {
        
        image
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

private extension PublishingInfo {
    
    var layoutInfo: LayoutInfo {
        
        .init(
            id: layoutInfoID,
            title: title,
            value: value,
            style: layoutInfoStyle
        )
    }
}

private extension PublishingInfo {
    
    var layoutInfoID: LayoutInfo.ID {
        
        switch id {
        case .amount:        return .amount
        case .brandName:     return .brandName
        case .recipientBank: return .recipientBank
        }
    }
    
    var layoutInfoStyle: LayoutInfo.Style {
        
        switch style {
        case .compressed: return .compressed
        case .expanded:   return .expanded
        }
    }
}

// MARK: - Previews

struct InfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            infoView(info: .amount)
            infoView(info: .brandName)
            infoView(info: .recipientBank)
        }
        .previewLayout(.sizeThatFits)
    }
    
    private static func infoView(
        info: PublishingInfo
    ) -> some View {
        
        Group {
            
            InfoView(info: info, config: .preview)
            
            InfoView(info: info, config: .preview)
        }
        .padding(20)
    }
}
