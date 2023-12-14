//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

extension View {
    
    func frame(_ size: CGSize) -> some View {
        
        frame(width: size.width, height: size.height)
    }
}

struct InfoView: View {
    
    typealias Info = SberQRConfirmPaymentState.Info
    
    let info: Info
    let config: InfoConfig
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            icon(info.icon)
                .frame(info.size)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                
                text(info.title, config: config.title)
                text(info.value, config: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func icon(_ icon: Info.Icon) -> some View {
            #warning("use type")
        //        switch icon.type {
        //        case .local:
        //        case .remote:
        //        }
        
        Image(icon.value)
            .resizable()
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

private extension SberQRConfirmPaymentState.Info {
    
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
        info: SberQRConfirmPaymentState.Info
    ) -> some View {
        
        InfoView(info: info, config: .default)
    }
}
