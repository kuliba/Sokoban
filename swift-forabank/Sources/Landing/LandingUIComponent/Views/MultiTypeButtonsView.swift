//
//  MultiTypeButtonsView.swift
//  
//
//  Created by Andryusina Nataly on 21.09.2023.
//

import SwiftUI

struct MultiTypeButtonsView: View {
    
    @ObservedObject var model: ViewModel
    private let config: UILanding.Multi.TypeButtons.Config
    
    init(
        model: ViewModel,
        config: UILanding.Multi.TypeButtons.Config
    ) {
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        HStack(spacing: config.spacing) {
            
            Button(action: { model.openUrl(for: model.data.textLink) }) {
                
                switch model.image(byImageLink: model.data.md5hash) {
                case .none:
                    Color.white
                        .frame(config)
                    
                case let .some(image):
                    image
                        .resizable()
                        .frame(config)
                }
                
                Text(model.data.text)
                    .font(config.fonts.into)
                    .foregroundColor(config.textColor(model.data.backgroundColor))
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier("MultiTypeButtonsText")
            }
            Button(action: { model.handler(for: model.data) }) {
                Text(model.data.buttonText)
                    .font(config.fonts.button)
                    .multilineTextAlignment(.center)
                    .foregroundColor(config.colors.buttonText)
                    .accessibilityIdentifier("MultiTypeButtonsButtonText")
            }
            .frame(height: config.sizes.heightButton)
            .frame(maxWidth: .infinity)
            .background(config.colors.button)
            .cornerRadius(config.cornerRadius)
            .accessibilityIdentifier("MultiTypeButtonsButton")
        }
        .padding(.top, config.paddings.top)
        .padding(.bottom, config.paddings.bottom)
        .padding(.horizontal, config.paddings.horizontal)
        .frame(maxWidth: .infinity)
        .background(config.backgroundColor(model.data.backgroundColor))
    }
}

struct MultiTypeButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        
        MultiTypeButtonsView(
            model: .init(
                data: .default,
                images: [:],
                selectDetail: {_ in },
                action: {_ in },
                orderCard: {_, _ in }
            ),
            config: .default
        )
        .background(Color.black)
    }
}

extension View {
    
    func frame(
        _ config: UILanding.Multi.TypeButtons.Config
    ) -> some View {
        
        self.frame(
            width: config.sizes.imageInfo,
            height: config.sizes.imageInfo
        )
    }
}
