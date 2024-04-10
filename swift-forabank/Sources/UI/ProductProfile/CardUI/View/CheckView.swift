//
//  CheckView.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

struct CheckView: View {
    
    let config: Config
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .frame(
                    width: config.sizes.checkView.width,
                    height: config.sizes.checkView.height
                )
                .foregroundColor(config.colors.checkForeground.opacity(0.12))
            
            config.images.check
                .resizable()
                .foregroundColor(config.colors.foreground)
                .background(Color.clear)
                .frame(width: config.sizes.checkViewImage.width, height: config.sizes.checkViewImage.height)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topTrailing
        )
        .padding(config.front.checkPadding)
    }
}

struct CheckView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CheckView(config: .config(.previewCard))
    }
}
