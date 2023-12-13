//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

public struct Info {
    
    let id: GetSberQRDataResponse.Parameter.Info.ID
    let value: String
    let title: String
    let image: Image
    
    public init(
        id: GetSberQRDataResponse.Parameter.Info.ID,
        value: String,
        title: String,
        image: Image
    ) {
        self.id = id
        self.value = value
        self.title = title
        self.image = image
    }
}

struct InfoView: View {
    
    let info: Info
    let config: InfoConfig
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            info.image
                .resizable()
                .frame(info.size)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                
                text(info.title, config: config.title)
                text(info.value, config: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
