//
//  ImageSvg.swift
//  
//
//  Created by Andryusina Nataly on 17.09.2023.
//

import SwiftUI

struct ImageSvg: View {
    
    @ObservedObject var model: UILanding.ImageSvg.ViewModel
    let config: UILanding.ImageSvg.Config

    var body: some View {
        
        VStack(spacing: 0) {
            
            switch model.image(byMd5Hash: model.data.md5hash.rawValue) {
            case .none:
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 84)
                
            case let .some(image):
                image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                    .padding(.horizontal, config.paddings.horizontal)
                    .padding(.vertical, config.paddings.vertical)
                    .accessibilityIdentifier("ImageSvg")
            }
        }
        .background(config.backgroundColor(model.data.backgroundColor.rawValue, defaultColor: config.background.defaultColor))
    }
}
