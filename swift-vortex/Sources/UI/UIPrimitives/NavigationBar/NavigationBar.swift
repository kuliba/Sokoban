//
//  NavigationBar.swift
//
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import SwiftUI
import SharedConfigs

public struct NavigationBar: View {
    
    let backAction: () -> Void
    let title: String
    let subtitle: String?
    
    let config: NavigationBarConfig
    
    public init(
        backAction: @escaping () -> Void,
        title: String,
        subtitle: String?,
        config: NavigationBarConfig
    ) {
        self.backAction = backAction
        self.title = title
        self.subtitle = subtitle
        self.config = config
    }
        
    public var body: some View {
        
        VStack {
            HStack {
                Button(action: backAction) {
                    HStack {
                        Image(systemName: "chevron.left")
                    }.foregroundColor(config.colors.foreground)
                }
                .frame(width: config.sizes.widthBackButton)
                VStack() {
                    Text(title)
                        .font(config.title.textFont)
                        .lineLimit(1)
                        .foregroundColor(config.title.textColor)
                    subtitle.map {
                        Text($0)
                            .font(config.subTitle.textFont)
                            .lineLimit(1)
                            .foregroundColor(config.subTitle.textColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, -config.sizes.widthBackButton)
            }.padding(.horizontal, config.sizes.padding)
        }
        .background(config.colors.background.edgesIgnoringSafeArea(.all))
        .frame(height: config.sizes.heightBar)
    }
}

#Preview {
    NavigationBar(
        backAction: {},
        title: "Title",
        subtitle: "Subtitle", 
        config: .init(
            title: .init(textFont: .title, textColor: .black),
            subTitle: .init(textFont: .body, textColor: .gray),
            colors: .init(foreground: .black, background: .white),
            sizes: .init(heightBar: 45, padding: 16, widthBackButton: 24)
        ))
}

