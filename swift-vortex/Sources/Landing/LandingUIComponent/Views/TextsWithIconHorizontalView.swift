//
//  TextsWithIconHorizontalView.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2023.
//

import SwiftUI

struct TextsWithIconHorizontalView: View {
    
    @ObservedObject var model: ViewModel
    let config: UILanding.TextsWithIconHorizontal.Config
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .foregroundColor(config.backgroundColor)
                .accessibilityIdentifier("TextsWithIconHorizontalBody")
            
            HStack(spacing: config.spacing) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: config.circleSize, height: config.circleSize)
                        .accessibilityIdentifier("TextsWithIconHorizontalCircle")
                    
                    switch model.image(byMd5Hash: model.data.md5hash, imagesFromConfig: config.images) {
                    case .none:
                        Color.grayLightest
                            .frame(width: config.icon.width, height: config.icon.width)
                        
                    case let .some(image):
                        image
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: config.icon.width, height: config.icon.height)
                    }
                }
                
                Text(model.data.title)
                    .font(config.text.font)
                    .foregroundColor(config.text.color)
                    .padding(.trailing)
                    .accessibilityIdentifier("TextsWithIconHorizontalText")
            }
            .padding(.leading, config.icon.padding.leading)
        }
        .frame(height: config.height)
        .padding(.vertical, config.paddings.vertical)
        .padding(.horizontal, config.paddings.horizontal)
        .modifier(CustomFrameModifier(active: model.data.contentCenterAndPull))
    }
}

struct CustomFrameModifier : ViewModifier {
    var active : Bool
    
    @ViewBuilder func body(content: Content) -> some View {
        if active {
            content.fixedSize()
        } else {
            content.frame(maxWidth: .infinity)
        }
    }
}

struct TextsWithIconHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            TextsWithIconHorizontalView(
                model: .init(
                    data: .init(
                        md5hash: "1",
                        title: "title",
                        contentCenterAndPull: true),
                    images: .defaultValue),
                config: .default)
            
            TextsWithIconHorizontalView(
                model: .init(
                    data: .init(
                        md5hash: "1",
                        title: "title",
                        contentCenterAndPull: false),
                    images: .defaultValue),
                config: .default)
        }
    }
}
