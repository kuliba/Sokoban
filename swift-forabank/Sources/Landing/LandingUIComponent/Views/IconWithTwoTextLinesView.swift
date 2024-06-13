//
//  IconWithTwoTextLinesView.swift
//  
//
//  Created by Andrew Kurdin on 2023-09-14.
//

import SwiftUI

struct IconWithTwoTextLinesView: View {
    
    @ObservedObject var model: ViewModel
    private let config: UILanding.IconWithTwoTextLines.Config
    
    init(
        model: ViewModel,
        config: UILanding.IconWithTwoTextLines.Config
    ) {
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        VStack {
            
            switch model.image(byMd5Hash: model.data.md5hash) {
            case .none:
                Color.grayLightest
                    .frame(width: config.icon.size, height: config.icon.size)
                    .cornerRadius(config.icon.size/2)
                    .padding(.bottom, config.icon.paddingBottom)
                    .accessibilityIdentifier("IconWithTwoTextLinesDefaultIcon")
                
            case let .some(image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: config.icon.size, height: config.icon.size)
                    .cornerRadius(config.icon.size/2)
                    .padding(.bottom, config.icon.paddingBottom)
                    .accessibilityIdentifier("IconWithTwoTextLinesImageIcon")
            }
            
            model.data.title.map {
                
                Text($0)
                    .font(config.title.font)
                    .foregroundColor(config.title.color)
                    .padding(.bottom, config.title.paddingBottom)
                    .accessibilityIdentifier("IconWithTwoTextLinesFirstLine")
            }
            
            model.data.subTitle.map {
                
                Text($0)
                    .font(config.subTitle.font)
                    .foregroundColor(config.subTitle.color)
                    .padding(.bottom, config.subTitle.paddingBottom)
                    .accessibilityIdentifier("IconWithTwoTextLinesSecondLine")
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, config.paddings.vertical)
        .padding(.vertical, config.paddings.vertical)
    }
}

struct IconWithTwoTextLines_Previews: PreviewProvider {
    static var previews: some View {
        IconWithTwoTextLinesView(model: .init(data: .default, images: [:]), config: .defaultValue)
    }
}
