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
            
            Rectangle()
                .fill(config.appearance.background.color)
            config.images.check
                .resizable()
                .renderingMode(.original)
                .opacity(0.9)
        }
        .frame(width: config.sizes.checkViewImage.width, height: config.sizes.checkViewImage.height)
        .padding(config.front.checkPadding)
    }
}

struct CheckView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CheckView(config: .config(.previewCard))
    }
}
