//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct InfoView: View {
    
    let info: Info
    let config: InfoConfig
    
    @State private var image: Image
    
    init(
        info: Info,
        config: InfoConfig
    ) {
        self.info = info
        self.config = config
        self.image = info.image.value
    }
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            icon()
                .frame(info.size)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                
                text(info.title, config: config.title)
                text(info.value, config: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private func text(
        _ text: String,
        config: TextConfig
    ) -> some View {
        
        Text(text)
            .foregroundColor(config.textColor)
            .font(config.textFont)
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
        
        InfoView(info: info, config: .default)
    }
}
