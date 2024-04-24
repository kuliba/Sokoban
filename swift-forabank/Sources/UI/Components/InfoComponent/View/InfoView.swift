//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

public struct InfoView: View {
    
    let info: Info
    let config: InfoConfig
    
    @State private var image: Image
    
    public init(
        info: Info,
        config: InfoConfig
    ) {
        self.info = info
        self.config = config
        self.image = info.image.value
    }
    
    public var body: some View {
        
        HStack(spacing: 12) {
            
            icon()
                .frame(info.size)
                .frame(width: 32, height: 32)
            
            switch info.style {
            case .expanded:
                VStack(alignment: .leading, spacing: 4) {
                    
                    info.title.text(withConfig: config.title)
                    info.value.text(withConfig: config.value)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            case .compressed:
                HStack {
                    
                    info.title.text(withConfig: config.title)
                    
                    Spacer()
                    
                    info.value.text(withConfig: config.value)
                }
            }
        }
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

private extension Info {
    
    var size: CGSize {
        
        switch id {
        case .amount:
            return .init(width: 24, height: 24)
            
        case .brandName, .recipientBank:
            return .init(width: 32, height: 32)
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
        info: Info
    ) -> some View {
        
        Group {
            
            InfoView(info: info, style: .expanded, config: .preview)
            
            InfoView(info: info, style: .compressed, config: .preview)
        }
        .padding(20)
    }
}
