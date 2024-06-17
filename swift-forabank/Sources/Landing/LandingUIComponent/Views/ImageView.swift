//
//  ImageView.swift
//  
//
//  Created by Andryusina Nataly on 17.09.2023.
//

import SwiftUI
import UIPrimitives

struct ImageView: View {
    
    @ObservedObject var model: UILanding.ImageBlock.ViewModel
    let config: UILanding.ImageBlock.Config

    var body: some View {
        
        VStack(spacing: 0) {
            switch model.image(byLink: model.data.link.rawValue) {
            case .none:
                if model.data.placeholder.rawValue {
                    Rectangle()
                        .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.97))
                        .frame(height: 64)
                        .shimmering()
                }
                
            case let .some(image):
                image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                    .padding(.horizontal, config.paddings.horizontal)
                    .padding(.vertical, config.paddings.vertical)
                    .accessibilityIdentifier("ImageView")
            }
        }
        .background(config.backgroundColor(model.data.backgroundColor.rawValue, defaultColor: config.background.defaultColor))
        .padding(.bottom, -config.negativeBottomPadding)
    }
}
